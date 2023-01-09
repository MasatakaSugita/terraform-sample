動作確認をするためにAWS ECRにpushするサンプルアプリケーション

## ECRへのpush手順
### 1. ローカルでDockerImageを作成する
```
DockerFileがあるディレクトリで
$ docker build . -t {app_name}
```

### 2.ECRにpushする
認証トークンを取得し、レジストリに対して Docker クライアントを認証します。
AWS CLI を使用する
```
$ aws ecr --profile プロファイル名 get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin {アカウント番号}.dkr.ecr.ap-northeast-1.amazonaws.com
```

リポジトリにイメージをプッシュできるように、イメージにタグを付けます。
```
$ docker tag terraform-sample:latest {アカウント番号}.dkr.ecr.ap-northeast-1.amazonaws.com/terraform-sample:latest
```

新しく作成した AWS リポジトリにこのイメージをプッシュします
```
$ docker push {アカウント番号}.dkr.ecr.ap-northeast-1.amazonaws.com/terraform-sample:latest
```