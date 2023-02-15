#----------------------------
# WAF ACL
#----------------------------
resource "aws_wafv2_web_acl" "main" {
  name  = "${var.app_name}-WebACL"
  description = "${var.app_name}-WebACL"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  #日本からの通信を通す
  #forwarded_ip_configのX-Forwarded-Forヘッダーでip取得をすることで日本の踏み台サーバー経由でもある程度カバーできる
  rule {
    name = "allowJpRule"
    priority = 0

    action {
      allow {}
    }

    statement {
      geo_match_statement {
        forwarded_ip_config {
          header_name = "X-Forwarded-For"
          fallback_behavior = "MATCH"
        }
        country_codes = ["JP"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allowJpRuleMetric"
      sampled_requests_enabled   = false
    }
  }


  #DDoS攻撃に対するルール(5分間あたりのlimit(閾値)を超えた場合にblockする)
  rule {
    name     = "AWSRateBasedRule"
    priority = 10

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit = 100
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSRateBasedRuleWAFMetric"
      sampled_requests_enabled   = true
    }
  }

  #SQLインジェクション攻撃に対するルール
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSetWAFMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.app_name}-WebACL"
    sampled_requests_enabled   = true
  }
}

#----------------------------
# WAF ACLをALBにアタッチ
#----------------------------
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}