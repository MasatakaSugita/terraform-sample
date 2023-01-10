output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "alb_arn" {
  value = aws_lb.main.arn
}