# remote-backend

tfstateを格納するリモートバックエンドを構築します。このモジュールでリソースを作成した後、このモジュールのtfstateを以下の手順でリモートバックエンドに格納します。

- ローカルのtfstateをリモートバックエンドにアップロードします。

``` sh
$ aws s3 cp ./terraform.tfstate s3://<base_name>-tfstate/tf-backend/
```

- versions.tfを修正しbackendブロックを追加します。

```
terraform {
  required_version = ">= 1.3.7"

  required_providers {
    aws = {
      version = "= 4.49.0"
      source  = "hashicorp/aws"
    }
  }

　# tf-backendモジュール実行後に以下を追加
  backend "s3" {
    bucket         = "<base_name>-tfstate"
    key            = "tf-backend/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "<base_name>-tfstate-lock"
    region         = "ap-northeast-1"
  }
}
...
```

- ローカルのtfstateを削除します。

``` sh
$ rm terraform.tfstate terraform.tfstate.backup
```

- initしてplanして差分がないことを確認します。

``` sh
$ terraform init
$ terraform plan
```
