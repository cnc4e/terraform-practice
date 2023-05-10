- [ステップ2　基本的なTerraformの書き方・知識](#ステップ2基本的なterraformの書き方知識)
  - [2-1. Terraformの基本的な設定](#2-1-terraformの基本的な設定)
    - [プロバイダーの設定をする](#プロバイダーの設定をする)
    - [Terraformとプロバイダーのバージョン要件を設定する](#terraformとプロバイダーのバージョン要件を設定する)
  - [2-2. コードを書いてリソースをデプロイする](#2-2-コードを書いてリソースをデプロイする)
  - [2-3. リソース間で値を渡す](#2-3-リソース間で値を渡す)
  - [2-4. Variablesで変数にする](#2-4-variablesで変数にする)
  - [2-5. default\_tags](#2-5-default_tags)
  - [2-6. デプロイしたリソースの情報を確認にする](#2-6-デプロイしたリソースの情報を確認にする)
  - [2-7. tfstateについて](#2-7-tfstateについて)
  - [2-8. .terraformについて](#2-8-terraformについて)
  - [2-9. コメントアウトでリソースを削除する](#2-9-コメントアウトでリソースを削除する)
- [後片付け](#後片付け)


# ステップ2　基本的なTerraformの書き方・知識

Terraformを使う上で最低限知っていた方がいいと思うことを記載しています。

`step2`ディレクトリを作成、移動して実施ください。以降のプラクティスはすべて`step2`ディレクトリ内で行う想定です。ファイルはステップ内で同じものを続けて使ったください。

## 2-1. Terraformの基本的な設定

### プロバイダーの設定をする

Terraformはプロバイダーを使ってリソースのデプロイをします。対応したプロバイダーは[こちら](https://registry.terraform.io/browse/providers)にあります。AWSプロバイダーの場合はリソースをデプロイするリージョンを設定できます。設定は[providerブロック](https://developer.hashicorp.com/terraform/language/providers/configuration)に書きます。providerブロックもどこに書いても良いですが、`versions.tf`ファイルに書くのがよいでしょう。

**プラクティス**

- [Provider Configuration](https://developer.hashicorp.com/terraform/language/providers/configuration)を参考に以下内容を`versions.tf`に追加してください。
  - `aws`プロバイダーの設定ブロックで東京リージョン(ap-northeast-1)を指定します（任意の別リージョンでも良いです）

> ヒント: ステップ1の設定をまねてください。

### Terraformとプロバイダーのバージョン要件を設定する

Terraform自体とクラウドプロバイダーのバージョンに要件を設定できます。これは[terraformブロック](https://developer.hashicorp.com/terraform/language/settings)で設定します。例えばTerraformとAWSプロバイダーのバージョンを2023/1時点の最新であるTerraform:1.3.7、AWSプロバイダー:4.49.0以上といった指定ができます。

Terraformおよびクラウドプロバイダーは活発に開発が行われており、バージョン違いで意図した動作をしないことが懸念されます。そのため、terraformブロックで使用するバージョン要件を設定した方がいいです。

terraformブロックはどのファイルに書いてもいいですが`versions.tf`ファイルに書くのがよいでしょう。

**プラクティス**

- [Terraform Settings](https://developer.hashicorp.com/terraform/language/settings)を参考に以下内容の`versions.tf`を作成してください。
  - AWSプロバイダーのバージョンを`4.49.0`以上を要件に指定します。

> ヒント: ステップ1の設定をまねてください。

## 2-2. コードを書いてリソースをデプロイする

Terraformはクラウドプロバイダーを使用してリソースをデプロイします。たとえばAWSの場合、[AWSプロバイダー](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)にTerraformでデプロイできるリソースが載っています。デプロイしたいリソースを[resourceブロック](https://developer.hashicorp.com/terraform/language/resources/syntax)に記述してデプロイします。各リソースには設定可能なパラメーターが数多く用意されています。リソースごとに必須のパラメーターとオプションのパラメーターがあります。指定しなかったオプションパラメーターはデフォルト値でデプロイされます。すべてのパラメーターを記述してもいいですが大変です。明示的にデフォルトから変えたいパラメーターのみ書くのが良いと思います。本プラクティスでは明示的に指定しているパラメーター以外は指定なし（デフォルト値）で良いです。

**プラクティス**

- [Resource: aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)を参考に以下内容の`main.tf`ファイルを作成します。
  - リソースタイプ:aws_vpc リソース名:tf_test
  - CIDRブロック:10.1.0.0/16
  - Name:tf-test、Env:terraform-practice、Owner:自分の名前 のタグを設定
- initしてplanで内容を確認しapplyします。
- マネージメントコンソールまたは以下コマンドでリソースが作成されたことを確認します。

``` sh
$ aws ec2 describe-vpcs --filters "Name=tag-value,Values=tf-test"
```

## 2-3. リソース間で値を渡す

つづいて作成したVPCにサブネットを追加します。サブネットは[Resource: aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)で宣言します。サブネットを作成する際、[vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#vpc_id)の指定が必須です。VPCのIDを自分で確認して入力するのは手間です。Terraformでは作成したリソースの情報（属性）を別リソースから参照できます。VPCの場合、[Resource: aws_vpc の Attributes Reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#attributes-reference)に書かれている属性を別リソースから参照できます。別リソースからは`リソースタイプ.リソース名.属性名`で参照できます。

**プラクティス**

- [Resource: aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)を参考に以下内容を`main.tf`に追加します。
  - リソースタイプ:aws_subnet リソース名:tf_test
  - vpc_id:aws_vpc.tf_testのIDを参照
  - CIDRブロック:10.1.10.0/24
  - Name:tf-test、Env:terraform-practice、Owner:自分の名前 のタグを設定
- planしてapplyします。
- マネージメントコンソールまたは以下コマンドでリソースが作成されたことを確認します。

``` sh
$ aws ec2 describe-subnets --filters "Name=tag-value,Values=tf-test"
```

## 2-4. Variablesで変数にする

値を変数にして外だしすることもできます。後のStepであつかうモジュール化をする場合によく使います。変数化したい値ごとに[variablesブロック](https://developer.hashicorp.com/terraform/language/values/variables)で記述します。variablesブロックもどこに書いてもいいですが、`variables.tf`ファイルにまとめて書くのがよいでしょう。variablesブロックで宣言した変数はリソース内で`var.名前`と指定すれば参照できます。文字列の中に変数を埋め込みたい場合は`${var.名前}`と書くと文字列に変数を入れられます。variabelsブロックには[type](https://developer.hashicorp.com/terraform/language/values/variables#type-constraints)が指定でき値の制限ができます。基本的にtypeは指定するようにしましょう。また、[description](https://developer.hashicorp.com/terraform/language/values/variables#input-variable-documentation)で値の説明を書けます。基本的にdescriptionも記述するようにしましょう。

variablesブロックで宣言した変数に値を設定するには[いくつかの方法](https://developer.hashicorp.com/terraform/language/values/variables#assigning-values-to-root-module-variables)があります。`terraform.tfvars`ファイルに`変数名=値`の形式で指定することが多いと思います。

**プラクティス**

- `variables.tf`ファイルを作成し以下内容のvariablesブロックを記述します。
  - 変数名: subnet_cidr
  - タイプ: 文字列
  - 説明: サブネットのCIDRです
- `terraform.tfvars`ファイルを作成し、subnet_cidrに`10.1.10.0/24`を設定します。
- `main.tf`のaws_subnet.tf_testのcidr_blockを変数`subnet_cidr`から読みこむようにします。
- planします。`No changes.`となり変更がないことを確認します。
- `terraform.tfvars`ファイルのsubnet_cidrに`10.1.20.0/24`に変更します。
- planしてサブネットが`replaced`されることを確認し、applyします。

## 2-5. default_tags

作成したVPCやサブネットにはEnvやOwnerなど、同じタグが設定されています。こういったすべてのリソースに設定したいタグは[default_tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider)で設定すると楽です。default_tagsはproviderブロックで設定します。

**プラクティス**

- `varsions.tf`内のAWSプロバイダー設定にて、Env:terraform-practice、Owner:自分の名前 のデフォルトタグを設定します
- `main.tf`のvpcおよびsubentからEnvとOwnerのタグを消します
- planします。`No changes.`となり変更がないことを確認します

## 2-6. デプロイしたリソースの情報を確認にする

Terraformで作成したリソースの情報(ARNやIDなど)を確認するには[outputブロック](https://developer.hashicorp.com/terraform/language/values/outputs)に記述します。outputブロックもどこに書いてもいいですが、`ouput.tf`ファイルにまとめて書くのがいいでしょう。outputする値の指定はリソースの属性参照と同じく`リソースタイプ.リソース名.属性名`です。また、属性名を省略し`リソースタイプ.リソース名`と指定すると、そのリソースのすべての属性を表示できます。

**プラクティス**

- `output.tf`ファイルを作成し以下内容のoutputブロックを記述します。
  - vpc_id: vpcのid
  - vpc_arn: vpcのarn
  - subnet: subnetのすべて属性
- planしてapplyします。applyしたあとoutputが表示されます。
- `terraform output`するとoutputした値を確認できます。

## 2-7. tfstateについて

Terraformを実行したディレクトリを見ると`terraform.tfstate`と`terraform.tfstate.backup`というファイルがあります。これらのファイルはTerraformがデプロイしたリソースを記録するものです。中身を確認するとJSON形式でデプロイしたリソースの情報が書かれています。このファイルはとても大事です。**絶対に消さないようにしましょう。**もし消してしまった場合、今までデプロイしたリソースはTerraformの管理外となってしまいます。

**プラクティス**

試しに`terraform.tfstate`を消してみます。この操作は学習目的のものです。実運用では絶対にしないでください。

- `terraform.tfstate`を削除します。
- `terraform.tfstate.backup`を別ディレクトリ等に退避します。
- planします。VPCおよびサブネットが`作成`されることを確認します。

planすると作成になりました。つまり、Terraform的には今まで作成したVPCやサブネットはなかったことになっています。このままapplyします。

- applyします。
- マネージメントコンソールまたは以下コマンドでVPCおよびサブネットを確認します。それぞれ2つずつ表示されます。

``` sh
$ aws ec2 describe-vpcs --filters "Name=tag-value,Values=tf-test"
$ aws ec2 describe-subnets --filters "Name=tag-value,Values=tf-test"
```

VPCはCIDRが同じでもデプロイできるためVPCおよびサブネットがもう1セット作成されました。このように、tfstateファイルがなくなると以前のリソースをTerraformで管理できなくなります。そのため、tfstateファイルは絶対なくさないようにします。

また、複数人でTerraformを使って環境を管理する場合、このtfstateファイルを共有した方がよいです。その場合、tfstateファイルを外部のバックエンドに保存して共有します。バックエンドにはS3が使えるため、S3に保管しつつバージョニングを有効にしてtfstateファイルを保護します。さらにtfstateが同時に更新されることを防ぐために排他制御もした方がいいです。これらについては別のステップにてあつかいます。

- `terraform destroy`で新しいリソースを削除します。
- 退避させた`terraform.tfstate.backup`を`terraform.tfstate`として戻します。

## 2-8. .terraformについて

Terraformを実行したディレクトリを見ると隠しディレクトリとして`.terraform`が作成されています。これはterraform initした時に作成されたもので、この中にはプロバイダーを管理するための情報やtfstateのバックエンド情報が格納されています。このディレクトリはそれなりに容量があります。TerraformをGitで共有する場合、この.terraformディレクトリをGitに含めないように`.gitignore`を設定した方がいいです。GitHubやGitLabには.gitignoreのテンプレートでterraformがあり、そのテンプレートを使えば.terraformが除外されるように設定さますので活用しましょう。

**プラクティス**

- ディレクトリ内に`.terraform`があることを確認します。

## 2-9. コメントアウトでリソースを削除する

Terraformで作成したリソースはdestroy以外にも削除する方法があります。リソースをコメントアウトして再度applyするとコメントアウトしたリソースを消すことができます。これだとコメントアウトしたリソースだけ削除できます。destroyだと誤ってすべてのリソースを削除してしまうかもしれないため、複数のリソースが含まれる場合はこの方法の方がいいかもしれません。コメントアウトの仕方はこちらの[Comments](https://developer.hashicorp.com/terraform/language/syntax/configuration#comments)にあります。

**プラクティス**

- `main.tf`内のvpcおよびsubnetをコメントアウトします。
- `output.tf`内のvpcおよびsubnetの出力する部分をコメントアウトします。
- planしてapplyします。リソースが削除されます。

> 今回はvpcとsubentを同時に削除しましたが、subnet部分だけコメントアウトしてapplyするとsubnetだけ削除できます。

# 後片付け

- destoryします。またはmain.tfをすべてコメントアウトしてapplyします。
