# Terraform Practice

Terraform入門者を対象とした練習問題です。練習問題を通じてTerraformの使い方、書き方を学びます。

> **注意**  
> 書き方を学ぶことに重点を置いています。様々なリソースの記述方法を解説したものではありません。

**プラクティス**の後に書かれた部分が問題です。問題文を読み自分で考えてコマンドやコードを書いてください。

Terraform Practiceはいくつかのステップに分けて構成されています。ステップの順番通り進んでいくことを想定していますが各ステップは独立しています。学習したいステップだけ実施しても構いません。各ステップごとにディレクトリを作成し、そのディレクトリ内にファイルを作成してください。ステップ内は続けて実施してください。答えの例はステップ名のディレクトリ配下にあります。

なお、本プラクティスはAWSを前提にしています。

各ステップは以下内容です。

- ステップ1はTerraformを使う準備、基本的なコマンドの使い方です。
- ステップ2は基礎的なTerraformの使い方・知識です。この内容さえ押さえておけば最低限Terraformを使えるようになります。
- ステップ3~5をTerraformさらに高度に使う方法です。ループや分岐、モジュール化です。
- ステップ6はTipsです。読み飛ばしても構いません。
- ステップ7は最終問題です。プラクティスで学んだことを思い出してコード作成に挑戦します。

## 目次

### [ステップ1 Terraformを使う](./step1-inital/README.md)
  - [実行準備](./step1-inital/README.md#実行準備)
    - [Terraform CLIのインストール](./step1-inital/README.md#terraform-cliのインストール)
    - [AWSプロファイルの準備](./step1-inital/README.md#awsプロファイルの準備)
  - [基礎的なterraformの使い方](./step1-inital/README.md#基礎的なterraformの使い方)
### [ステップ2　基本的なTerraformの書き方・知識](./step2-basic/README.md)
  - [2-1. Terraformの基本的な設定](./step2-basic/README.md#2-1-terraformの基本的な設定)
    - [プロバイダーの設定をする](./step2-basic/README.md#プロバイダーの設定をする)
    - [Terraformとプロバイダーのバージョン要件を設定する](./step2-basic/README.md#terraformとプロバイダーのバージョン要件を設定する)
  - [2-2. コードを書いてリソースをデプロイする](./step2-basic/README.md#2-2-コードを書いてリソースをデプロイする)
  - [2-3. リソース間で値を渡す](./step2-basic/README.md#2-3-リソース間で値を渡す)
  - [2-4. Valiablesで変数にする](./step2-basic/README.md#2-4-valiablesで変数にする)
  - [2-5. default\_tags](./step2-basic/README.md#2-5-default_tags)
  - [2-6. デプロイしたリソースの情報を確認にする](./step2-basic/README.md#2-6-デプロイしたリソースの情報を確認にする)
  - [2-7. tfstateについて](./step2-basic/README.md#2-7-tfstateについて)
  - [2-8. .terraformについて](./step2-basic/README.md#2-8-terraformについて)
  - [2-9. コメントアウトでリソースを削除する](./step2-basic/README.md#2-9-コメントアウトでリソースを削除する)
### [ステップ3 繰り返し処理](./step3-loop/README.md)
  - [3-1. countによるリソースの繰り返し](./step3-loop/README.md#3-1-countによるリソースの繰り返し)
  - [3-2. for\_eachによるリソースの繰り返し](./step3-loop/README.md#3-2-for_eachによるリソースの繰り返し)
  - [3-3. dynamicによるブロックの繰り返し](./step3-loop/README.md#3-3-dynamicによるブロックの繰り返し)
  - [3-4. for\_eachで複数の値を指定](./step3-loop/README.md#3-4-for_eachで複数の値を指定)
  - [3-5. 繰り返しで作成したリソースのoutput](./step3-loop/README.md#3-5-繰り返しで作成したリソースのoutput)
### [ステップ4 分岐](./step4-if/README.md)
  - [4-1. 三項演算子によるパラメータの分岐](./step4-if/README.md#4-1-三項演算子によるパラメータの分岐)
  - [4-2. 三項演算子とループによるリソースの分岐](./step4-if/README.md#4-2-三項演算子とループによるリソースの分岐)
    - [ただ分岐させたい場合](./step4-if/README.md#ただ分岐させたい場合)
    - [分岐させてループも回したい場合](./step4-if/README.md#分岐させてループも回したい場合)
### [ステップ5 モジュール化](./step5-module/README.md)
  - [5-1. リソース群をモジュールにする](./step5-module/README.md#5-1-リソース群をモジュールにする)
  - [5-2. モジュールを使いまわして複数デプロイする](./step5-module/README.md#5-2-モジュールを使いまわして複数デプロイする)
  - [5-3. モジュールの値を参照する](./step5-module/README.md#5-3-モジュールの値を参照する)
### [ステップ6 Tips](./step6-tips/README.md)
### [ステップ7 総合問題](./step7-test/README.md)