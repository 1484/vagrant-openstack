# vagrant-openstack
日本仮想化技術株式会社さんが公開されている「[OpenStack Newton 構築手順書(Ubuntu 16.04LTS版)](https://github.com/virtualtech/openstack-newton-docs)」の環境をVagrantで構築するためのShellScriptです。

## 動作環境
次の環境で動作確認を行っています。

- Microsoft Surface Pro4 (8GB memory)
  - Windows10 Professional
    - Vagrant 1.9.3
    - VirtualBox 5.1.22

Vagrantは最新ではありません、最新で動かなかった場合は上記Versionにてお試しいただければと思います。

## 設定
構築手順書の環境から少し変更を加えております。

### アサインメモリ
上記動作環境で動作確認を取るためメモリの制約があり、controllerノードには4GB,computeノードには2GBのメモリアサインとしています。
もっとメモリを搭載したマシンを検証用に用意すべきですね。（欲しい）

あなたの動作させようとする環境に応じてVagrantfileの編集をする事でより快適に動作させる事が可能かと思います。

### NAT環境
Windows上にインストールしたVertualBoxの仮想マシン上で環境を構築しているため、controller上に構築されるHorizonへアクセスするなどNAT環境を構築しています。127.0.0.1:80 へNATしていますので、あなたの環境で都合が悪い場合はVagrantfileの記載を修正してください。

## Branch
masterブランチとazureブランチを切っています。VirtualBoxで使う方はmasterブランチを、azureで使う方はazureブランチをお使いいただければ良いかと思います。

### azure branch
azure branchではVagrantfile以外にENVを用いてazureのアカウント設定を行う必要があります。まだ説明書き等は追いついていません。

またazure branchではまだ動作確認が不十分で正常に動作しない事がわかっています。
