# ステップ7 総合問題

今まで学んだことの総復習です。前のステップやインターネットを駆使して良いので、以下を満たすTerraformコードを書いてデプロイしてください。

**プラクティス1**

- 子モジュールとして以下2つ作成してください。
  - network
    - [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)を1つ作成します。
      - CIDRは変数で設定します。
    - [サブネット](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)を1つ作成します。
      - VPCのIDは同じモジュールのVPC IDを参照します。
      - CIDRは変数で設定します。
    - 各リソースにはNameタグをつけます。タグの値は`<プロジェクト名>-リソース`にします。(例、tfpractice-vpc)
    - 以下変数を定義します。
      - PJ名
      - VPCのCIDR
      - サブネットのCIDR
    - 作成したVPCとサブネットのIDをアウトプットします。
  - compute
    - [EC2インスタンス](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)を作成します。
      - AMIはAmazonLinux2を使います。リージョンの最新AMI IDを指定してください。
      - インスタンスタイプは変数で設定します。
      - サブネットIDは変数で設定します。
      - セキュリティーグループは同じモジュールのSG IDを参照します。
      - 変数appがforntの場合、ルートブロックデバイスの暗号化をしてください。そうでない場合、暗号化しないでください。
    - [セキュリティーグループ](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)を作成します。
      - 名前は`<プロジェクト名>-<APP名>-ec2-sg`にします。
      - 説明は`<プロジェクト名>-<APP名> ec2 sg`にします。
      - VPC IDは変数で設定します。
      - インバウンドの設定をします。
        - 変数allow-tcp-portsで指定したポート番号の分だけ設定します。
        - プロトコルはtcpを指定します。
        - 指定したCIDRからのインバウンドを許可します。
    - [S3バケット](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)を作成します。
      - 変数appがbackの場合作成します。それ以外の場合、リソースを作成しません。
      - バケット名は`<プロジェクト名>-<APP名>-bucket`にします。
    - 各リソースにはNameタグをつけます。`<プロジェクト名>-<APP名>`にします。(例、tfpractice-front)
    - 以下変数を定義します。
      - PJ名
      - APP名
      - インスタンスのタイプ
      - VPC ID
      - サブネット ID
      - セキュリティーグループでインバウンドを許可するCIDR
      - セキュリティーグループでインバウンドを許可するポート番号のリスト
- ルートモジュール
  - 子モジュールとしてnetworkとcomputeを読み込んでください。
  - networkの変数に値を設定してください。
    - PJ名、VPCのCIDR、サブネットのCIDRは任意の値を設定してください。
  - computeの変数に値を設定してください。
    - VPC IDやサブネットIDはnetworkモジュールの値を参照してください。
    - 変数appにはfrontを設定してください。
    - セキュリティーグループでインバウンドを許可するCIDRは自身の端末のIPアドレスを設定してください。[IPアドレスの確認](https://www.cman.jp/network/support/go_access.cgi)
    - セキュリティーグループでインバウンドを許可するポート番号は80と443を設定してください。

コードが書けたらinitしてplanしてapplyしてください。  
以下リソースが作成されていることを確認してください。

- VPC
  - Nameが指定した通りか確認します。
  - CIDRが指定した通りか確認します。
- サブネット
  - Nameが指定した通りか確認します。
  - CIDRが指定した通りか確認します。
- EC2
  - Nameが指定した通りか確認します。
  - AMIがAmazonlinux2か確認します。
  - 指定したサブネットにあるか確認します。
  - 指定したSGがついているか確認します。
  - ルートボリュームが暗号化されているか確認します。
- セキュリティーグループ
  - Nameが指定した通りか確認します。
  - 指定した宛先からの指定ポートのインバウンドが許可されているか確認します。

以下リソースが作成されていないことを確認してください。

- S3バケット

**プラクティス2**

- ルートモジュールに以下の修正を加えてください。
  - 追加でcomputeのモジュールを読み込みます。
  - networkの変数に値を設定してください。
  - computeの変数に値を設定してください。
    - VPC IDやサブネットIDはnetworkモジュールの値を参照してください。
    - 変数appにはbackを設定してください。
    - セキュリティーグループでインバウンドを許可するCIDRは自身の端末のIPアドレスを設定してください。[IPアドレスの確認](https://www.cman.jp/network/support/go_access.cgi)
    - セキュリティーグループでインバウンドを許可するポート番号は80と443を設定してください。

コードがかけたらinitしてplanしてapplyしてください。  
以下リソースが追加で作成されていることを確認してください。

- EC2
  - Nameが指定した通りか確認します。
  - AMIがAmazonlinux2か確認します。
  - 指定したサブネットにあるか確認します。
  - 指定したSGがついているか確認します。
  - ルートボリュームが暗号化されていないことを確認します。
- セキュリティーグループ
  - Nameが指定した通りか確認します。
  - 指定した宛先からの指定ポートのインバウンドが許可されているか確認します。
- S3バケット
  - Nameが指定した通りか確認します。

# 後片付け

- destoryします。またはmain.tfをすべてコメントアウトしてapplyします。

