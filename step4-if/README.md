- [ステップ4 分岐](#ステップ4-分岐)
  - [4-1. 三項演算子によるパラメータの分岐](#4-1-三項演算子によるパラメータの分岐)
  - [4-2. 三項演算子とループによるリソースの分岐](#4-2-三項演算子とループによるリソースの分岐)
    - [ただ分岐させたい場合](#ただ分岐させたい場合)
    - [分岐させてループも回したい場合](#分岐させてループも回したい場合)
- [後片付け](#後片付け)


# ステップ4 分岐

Terraformにif文はありませんが、条件式を使えば似たようなことができます。

`step4`ディレクトリを作成、移動して実施ください。以降のプラクティスはすべて`step4`ディレクトリ内で行う想定です。`versions.tf`を作成しておいてください。必要に応じて`main.tf`、`varibales.tf`、`output.tf`、`terraform.tfvars`も作成してください。すべてのリソースにはStep=step4のタグを設定します。ファイルはステップ内で同じものを続けて使ってください。

## 4-1. 三項演算子によるパラメータの分岐

[Conditional式](https://developer.hashicorp.com/terraform/language/expressions/conditionals)(三項演算子)で条件分岐を書けます。

**プラクティス**

- 以下の変数を設定します。
  - vpc-cidr: "10.1.0.0/16"
  - dev: true (bool型です。) 
- [vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)を作成します。
  - cidrは変数vpc-cidrで指定します。
  - `enable_dns_support`の値を変数devがtrueの場合は`true`を、そうでない場合は`false`を設定するようにします。
  - `enable_dns_hostnames`の値も変数devがtrueの場合は`true`を、そうでない場合は`false`を設定するようにします。
- vpcのidを表示するようにします。
- initしてplanで内容を確認しapplyします。
- マネージメントコンソールまたは以下コマンドでリソースが作成されたことを確認します。

``` sh
$ aws ec2 describe-vpc-attribute --attribute enableDnsSupport --vpc-id <vpc id>
$ aws ec2 describe-vpc-attribute --attribute enableDnsHostnames --vpc-id <vpc id>
```

- 変数devの値をfalseにします。
- planしてapplyします。in placeで値が変更になります。
- マネージメントコンソールまたは以下コマンドでリソースが作成されたことを確認します。

``` sh
$ aws ec2 describe-vpc-attribute --attribute enableDnsSupport --vpc-id <vpc id>
$ aws ec2 describe-vpc-attribute --attribute enableDnsHostnames --vpc-id <vpc id>
```

今回は条件判定に使った変数devをbool型にしましたがstring型などでも判定できます。その場合、[演算子](Arithmetic and Logical Operators)を使います。たとえば変数の値がある文字列と一致するか判定するなら` 変数 == "文字列" `と書きます。

## 4-2. 三項演算子とループによるリソースの分岐

ループ(count/for_each)と組み合わせればリソースレベルでの分岐もできます。

### ただ分岐させたい場合

countの場合、条件に一致する時はcountの値を`1`にし、一致しない場合は`0`を指定します。count=0だとループしないのでリソースが作られません。

for_eachの場合、条件に一致する時は`{ dummy = "dummy" }`等のダミーマップにし、一致しない場合は空のマップ`{}`を指定します。空マップだとループしないのでリソースが作られません。

**プラクティス**

- 以下の変数を追加で設定します。
  - subnet-cidr: "10.1.10.0/24"　(stringです)
- [subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)を作成します。
  - 変数devがtrueの場合はサブネットを作成します。そうでない場合はサブネットを作成しません。(count/for_eachどちらを使ってもいいです)
  - cidrはsubnet-cidrで指定します。
- planしてapplyします。
- マネージメントコンソールまたは以下コマンドでリソースが作成されたことを確認します。

``` sh
$ aws ec2 describe-subnets --filters "Name=tag-value,Values=step4"
```

- 変数devをfalseにします。
- planしてapplyします。VPCの設定も変わりますが、サブネットがdestroyedになればOKです。

### 分岐させてループも回したい場合

countの場合、条件に一致する時はcountの値をリストの長さでループを回し、一致しない場合はcountの値で`0`を指定します。

for_eachの場合、条件に一致する時はmap/objyectでループを回し、一致しない場合は空のマップ`{}`を指定します。ただし、tosetでリストを変換している場合は空マップではなく`toset([])`と指定しないと左右の型が不一致でエラーになります。

**プラクティス**

- 変数subnet-cidrをsubnet-cidrsに変更し、リスト型で ["10.1.10.0/24","10.1.20.0/24"] を設定します。
- [subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)を作成します。
  - 変数devがtrueの場合はサブネットを作成します。サブネットはsubnet-cidrsに設定されている数だけ作成します。変数devがfalseの場合はサブネットを作成しません。(count/for_eachどちらを使ってもいいです)
  - cidrはsubnet-cidrsの値で指定します。
- planしてapplyします。
- マネージメントコンソールまたは以下コマンドでリソースが作成されたことを確認します。

``` sh
$ aws ec2 describe-subnets --filters "Name=tag-value,Values=step4"
```

- 変数devをfalseにします。
- planしてapplyします。VPCの設定も変わりますが、サブネットがdestroyedになればOKです。

# 後片付け

- destoryします。またはmain.tfをすべてコメントアウトしてapplyします。
