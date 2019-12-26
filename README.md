# vagrant-openstack
日本仮想化技術株式会社さんが公開されている「[OpenStack Newton 構築手順書(Ubuntu 16.04LTS版)](https://github.com/virtualtech/openstack-newton-docs)」の環境をVagrantで構築するためのShellScriptです。

## 動作環境
次の環境で動作確認を行っています。

- NEC LAVIE ProMobile
  - Ubuntu Desktop 19.10
    - Vagrant 2.2.3+dfsg-1ubuntu2
    - VirtualBox 6.0.14-dfsg-1

どちらもaptで入れられるVerisonです。Oracleのサイトからダウンロード可能なVirtualBox6.1などはまだvagrant側が対応していないのでaptで入れられるものを用いるようにしてください。

## 設定
構築手順書の環境から少し変更を加えております。

### アサインメモリ
上記動作環境で動作確認を取るためメモリの制約があり、controllerノードには4GB,computeノードには2GBのメモリアサインとしています。
もっとメモリを搭載したマシンを検証用に用意すべきですね。（欲しい）

あなたの動作させようとする環境に応じてVagrantfileの編集をする事でより快適に動作させる事が可能かと思います。

### NAT環境
まっさらに用意したLinux環境にvagrantとvirtualboxだけ入れることで動くようにしたためvagrant内で作成可能なネットワークのみで作るようにしています。
そのためcontrollerノードに構築したhorizonへアクセスする際はloalhostにNATしたポートへ接続する様になります。

## 導入後
settingsディレクトリに入っているadmin-openrcやdemo-openrcを用いて学習することが出来ます。またWebブラウザで http://localhost:8880/horizon/ へアクセスする事でWebUIでのコントロールも可能です。ログインするID等はopenrcファイルの中身を確認してください。
