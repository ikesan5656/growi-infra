#!/bin/bash

# 1. OracleLinuxのアップデート
dnf update -y

# 2. Dockerのインストールに必要なリポジトリの追加とインストール
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io

# 3. Dockerサービスの起動と自動起動有効化
systemctl start docker
systemctl enable docker

# 4. OS内部ファイアウォール（firewalld）の解放
# ロードバランサーからの通信（3000番ポート）を許可します
firewall-cmd --permanent --zone=public --add-port=3000/tcp
firewall-cmd --reload

# 5. Growiの簡易起動
# ※疎通確認用に公式イメージをポート3000でバックグラウンド起動します
docker run -d --name growi -p 3000:3000 weseek/growi:latest