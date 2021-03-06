# vagrant-openstack
日本仮想化技術株式会社さんが公開されている「[OpenStack Newton 構築手順書(Ubuntu 16.04LTS版)](https://github.com/virtualtech/openstack-newton-docs)」の環境をVagrantで構築するためのShellScriptです。

## 動作環境
次の環境で動作確認を行っています。

- NEC LAVIE ProMobile
  - Ubuntu Desktop 19.10
    - Vagrant 2.2.3+dfsg-1ubuntu2
    - VirtualBox 6.0.14-dfsg-1

- NEC LAVIE ProMobile
  - Windows 10 pro
    - Vagrant 2.2.7 for Windows 64bit
    - VirtualBox 6.1.4 for Windows 64bit

## 設定
構築手順書の環境から少し変更を加えております。

### アサインメモリ
controllerノードには8GB,computeノードには2GBのメモリアサインとしています。
controllerノードは4GBでも動作しますがhorizonを用いる際にかなり快適度が異なります。
あなたの動作させようとする環境に応じてVagrantfileの編集をする事でより快適に動作させる事が可能かと思います。

### NAT環境
まっさらに用意したLinux/Windows環境にvagrantとvirtualboxだけ入れることで動くようにしたためvagrant内で作成可能なネットワークのみで作るようにしています。
そのためcontrollerノードに構築したhorizonへアクセスする際はloalhostにNATしたポートへ接続する様になります。

## 導入後
settingsディレクトリに入っているadmin-openrcやdemo-openrcを用いて学習することが出来ます。またWebブラウザで http://localhost:8880/horizon/ へアクセスする事でWebUIでのコントロールも可能です。ログインするID等はopenrcファイルの中身を確認してください。
