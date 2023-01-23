- [ステップ1 Terraformを使う](#ステップ1-terraformを使う)
  - [実行準備](#実行準備)
    - [Terraform CLIのインストール](#terraform-cliのインストール)
    - [AWSプロファイルの準備](#awsプロファイルの準備)
  - [基礎的なterraformの使い方](#基礎的なterraformの使い方)
    - [コードの準備](#コードの準備)
    - [Terraformでリソースをデプロイ](#terraformでリソースをデプロイ)
    - [Terraformでデプロイしたリソースを削除](#terraformでデプロイしたリソースを削除)

# ステップ1 Terraformを使う

まずはTerraformを使って簡単なリソースをデプロイしてみましょう。Terraform CLIを端末にインストールし、サンプルのコードを使ってリソースをデプロイしてみます。

## 実行準備

Terraformを使えるように準備します。前提として作業端末はインターネットに繋がっている必要があります。(HashicorpおよびAWSへアクセスします。)

### Terraform CLIのインストール

Terraformコマンドはシングルバイナリで実行できます。[こちらの公式ページ](https://developer.hashicorp.com/terraform/downloads)にアクセスし、端末にあった方法でインストールしてください。

たとえば、v1.3.7(2023/1時点の最新)をUbuntuにインストールする場合は以下のようにします。

``` sh
$ wget https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip
$ unzip terraform_1.3.7_linux_amd64.zip
$ chmod +x terraform
$ mv terraform /usr/local/bin/
```

Terraform CLIをインストールしたら以下でコマンドが使用できることを確認します。

``` sh
$ terraform version
```

### AWSプロファイルの準備

本プラクティスではAWSを使用します。AWS CLIの設定をしておいてください。使用するIAMユーザーにはAdministratorAccess等の強い権限を与えておくと楽ですが、組織のポリシーに従い権限を付与してください。

AWS CLIのインストールおよび設定は公式のドキュメントを参照してください。

- [Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Configuration basics](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

## 基礎的なterraformの使い方

### コードの準備

以下コマンドで作業用に`step1`ディレクトリを作成し、そのディレクトリ下に`test.tf`を作成します。このコードは東京リージョンに10.1.0.0/16のCIDRブロックを持つtf-testという名前のVPCを作成します。（リージョンは変えても構いません）

``` sh
$ mkdir step1
$ cd step1
$ cat <<EOF > test.tf
terraform {
  required_providers {
    aws = {
      version = ">= 4.49.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
}

resource "aws_vpc" "tf_test" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "tf-test"
  }
}
EOF
```

### Terraformでリソースをデプロイ

Terraformを使ってリソースをデプロイするには`init`、`plan`、`apply`を行います。

まずは`terraform init`コマンドでTerraformを実行するディレクトリの初期化を行います。`Terraform has been successfully initialized!`が出れば成功です。initは実行ディレクトリで1回行えばあとは実行しなくてもよいです。（プロバイダーやモジュールを変更した場合はinitし直しが必要です。）

``` sh
$ terraform init
...
Terraform has been successfully initialized!
...
```

続いて`terraform plan`でコードによりデプロイされるリソースの内容を確認します。planは省略可能ですがplanで確認するクセをつけた方がいいです。

``` sh
$ terraform plan
...
```

最後に`terraform apply`をするとリソースがデプロイされます。applyするとplanの結果も表示されます。確認メッセージで`yes`を入力するとデプロイされます。問題を見つけた場合は`no`など入力すればいいです。最終的に`Apply complete!`のメッセージが出ればデプロイ完了です。

``` sh
$ terraform apply
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: # yesを入力
...
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

マネコンや以下コマンドでTerraformコードのリソースがデプロイされていることを確認できます。

``` sh
$ aws ec2 describe-vpcs --filters "Name=tag-value,Values=tf-test"
```

### Terraformでデプロイしたリソースを削除

`terraform destroy`でデプロイしたリソースを削除できます。destroyを実行するとapplyと同様に最終確認メッセージの入力が求められます。`yes`を入力するとリソースを削除します。destroyは危険なコマンドなため注意して扱いましょう。`Destroy complete!`のメッセージが出れば削除完了です。

``` sh
$ pwd # step1ディレクトリにいることを確認
$ terraform destroy
...
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: # yesを入力
...
Destroy complete! Resources: 1 destroyed.
```

applyの時と同様、マネコンやAWSコマンドでTerraformコードのリソースが削除されていることを確認できます。
