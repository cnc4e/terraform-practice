- [ステップ6 Tips](#ステップ6-tips)
  - [tfstateのリモートバックエンド化](#tfstateのリモートバックエンド化)
  - [リモートバックエンドのtfstateから値を参照する](#リモートバックエンドのtfstateから値を参照する)
  - [1つのモジュールで複数のリージョンを使う](#1つのモジュールで複数のリージョンを使う)
  - [特定のリース、モジュールだけ操作](#特定のリースモジュールだけ操作)
  - [リソースの依存関係は自動でやってくれるが明示的にdepends\_onさせることもできる](#リソースの依存関係は自動でやってくれるが明示的にdepends_onさせることもできる)
  - [ignore\_changesで変更を無視できる](#ignore_changesで変更を無視できる)
  - [リソースファイルは分けてもいい](#リソースファイルは分けてもいい)
  - [Terraformのベストプラクティス](#terraformのベストプラクティス)
  - [その他便利なterraformコマンド](#その他便利なterraformコマンド)
    - [fmt](#fmt)
    - [show](#show)
    - [validate](#validate)

# ステップ6 Tips

知っておくと便利なことをまとめます。とくにプラクティスはなく読むものです。読み飛ばしても構いません。

## tfstateのリモートバックエンド化

tfstateはTerraformでデプロイしたリソース情報が書き込まれる大事なファイルです。消してしまっても復元できるようにするのが望ましいです。また、チームでコードを共有する場合、tfstateも共有します。

tfstateはローカルではなく、外部のストレージサービス(S3等)に配置することができます。また、同時に複数人がtfstateを更新しないようにDynamoDBを使った排他制御もできます。[こちら](./step6/remote-backend/)にstateを格納するS3バケットと排他制御用のDynamoDBを作るサンプルのTerraformコードを用意しました。一点、README.mdにもありますがこのコード自体のstateはローカルに作成されます。リソース作成後にコマンドでtfstateをS3にアップロードし、versions.tfを書き換えればこのモジュールのtfstateもリモートバックエンドで管理できます。

別のモジュールで上記作成したリモートバックエンドを使うには以下のようにterraformブロックを設定します。`<module_name>`は任意のモジュール名に書き換えてください。

```
terraform {
...
  backend "s3" {
    bucket         = "<base_name>-tfstate"
    key            = "<module_name>/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "<base_name>-tfstate-lock"
    region         = "ap-northeast-1"
  }
}
```


**参考**

- [Terraform公式:バックエンドS3](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

## リモートバックエンドのtfstateから値を参照する

リモートバックエンドに保管したtfstateからモジュールでoutputした値を参照できます。例えばstep5のモジュールをリモートバックエンド化し、別のモジュールから参照するには以下のように書きます。

```
data "terraform_remote_state" "step5" {
  backend = "s3"

  config = {
    bucket = "<base_name>-tfstate"
    key    = "step5/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

module "test" {
  source = "./test"

  base_name = var.base_name
  vpc_id    = data.terraform_remote_state.step5.outputs.vpc-id-1.vpc-id
}
```

データを参照する際、上記例では`data.terraform_remote_state.step5.outputs.vpc-id-1.vpc-id`で指定しています。最後の`vpc-id-1.vpc-id`はstep5のoutput名とvalue名です。以下、step5のoutputです。

```
output "vpc-id-1" {
  value = module.network1.vpc-id
}
```

## 1つのモジュールで複数のリージョンを使う

1モジュールで複数のリージョンへデプロイするには[alias](https://developer.hashicorp.com/terraform/language/providers/configuration#alias-multiple-provider-configurations)を使います。例えば以下のように書けば`us-east-1`と`us-east-2`にデプロイできます。複数リージョンへのデプロイはCloudFront等us-east-1でしかデプロイ出来ないリソースと組み合わせる時に使います。

**versions.tf**

```
terraform {
  required_version = ">= 1.3.7"
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}
```

**main.tf**

```
resource "aws_vpc" "us-east-1" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "us-east-2" {
  provider   = aws.us-east-2
  cidr_block = "10.1.0.0/16"
}
```

## 特定のリース、モジュールだけ操作

モジュール内の特定のリソースあるいはモジュールを指定して操作(plan,apply等)を実行できます。コマンドに[-traget](https://developer.hashicorp.com/terraform/tutorials/cli/resource-targeting)をつければいいです。

``` sh
terraform plan -traget=<リソースタイプ.リソース名>
terraform plan -traget=module.<モジュール名>
```

## リソースの依存関係は自動でやってくれるが明示的にdepends_onさせることもできる

基本的にTerraformは依存関係を自動で推測してデプロイしてくれます。例えば、ステップ2で作成したVPCとサブネットだと、サブネットの値でVPC IDを参照しているため、VPC→サブネットの順番でデプロイしてくれます。しかし、依存関係を明示的に指定したいこともあります。[depends_on](https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on)を使えば明示的な依存関係を設定できます。たとえば以下のように書きます。

```
resource "aws_vpc" "est" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "test" {
  vpc_id     = aws_vpc.test.id

  depends_on = [
    aws_vpc.test
  ]  
}
```

## ignore_changesで変更を無視できる

初期デプロイ以降は変更を無視したい場合もあります。例えば、AutoScallingGroupの希望数はオートスケールによって値が変更されていたります。Terraformコードと実環境の差異を無視したいときは[lifecycle.ignore_changes](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#ignore_changes)を使います。例えば以下のように書くと`cidr_block`の値を変更しても無視されます。

```
resource "aws_vpc" "est" {
  cidr_block = "10.1.0.0/16"

  lifecycle {
    ignore_changes = [
      cidr_block,
    ]
  }  
}
```

## リソースファイルは分けてもいい

本プラクティスでは`main.tf`にリソース定義は書いていましたがmain.tfでなくても構いません。例えば、`vpc.tf`と`subnet.tf`にファイルを分けてもいいです。main.tfがあまりにも長くなる場合はリソースごとにファイルを分けても良いでしょう。

## Terraformのベストプラクティス

色々ありますがGCPのドキュメントが日本語だし情報量も多くて良いかと思います。[Terraform を使用するためのベスト プラクティス](https://cloud.google.com/docs/terraform/best-practices-for-terraform?hl=ja)

## その他便利なterraformコマンド

### fmt

`terraform fmt`でカレントディレクトリのterraformコードを見やすくインデントを修正してくれます。`terraform fmt -recursive`にするとカレントディレクトリ配下も再帰的にfmtしてくれます。

### show

`terraform show`でカレントディレクトリのモジュールでデプロイしたリソース情報を見れます。(outputしていない値も確認できます。)

### validate

`terraform validate`でカレントディレクトリのterraformコードの構文チェックができます。
