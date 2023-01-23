- [ステップ5 モジュール化](#ステップ5-モジュール化)
  - [5-1. リソース群をモジュールにする](#5-1-リソース群をモジュールにする)
  - [5-2. モジュールを使いまわして複数デプロイする](#5-2-モジュールを使いまわして複数デプロイする)
  - [5-3. モジュール間で値を渡す](#5-3-モジュール間で値を渡す)
- [後片付け](#後片付け)


# ステップ5 モジュール化

モジュールはTerraformコードをまとめたものです。

`step4`ディレクトリを作成、移動して実施ください。以降のプラクティスはすべて`step4`ディレクトリ内で行う想定です。`versions.tf`を作成しておいてください。必要に応じて`main.tf`、`varibales.tf`、`output.tf`、`terraform.tfvars`も作成してください。すべてのリソースにはStep=step4のタグを設定します。

## 5-1. リソース群をモジュールにする

[モジュール](https://developer.hashicorp.com/terraform/language/modules)にすると複数のリソース郡をまとめてデプロイできます。Terraformコードをモジュール化する方法は、モジュール化したいコード群を1つのディレクトリにまとめるだけです。モジュールは[moduleブロック](https://developer.hashicorp.com/terraform/language/modules/syntax)を使って呼び出します。呼び出し元をルートモジュール、呼び出されるモジュールを子モジュールと言います。

子モジュールは呼び出されるモジュールであるため、`versions.tf`や`terraform.tfvars`などは不要です。ルートモジュールから値を設定したり、モジュールで作成したリソースの値をルートモジュールに返すには`variables.tf`や`output.tf`が必要です。

**プラクティス**

- `step5`ディレクトリ配下に`network`ディレクトリを作成し、以下のコードを作成してください。
  - [vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)を作成します。
    - cidrは変数で設定します。
  - [subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)を作成します。
    - cidrは変数で設定します。変数はリスト型にし、変数の値の数だけサブネットを作ります。
  - vpcのidとsubentのidをルートモジュールに返します。
- `step5`ディレクトリ配下に以下のコードを作成します。
  - networkモジュールをデプロイ。ソースのパスは相対パス(./network)で指定します。
    - networkに必要な変数を設定します。(値は変数から読み込んでもいいし、直接指定してもいいです。)
  - networkで作成したvpcとsubnetのidを表示します。(モジュールの値はmodule.<モジュール名>.<変数名>です。)
- initしてplanしてapplyします。

## 5-2. モジュールを使いまわして複数デプロイする

モジュール化すると何度も呼び出せます。

**プラクティス**

- `step5`ディレクトリ配下に以下のコードを作成します。
  - 追加でもう1つnetworkモジュールをデプロイします。ソースのパスは相対パス(./network)で指定します。
    - networkに必要な変数を設定します。(値は変数から読み込んでもいいし、直接指定してもいいです。1つ目と値を変えても変えなくてもいいです)
  - 追加のnetworkで作成したvpcとsubnetのidも表示します。

## 5-3. モジュール間で値を渡す

モジュールで作成した値を別モジュールで使うこともできます。なお、ルートモジュールから呼び出す子モジュールを追加する場合、再度initが必要です。

**プラクティス**

- `step5`ディレクトリ配下に`compute`ディレクトリを作成し、以下のコードを作成してください。
  - [ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)を作成します。
    - amiはそのリージョンの最新のAmazonLinux2を指定します。
      - amiのidは変数にして入力してもいいし、dataで引っ張ってきてもいいです。dataで読み込む場合、[こちら](https://aws.amazon.com/jp/blogs/news/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/)にある通り、SSMパラメーターで取得できます。データの取得は[aws_ssm_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter)を使います。
    - インスタンスタイプは変数で指定します。
    - subnetは変数で指定します。
- `step5`ディレクトリ配下に以下のコードを作成します。
  - computeモジュールをデプロイします。
    - インスタンスタイプは`t3.micro`を設定します。
    - サブネットのIDは1つ目のnetworkモジュールで作成した0番目のサブネットIDを指定します。
- initしてplanしてapplyします。

# 後片付け

- destoryします。または、main.tfをすべてコメントアウトしてapplyします。
