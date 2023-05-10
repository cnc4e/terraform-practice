- [ステップ3 繰り返し処理](#ステップ3-繰り返し処理)
  - [3-1. countによるリソースの繰り返し](#3-1-countによるリソースの繰り返し)
  - [3-2. for\_eachによるリソースの繰り返し](#3-2-for_eachによるリソースの繰り返し)
  - [3-3. dynamicによるブロックの繰り返し](#3-3-dynamicによるブロックの繰り返し)
  - [3-4. for\_eachで複数の値を指定](#3-4-for_eachで複数の値を指定)
  - [3-5. 繰り返しで作成したリソースのoutput](#3-5-繰り返しで作成したリソースのoutput)
- [後片付け](#後片付け)


# ステップ3 繰り返し処理

Terraformは基本的に1つのリソースブロックにつき1つのリソースがデプロイされます。しかし、同じ設定のリソースを複数作りたいこともあります。そのような時、ループを使えば記述量を減らせます。Terraformにはいくつかループの書き方があります。

`step3`ディレクトリを作成、移動して実施ください。以降のプラクティスはすべて`step3`ディレクトリ内で行う想定です。`versions.tf`を作成しておいてください。必要に応じて`main.tf`、`varibales.tf`、`output.tf`、`terraform.tfvars`も作成してください。すべてのリソースにはStep=step3のタグを設定します。ファイルはステップ内で同じものを続けて使ってください。

## 3-1. countによるリソースの繰り返し

countは指定した回数だけ繰り返します。使い方は[count](https://developer.hashicorp.com/terraform/language/meta-arguments/count)を参照ください。

**プラクティス**

- 以下の変数を設定します。
  - vpc-cidr: "10.1.0.0/16"
  - subnet-cidrs: ["10.1.10.0/24","10.1.20.0/24"] (リスト型です)
- [vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)を作成します。
  - cidrは変数vpc-cidrで指定します。
- [subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)を作成します。
  - 作成するsubnetの数はリスト変数subnet-cirdsの長さから取得します。リストの長さは[length](https://developer.hashicorp.com/terraform/language/functions/length)関数を使います。
  - subnetは上記作成したvpcに作ります。
  - 各subnetのcidrは変数subnet-cidrsから取得します。
- initしてplanで内容を確認しapplyします。
- マネージメントコンソールまたは以下コマンドでリソースが作成されたことを確認します。

``` sh
$ aws ec2 describe-subnets --filters "Name=tag-value,Values=step3"
```

countの場合、planの結果でもわかる通り各リソースは`リソースタイプ.リソース名[インデック番号]`で作成されます。インデックス番号は0からの連番です。countで注意するのはインデックス番号が変わるとリソースも作り直しになる点です。たとえば、subnet-cidrsを["10.1.20.0/24"]だけにしてplanしてみてください。planしたら値を戻してください。感覚的にはインデックス0のsubnet(10.1.10.0/24)だけ削除してほしいところです。しかし、実際にはインデックス0のリソースが`replaced`になり、インデックス1のリソースが`destroyed`になります。これをapplyするとインデックス0、1のリソースを一度削除し、インデックス0を新しいcidr(10.1.20.0/24)で作り直します。VPCやサブネットなどは一度作ってから途中で消すことはあまりないかもしれませんが、作成するリソースの個数が変わるようなリソースの場合countはやめた方がいいです。なので、ループを書く時は次に解説する`for_each`を使うようにしましょう。

> planした後subnet-cidrsの値を["10.1.10.0/24","10.1.20.0/24"]に戻すのを忘れないでください。

## 3-2. for_eachによるリソースの繰り返し

for_eachもループですがcountとは違い回数指定ではなく、[map/object型](https://developer.hashicorp.com/terraform/language/expressions/types#maps-objects)を指定します。使い方は[for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)を参照ください。

**プラクティス**

- countで書いたリソースブロックをコメントアウトします。
- planしてapplyしてsubnetを削除します。(これをしないと同じCIDRでサブネットを作成しようとしてエラーになる)
- countで書いたループをfor_eachに書き直します。
  - リスト型をmap型にするには[toset](https://developer.hashicorp.com/terraform/language/functions/toset)関数を使います。tosetで変換するとmapのkeyにリストの値が設定されます。
- planしてapplyします。
- マネージメントコンソールまたは以下コマンドでリソースが作成されたことを確認します。

``` sh
$ aws ec2 describe-subnets --filters "Name=tag-value,Values=step3"
```

for_eachの場合、planの結果でもわかる通り各リソースは`リソースタイプ.リソース名[キー名]`で作成されます。countで試したように、subnet-cidrsを"10.1.20.0/24"だけにしてplanしてみてください。planしたら値を戻してください。今度は10.1.10.0/24のサブネットのみ`destroyed`されることが確認できます。このようにfor_eachの場合は順番が変わっても作り直しにならないです。なのでループを書く時は極力`for_each`を使うようにしましょう。

> planした後subnet-cidrsの値を"10.1.10.0/24","10.1.20.0/24"に戻すのを忘れないでください。

## 3-3. dynamicによるブロックの繰り返し

まずはSecurityGroupのリソースを作ります。

**プラクティス1**

- [SecurityGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)を作成します。
  - 名前と説明は適当につけてください。
  - vpcは上記作成したvpcを指定してください。
  - ingressブロックで10.1.10.10/32からのtcp:443を許可するルールを追加してください
  - さらに別のingressブロックを追加し10.1.10.11/32からのtcp:443を許可するルールを追加してください
- 作成するSecurityGroupのidを表示するようにしてください。
- planしてapplyします。
- マネージメントコンソールまたは以下コマンドでリソース・ルールが作成されたことを確認します。
  
``` sh
aws ec2 describe-security-group-rules --filter Name="group-id",Values="<sg id>"
```

さて、上記のSGにさらに3つのingressルールを追加したいとします。3つならingressブロックを手で追加して書けなくもないですが面倒です。そこで[dynamic](https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks)を使います。dynamicを使うとリソール内のブロックに対して繰り返しが使えます。書き方はfor_eachに似ています。

**プラクティス2**

- 以下の変数を追加で設定します。
  - sg-allow-cidrs: ["10.1.10.10/32","10.1.10.11/32","10.1.10.12/32","10.1.10.13/32","10.1.10.14/32"]
- プラクティス1で作成したSecurityGroupを改良します。
  - ingressをsg-allow-cidrsでループさせます。 (contentを忘れないように)
  - 許可するcidrはsg-allow-cidrsを設定します。
- planすると"10.1.10.12/32","10.1.10.13/32","10.1.10.14/32"が追加されることをが確認できます。
- applyします。
- マネージメントコンソールまたは以下コマンドでリソース・ルールが作成されたことを確認します。
  
``` sh
aws ec2 describe-security-group-rules --filter Name="group-id",Values="<sg id>"
```

dynamicは数が多いときにも使えますが、数を動的に変えたときにも使えます。たとえば今回のプラクティスで扱ったインバウンドルールなどは後から追加・削除が起こり得る設定なためdynamicと相性がいいです。

## 3-4. for_eachで複数の値を指定

for_eachはmap/object型をループさせます。そのため、複数の値をセットでループできます。

**プラクティス**

- 以下の変数を追加で設定します。
  - sg-allow-cidrsを削除します。
  - sg-ingress-rulusを以下のように設定します。
```
sg-ingress-rulus = {
    "10.1.10.10/32" = {
        protocol = "TCP"
    }
    "10.1.10.11/32" = {
        protocol = "TCP"
    }
    "10.1.10.12/32" = {
        protocol = "UDP"
    }
    "10.1.10.13/32" = {
        protocol = "UDP"
    }
    "10.1.10.14/32" = {
        protocol = "UDP"
    }
}
```
  - 上記のtypeは以下の通りです。
```
type = map(object({
    protocol = "string"
}))
```
- SecurityGroupを改良します。
  - ingressをsg-ingress-rulusでループさせます。（mapの変数を指定する場合はtosetで変換不要です）
  - 許可するプロトコルはループのvalue.protocolを設定します。
  - 許可するcidrはループのkeyを設定します。
- planすると"10.1.10.12/32","10.1.10.13/32","10.1.10.14/32"のルールが再作成されることを確認できます。
- applyします。
- マネージメントコンソールまたは以下コマンドでリソース・ルールが作成されたことを確認します。
  
``` sh
aws ec2 describe-security-group-rules --filter Name="group-id",Values="<sg id>"
```

今回はkeyをcidr、valueをprotocolにしましたが、keyを適当な文字列にし、cidrをvalueに移してもいいです。また、valueにdescriptionなどを追加するのもいいです。

## 3-5. 繰り返しで作成したリソースのoutput

まずはfor_eachで作成したsubnetをoutputします。

**プラクティス1**

- subnetのリソース情報をすべて表示します。リソースの情報をすべて表示するには`value = <リソースタイプ>.<リソース名>`です。
- planしてapplyします。

以下のようなoutputが得られたはずです。さまざまな情報の中に各サブネットのIDが含まれています。

```
subnets = {
  "10.1.10.0/24" = {
    ...
    "id" = "subnet-031c458bb2c6ed4d3"
    ...
  }
  "10.1.20.0/24" = {
    ...
    "id" = "subnet-00d3d5e31362ff5f7"
    ...
}
```

さて、リソースすべての情報を表示してもいいですが必要な情報のみ、今回だとサブネットのIDだけを表示したいとします。for_eachで作成したリソースのoutputはobject型のため、たとえば`aws_subnet.リソース名[*].id`と指定してもエラーになります。この場合、[for](https://developer.hashicorp.com/terraform/language/expressions/for)を使って元のmapを加工します。

- outputを修正しsubentのidだけを表示するようにします。[ヒント](https://zenn.dev/machamp/articles/a8df5c66ee2eb0#%E4%BD%9C%E6%88%90%E3%81%97%E3%81%9F%E3%83%AA%E3%82%BD%E3%83%BC%E3%82%B9%E3%82%92output%E3%81%97%E3%81%9F%E3%81%84%E6%99%82)

# 後片付け

- destoryします。またはmain.tfをすべてコメントアウトしてapplyします。
