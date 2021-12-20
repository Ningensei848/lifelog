---
title: "Virtuso on GCP: Faster with Container-Optimised OS"
emoji: "🚢"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["Virtuoso", "GCP", "LOD", "SPARQL"]
published: true
---

:::message
この記事は [Linked Open Data Challenge 2021 (LOD チャレンジ 2021)](https://2021.lodc.jp/entry.html) の **データ活用部門** にエントリーしています
:::

# はじめに

自前のオープンデータでエンドポイントを建てよう！と考えたときに，**意外と難しいし手間がかかるという問題**があります．これを解決しようと取り組んだのが [林 正洋さん（公共オープンデータ利活用研究室 mirko）](http://www.mirko.jp/) の "[Google Cloud Platform の無期限無料枠を利用した Virtuoso の構築方法 - Qiita](https://megalodon.jp/2021-1214-2256-07/https://qiita.com:443/mirkohm/items/30991fec120541888acd)" でした[^1]．

[^1]: [LOD チャレンジ 2020 年度受賞作品（LOD プロモーション賞）](https://2020.lodc.jp/awardSymposium2020Report.html#:~:text=%E3%81%AF%E3%81%98%E3%82%81%E3%82%8B%EF%BC%81%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0%E3%82%BB%E3%83%83%E3%83%88-,%E3%83%86%E3%83%BC%E3%83%9E%E8%B3%9E%EF%BC%9A%20LOD%E3%83%97%E3%83%AD%E3%83%A2%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E8%B3%9E,-%E4%BD%9C%E5%93%81%E5%90%8D)でもある

https://qiita.com/mirkohm/items/30991fec120541888acd
https://qiita.com/mirkohm/items/95cac0ab26007f8bade4

しかし，このアプローチにはいくつかの欠点があり，そのせいで実際にエンドポイントを建てるまでには高いハードルが存在しているように私は感じました 😢
本記事では，これらを克服し，より簡単に SPARQL エンドポイントを建てられるような方法を紹介します．

# 先行事例の欠点

さて，まず先述したアプローチには二つの欠点と一つの大きな誤りがあります：

欠点：

1. Openlink Virtuoso のインストールに滅茶苦茶な時間がかかる
2. 必要なデータのロードするのに破茶滅茶な時間がかかる

誤り：

- オープンデータを志す人は，当然サーバ関連知識も熟知しているので，**コマンドがたくさん出てきても大丈夫**

:::details 詳細な説明

## 欠点 ①：インストールで時間を浪費しがち

- ただでさえ時間がかかる `make` コマンドを[わざわざ貧弱な計算機にやらせている](https://qiita.com/mirkohm/items/30991fec120541888ac#virtuoso-のインストール)ため，無駄に時間を消費してしまっている

ソースのビルドではなく，既存のイメージをそのまま流用したほうが良いはず　 → 　**Docker を活用**しよう！

## 欠点 ②：データのロードで時間を浪費しがち

- 数 KB 程度のファイル単体ならいざしらず，数 MB のファイルやら複数ファイルをまとめて Bulk load したいと思ったときに，データのロードにめちゃくちゃ時間がかかる or 失敗して起動しなくなる

これもまた，わざわざ貧弱な計算機で（ｒｙ
GCP の Always Free を使いたい場合には，貧弱な計算資源で賄うのも致し方ない……と思ったのもつかの間，**データのロードはローカルでやっておけばよい**ことに気づき，**[GCS](https://cloud.google.com/storage) も活用**することにした．

## 誤り：コマンドがたくさん出てきても大丈夫

そもそも，多くの人にとっては

＿人人人人人人人人人人人人人人＿
＞　サーバ環境に触れたくない　＜
￣ Y^Y^Y^Y^Y^Y^Y^Y^Y^Y ￣

というのが本音であろうと思われる．
よくわからないコマンドが並んでいるだけでも，かなりウッとなるらしい．

せめて**最小限のコマンド**で，しかも**コピペですべて終えられたら嬉しい**と考えた．

:::

![時間が過ぎていることに焦る女性と、飛んでいく時間のイラスト](https://4.bp.blogspot.com/-W3tg5MElxmQ/WzC9on89vDI/AAAAAAABM6c/R_4K4tzlE1U7f9sfPjiG5OY52PzNjfs6QCLcBGAs/s800/jikan_tobu_woman.png =200x)
_*Time flies like an arrow*_

これらの問題は **Docker および GCS[^2] を活用することで解決**できます！

[^2]: [Google Cloud Storage](https://cloud.google.com/storage) のこと（詳細はリンク先を参照）

以下では，その方法について細かく説明します．また，その際に以下の GitHub リポジトリを使用します（ぜひこちらにもスターください笑）

https://github.com/Ningensei848/virtuoso-on-gcp-with-cos

# 動作要件

まず，以下に示すものが必要です：

- [GCP](https://cloud.google.com/gcp) のアカウント
- 以下のコマンドが動作する環境:
  - `docker`: cf. https://docs.docker.com/get-docker
  - `gcloud`: cf. https://cloud.google.com/sdk/docs/install
  - `gsutil`: cf. https://cloud.google.com/storage/docs/gsutil_install

GCP への登録等については[先行事例にも書いてある](https://qiita.com/mirkohm/items/30991fec120541888acd#gcpに登録)のでそちらに譲ります．後者については，利用している OS によってインストール方法が異なるため，**この記事内で具体的な方法には触れません**．それぞれの URL から説明を読んで**各自インストールしてください**（インストールだけであれば，こちらもコマンドをコピペするだけで済むと思われます）．

:::message
`gsutil` については，`gcloud` を標準的な方法でインストールした際に附属しているようです； `docker` → `gcloud`（→ `gsutil`）の順でインストールを試してください
:::

# 概要

はじめに，必要なものを揃えたリポジトリを `git clone` してください：

`git clone https://github.com/Ningensei848/virtuoso-on-gcp-with-cos.git`

https://github.com/Ningensei848/virtuoso-on-gcp-with-cos

このリポジトリを元にすれば，以下の４ステップでやりたいことが実現します：

1. 設定項目を書き換える　 ← 　最重要！！
2. ローカル環境に Virtuoso コンテナを建て，RDF データを読み込ませる
3. _virtuoso.db_ を GCS にアップロードする
4. GCE インスタンスを作成する

設定がうまく機能していれば，作成された GCE インスタンスが自動起動し，あなたが設定したドメインに対して _https_ でアクセスできるようになるでしょう．

# Step 1. 設定項目を書き換える

まず，`.env.example` を開いてください．このファイルには，以降の手順でも使う設定がまとめられています．しかし，このままでは使えません．あなたの環境に置き換えて書き直す必要があります．
また，書き直した後はファイル名を `.env` にリネームしてください

設定を記述するにあたって GCP 側でやらねばならないことがいくつかあります：

- プロジェクトの作成
- 静的外部 IP アドレスの予約
- ドメインの確保
- [DNS](https://www.nic.ad.jp/ja/newsletter/No22/080.html) の設定

::::details 詳細をみる

〈**プロジェクトの作成**〉については，GCP にアカウントを登録した際に，コンソール画面へ移行するときに作成したものを使ってもいいし，新たに作っても構いません．何であれ，GCP 上で動かす汎ゆるサービスは，この「プロジェクト」という括りの中で動作する仕組みになっています（ので，なにをするにも必要な情報です）

〈**静的外部 IP アドレスの予約**〉については，[公式のドキュメントを参照](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address)してください．いままで GCP に触れたことがなければ "静的外部 IP アドレスを予約して、そのアドレスを新しい VM インスタンスに割り当て" というアプローチを取ることになるでしょう

:::message alert
外部 IP を予約すると，その時点で課金が発生します（インスタンス稼働時には $0.004/h，未使用時には $0.010/h ほど）．ただしこれは初年度無料トライアルの枠を圧迫するようなものではありません（一ヶ月あたり３ドルほどになる計算）
:::

〈**ドメインの確保**〉について，[freenom](https://www.freenom.com) を使えばいいという話もありますが，ここは敢えて [Cloud Domains](https://cloud.google.com/domains/docs/overview) を推しておきます．これは，[Google Domains](https://domains.google) として独立していたサービスを，GCP 上でも統合して使えるようにしたものです（ドメイン管理と支払いがラクになった）．

あなただけのドメインを入手したら，次はそのドメイン名をブラウザに入力すると画面遷移（いわゆる名前解決）してくれるように〈**DNS を設定**〉します．これもまたおすすめなのは [Cloud DNS](https://cloud.google.com/dns) です．が，何であれ DNS サーバにドメイン名を入力し，A レコードに予約済み静的 IP アドレスを登録してください．DNS サービスの仕様によってまちまちですが，実際にドメイン解決ができるようになるまでに一日程度待つ必要がある場合もあるようです（なお Cloud DNS なら遅くとも 300 秒程度です）

:::message
すべてを GCP 上で完結できることは，その他の最安値サービスを継ぎ接ぎするコストを補って余りあるメリットがあります
:::

::::

ここまでの情報をもとに，`.env.example` を編集し，**`.env` にリネームしてから保存してください**．

:::details 各種の変数についてもっと知る

必須項目:

- `USERNAME`: ユーザ名
- `USER_EMAIL`: メールアドレス (for letsencrypt)
- `SERVER_NAME`: 取得したドメイン名 (e.g. your-doma.in)
- `GCP_PROJECT_NAME`: GCP のプロジェクト名
- `GCE_*`: インスタンスに関するお好み設定
- `GCS_BUCKET_NAME`: GCS に作成したいバケットの名前

任意項目:

- `Parameters_NumberOfBuffers` & `Parameters_MaxDirtyBuffers`: virtuoso performance tuning
- `TOKEN_LINE`: enable notification cf. https://notify-bot.line.me

:::

# Step 2. ローカル環境に Virtuoso コンテナを建て，RDF データを読み込ませる

※`git clone` してきたリポジトリに `data/` フォルダが含まれていることを確認してください．

1. RDF データを `data/` 以下に好きなように配置する
2. スクリプトを実行し，`isql` プロシージャを得る
3. Virtuoso コンテナを建てる
4. virtuoso にデータを読み込ませて `virtuoso.db` を得る

## Step 2.1. RDF データを `data/` 以下に好きなように配置する

まずは， Virtuoso で読み込みたいデータを `data/` に集めて置いてください．初めは[公開済みデータセットを探してきて試す](https://www.data.go.jp)のが良いでしょう．また，もし自前でデータを作りたい場合には，XML よりも Turtle 形式で記述することをおすすめします．

:::message
現状，Turtle 形式か XML 形式に対応しています（ファイル形式については Virtuoso 側の仕様です）
:::

## Step 2.2. スクリプトを実行し，`isql` プロシージャを得る

次に，スクリプトを実行して `isql` プロシージャを取得します．これは，virtuoso に対してどこにどのデータが有るのか・どのようにデータを読み込めば良いのかを教えてあげるものです．ブラウザ経由でファイルをアップロードする方法もあるにはありますが，こちらは大規模にデータをロードするのには向いていないので紹介するのは控えます．

以下のコマンドをコピペして実行してください：

```shell
source .env
docker run --rm -v $(pwd)/data:/data -v $(pwd)/script:/script -u "$(id -u $USERNAME):$(id -g $USERNAME)" python:3.10-alpine python /script/configureSQL.py ttl --origin https://$SERVER_NAME
```

`source .env` で書き換えた設定項目を読み込み，コマンドラインから呼び出せるようにしています．また `docker run` では，ローカルのディレクトリをボリュームマウントした上で，Python によるスクリプトを実行しています．実行が完了すると，`script/` 以下に _initialLoader.sql_ というファイルが見つかるでしょう．

## Step 2.3. Virtuoso コンテナを建てる

`docker-compose` を利用してコンテナを建てます．もし `docker` をインストールした際に附属していなかった場合には，適宜[インストール](https://docs.docker.com/compose/install/)してください．

以下のコマンドをコピペして実行してください：

```shell
source .env
docker-compose up -d virtuoso
```

次のステップに進む前に，Virtuoso が本当に起動したのか確認しましょう：

```shell
# Check if the virtuoso server is online at port XXXX
docker-compose logs
```

`logs` コマンドを使うことで，立ち上げたコンテナが現在どのような状態になっているのか知ることができます．
以下のように，"Server online at XXXX" （XXXX はポート番号）という表示があれば準備完了です．

> virtuoso_container | HH:MM:SS Server online at $PORT_VIRTUOSO_ISQL (pid 1)

## Step 2.4. virtuoso にデータを読み込ませて `virtuoso.db` を得る

※公式ドキュメント：http://docs.openlinksw.com/virtuoso/rdfperfloading/
http://docs.openlinksw.com/virtuoso/rdfperfloading/

ローカル環境で行なう最後の作業として，RDF データを読み込ませて `virtuoso.db` を得ます．実は，この作業のために先程取得した _initialLoader.sql_ が必要なのでした．

以下のコマンドをコピペして実行してください：

```shell
source .env
nohup docker exec -i virtuoso_container isql $PORT_VIRTUOSO_ISQL -U dba -P $PASSWORD_VIRTUOSO < ./script/initialLoader.sql &
```

:::details このコマンドはなにか
ここで，`nohup $@ &` とは，`$@` に相当するコマンドをバックグラウンドかつ現在の接続状態とは独立して実行させるコマンドです．なぜこのようにするかというと，`$@` に相当する **`docker exec ~` コマンドの実行に結構な時間がかかる**（からバックグラウンドでやりたい）からという理由が一つと，もう一つは **`nohup.out` というファイルに現在の進捗が記録される**からという理由があります．
:::

コマンドが実行された後に，カレントディレクトリに `nohup.out` というファイルが生成されているのが確認できるでしょうか？ virtuoso による**データの読み込みが終わった際には，この `nohup.out` の一番最後に "_initialLoader.sql completed_" という表示が出力**されます．

この文字列が確認できたら，次のステップに進んでください．

# Step 3. _virtuoso.db_ を GCS にアップロードする

:::details GCS とはなにか
[GCS](https://cloud.google.com/storage) (Google Cloud Storage) は，同じく GCP 上のサービスです．GCP における「プロジェクト」，GCE におけるインスタンスのように，GCS には「バケット」という単位があります．このバケットをルートディレクトリとして，ファイルやディレクトリ等のデータを保存することができます．
まだバケットを持っていない場合には，新たに作成します．`gsutil` コマンド経由で作成する場合には以下のようなコマンドを実行します：

```shell
source .env
gsutil mb -p $GCE_PROJECT_NAME gs://$GCS_BUCKET_NAME
```

:::

GCS のバケットに，_virtuoso.db_ をアップロードします．すなわち，ローカルにあるファイルをクラウドストレージ上にコピーします．

```shell
source .env
gsutil cp ./.virtuoso/virtuoso.db gs://$GCS_BUCKET_NAME
```

# Step 4. GCE インスタンスを作成する

最後に，これまで記述・作成したきたものを GCE インスタンス上にデプロイします．以下で実行しているのは `create` コマンドではありますが，引数の中に `startup-script` というメタデータを含んでおり，これによってインスタンスが作成された後に**自動でスクリプトが走り，サーバ上に必要なあれこれを展開してくれる仕組み**になっています．

以下のコマンドをコピペして実行してください：

```shell
source .env
gcloud compute instances create $GCE_CREATE_ARGS
```

:::details $GCE_CREATE_ARGS の中身を知りたい

`.env` を編集する際にチラッと見えたかもしれませんが，**GCE_CREATE_ARGS** の中身は次のようになっています：

```shell
GCE_CREATE_ARGS="$GCE_INSTANCE_NAME \
 --project $GCE_PROJECT_NAME \
 --zone $GCE_ZONE \
 --machine-type $GCE_MACHINE_TYPE \
 --tags $GCE_TAGS \
 --create-disk $GCE_CREATE_DISK \
 --metadata-from-file user-data=$PWD/gcp/cloud-config.yml,NGINX_CONFIG=$PWD/nginx/default.conf.template,DOTENV=$PWD/.env,COMPOSE_FILE=$PWD/docker-compose.yml,startup-script=$PWD/gcp/startup.sh \
 --metadata google-logging-enabled=true,cos-metrics-enabled=true,USERNAME=$USERNAME \
 --address $GCE_STATIC_IP_ADDRESS \
 --shielded-secure-boot \
 --shielded-vtpm \
 --shielded-integrity-monitoring"
```

引数オプションの一つに `metadata-from-file` があるのがわかるでしょうか？ここに与えた変数によってローカルのファイルを GCE 上に「メタデータ」として渡し，`startup-script` に指定されている _gcp/startup.sh_ に記述された処理によってインスタンス内部にコピーしてくる仕組みです．

:::

:::message
インスタンス内部でも `gsutil` コマンドを用いて GCS とのデータ同期を取っている関係上，予約した静的 IP で**外部からアクセスできるまでの時間は `virtuoso.db` のデータ量に依存**しています．この処理だけはデータの大きさによって時間が取られてしまうことがあります，ご了承ください．
:::

:::details Tips: インスタンス起動時のログを見たい

インスタンスを（停止状態から）起動するたびに，`startup.sh` というスクリプトが走っています．この実行ログは，以下のコマンドを実行することで確認することが出来ます．

```shell
source .env
# （ブラウザウィンドウで接続する場合はスキップ）
# 1. インスタンスに ssh 接続する
gcloud compute ssh $GCE_INSTANCE_NAME --zone $GCE_ZONE
# 2. 以下のコマンドをインスタンス上で実行する
sudo journalctl -u google-startup-scripts.service
```

※閲覧状態から抜け出すには，Q キーを押下してください (_quit_ の意)

**インスタンスが本当に起動できているのか？**（あるいは起動できなかった理由は何なのか）を探る際にご活用ください．

:::

![ピンク色の花束の中に、「おめでとう」というメッセージカードが入っているイラスト](https://1.bp.blogspot.com/-QqaAp33KiPI/U3WdFej9oYI/AAAAAAAAgmg/l5XUakAdCXk/s800/bouquet_omedetou.png =100x)
_Congratulations !!_

これにてすべての工程は完了です！！
GCP のプロジェクトページを開き，インスタンスが立ち上がっていることを確認してください 🔍

# まとめ

[先行事例](https://megalodon.jp/2021-1214-2256-07/https://qiita.com:443/mirkohm/items/30991fec120541888acd)のウィーク・ポイントであった「時間的コストが大きすぎる」「サーバよくわからん人には難しい」という問題を，`docker` と GCP の各種コマンドで解決しました．本来必要だった処理は，`script/configureSQL.py` やら `gcp/startup.sh`, `gcp/cloud-config.yml` の中にすべて記述されています．もし自分なりにアレンジしたいという要望があれば，ぜひそちらのファイルも覗いてみてください．
https://github.com/Ningensei848/virtuoso-on-gcp-with-cos
