---
title: "SPARQLをやっていきたい話＆情報集約をするページ"
emoji: "💫"
type: "idea"
topics: ["memo", "rdf", "sparql"]
published: true
---

# TL;DR

冒頭ちょろっと小話を語ったあと，**SPARQL ってなに？という入門者 ～ RDF/SPARQL 関連の情報を探している経験者までを広く対象**として，日本語ページ中心にメモ的に記事としてまとめた．残念ながらこの領域を専門として研究しているような玄人にとって目新しい情報はない．

いい感じの情報ありましたら，記事最下部の `Discussion` の欄へのひとことをよろしくおねがいします．

# SPARQL をやっていきたい

**きれいなデータを誰でもいつでも何度でもどこからでも使えるようにしたい**，そうすればきっと何かしらいい方向に発展があるかもしれない，そんな気がしている．

:::details read more
データがなきゃあ始まらないという時代，どこもみんながみんなこぞってデータを集めているが，イマイチなにか発展する感じがしない．結局データより何よりマシンパワーと画期的なロジックで駆動していて，すべてをかっさらうのはリソースを持ってる G とか F とか A とか M とかばかり．さらにそもそも集めたデータが汚くて使えない，それをきれいにするのにまた人の手が必要とかいう奴隷労働も蔓延っている有様だ．

SPARQL においては，RDF トリプルストアにおいたデータは基本的に全世界に向けて公開される．どこにいても `URI` でデータの位置が示されているから，そのデータがどのエンドポイント（平たく言えばデータサーバ）に所属しているのかわかれば，そこに SPARQL クエリを投げることで整形されたデータが返ってくる．しかも，クエリの書き方によっては，返答結果をチェインさせて別のエンドポイントのデータとマージさせることもできる．エンドポイントが公開されること，柔軟なクエリを書けることが大きな特徴だと私は思っている．

しかしその「クエリを柔軟に書ける」という恩恵は，一方でどれだけ SPARQL に不慣れな者であっても最初から実行可能なクエリを一から十まできちんと構築することを要求する．RDB の SQL を書くのに苦労した人は少なくないだろうが，SPARQL においてはそれ以上の負担を初学者に強いることとなる．そして悲しいことにこの問題を解決してくれる有効な手段は今のところ存在していない（私の観測範囲においては）．経験者が手ほどきを丁寧にやってくれる環境があればまだしも，独学で手を付けるには心が折れてしまうことだろう．これじゃあいつまで立っても人口は増えていかない………!

解決のために水面下で動いている人もいる．少なくとも私がそうである．どうにか先人たちの知恵を最大限利用しつつ，初学者にも入りやすい・馴染みやすいツール，あるいは段階的に SPARQL を学ぶことのできるツールの作成に取り組んでいる．そうやって今年の春からずっと試行錯誤して，これまでの自分の見てきた SPARQL 関連の情報をまとめたものが本記事である．もちろん今後の継続的に内容の更新を続けていくことだろう．いつか SPARQL が世間一般に普及するときまで……（完）
:::

# FAQ

- SPARQL ってなに？ → [RDF 講習会](https://zenn.dev/ningensei848/articles/94f1bdd1963b762c01c9#sparql-%E3%81%AB%E5%85%A5%E9%96%80%E3%81%97%E3%81%9F%E3%81%84%EF%BC%81)を見るか[本を買う](https://www.amazon.co.jp/%E3%82%AA%E3%83%BC%E3%83%97%E3%83%B3%E3%83%87%E3%83%BC%E3%82%BF%E6%99%82%E4%BB%A3%E3%81%AE%E6%A8%99%E6%BA%96Web-API-SPARQL-NextPublishing-%E5%8A%A0%E8%97%A4-%E6%96%87%E5%BD%A6-ebook/dp/B017LQG9XC)とよい
- SPARQL クエリ用のエディタってある？ → [YASGUI](https://yasgui.triply.cc/) を使おう
- RDF トリプルストア？ → Openlink Virtuoso の OSS エディションを使うのが無難
  - （後から追記予定）
- SPARQL を見せずに GUI をつくりたい
  - 多分 `Metastanza` で『Stanza』をつくり，バックエンドに `SPARQList` と適当な RDF トリプルサーバを用意してやれば良い．自前で入力フォームを用意して，テンプレートエンジンやらフロントエンド JS で仮想 DOM 書き換えとかをやることになりそう．

# 各サービスにおける「sparql」での検索結果

メモとして．最新情報の監視に活用しましょう．

- [「sparql」の検索結果 | Zenn](https://zenn.dev/search?q=sparql)
- [「tag:sparql」の検索結果 - Qiita](https://qiita.com/search?sort=&q=tag%3Asparql)
- [sparql · GitHub Topics](https://github.com/topics/sparql?o=desc&s=stars)
- [Search Topics · sparql](https://github.com/search?q=sparql&type=topics)
- [sparql - Twitter 検索 / Twitter](https://twitter.com/search?q=sparql%20-sparqlew&src=typed_query)

# SPARQL に入門したい !!

## 手を動かすより先ず全体を理解する人向け

和文リソースにおいては，DBCLS:ライフサイエンス統合データベースセンター の方々の情報が正確かつ詳細で網羅的に提供されていると思います．時間に余裕がある方は，[RDF 講習会]()の動画を見ていくことで手軽にわかりやすく学ぶことができるでしょう．

- **RDF 講習会**（~~これ見とけばだいたい全部わかる~~）

<!-- タブが入るとうまくパースできない模様-->

:::details read more

### 開催概要

- [第 1 回 RDF 講習会](http://wiki.lifesciencedb.jp/mw/RDF-Tutorial1)
- [第 2 回 RDF 講習会](http://wiki.lifesciencedb.jp/mw/RDF-Tutorial2)
- [第 3 回 RDF 講習会](http://wiki.lifesciencedb.jp/mw/RDF-Tutorial3)
- [第 4 回 RDF 講習会](http://wiki.lifesciencedb.jp/mw/RDF-Tutorial4)

### Movie

#### 第 1 回

- [LOD の基礎知識 @ 第 1 回 RDF 講習会 ](https://togotv.dbcls.jp/20161008.html)
- [SPARQL を支える技術 @ 第 1 回 RDF 講習会 ](http://togotv.dbcls.jp/ja/20161009.html)
- [RDF によるデータ統合 @ 第 1 回 RDF 講習会 ](https://togotv.dbcls.jp/20161010.html)
- [RDF 開発のためのサービス @ 第 1 回 RDF 講習会 ](https://togotv.dbcls.jp/20161011.html)
- [SPARQL の基本 @ 第 1 回 RDF 講習会 ](https://togotv.dbcls.jp/20161012.html)
- [SPARQL によるアプリケーション開発 @ 第 1 回 RDF 講習会 ](https://togotv.dbcls.jp/20161014.html)

### 第 2 回

- [RDF 入門 @ 第 2 回 RDF 講習会 ](https://togotv.dbcls.jp/20180102.html)
- [SPARQL 入門 @ 第 2 回 RDF 講習会 ](https://togotv.dbcls.jp/20180103.html)
- [TogoDB を利用した、データの RDF 化@ 第 2 回 RDF 講習会 ](https://togotv.dbcls.jp/20180104.html)
- [D2RQ Mapper を利用した、データの RDF 化 @ 第 2 回 RDF 講習会 ](https://togotv.dbcls.jp/20180105.html)
- [RDF 形式で利用できる、生命科学 RDF データの紹介 @ 第 2 回 RDF 講習会 ](https://togotv.dbcls.jp/20180106.html)
- [RDF 化した自分のデータと、既存の生命科学 RDF データを統合して利用する方法 @ 第 2 回 RDF 講習会 ](https://togotv.dbcls.jp/20180107.html)

### 第 3 回

- [RDF 入門 @ 第 3 回 RDF 講習会 ](https://togotv.dbcls.jp/20181101.html)
- [SPARQL 入門 @ 第 3 回 RDF 講習会 ](https://togotv.dbcls.jp/20181102.html)
- [TogoDB を利用した、データの RDF 化@ 第 3 回 RDF 講習会 ](https://togotv.dbcls.jp/20181103.html)
- [D2RQ Mapper を利用した、データの RDF 化 @ 第 3 回 RDF 講習会 ](https://togotv.dbcls.jp/20181104.html)
- [RDF 形式で利用できる、生命科学 RDF データの紹介 @ 第 3 回 RDF 講習会 ](https://togotv.dbcls.jp/20181105.html)
- [RDF 化した自分のデータと、既存の生命科学 RDF データを統合して利用する方法 @ 第 3 回 RDF 講習会 ](https://togotv.dbcls.jp/20181106.html)

### 第 4 回

- [Semantic Web と RDF @ 第 4 回 RDF 講習会 ](https://togotv.dbcls.jp/20191209.html)
- [RDF 作成のデザインパターン・オントロジー作成の方法 @ 第 4 回 RDF 講習会 ](https://togotv.dbcls.jp/20191210.html)
- [SPARQL クエリの基本 @ 第 4 回 RDF 講習会 ](https://togotv.dbcls.jp/20191211.html)
- [Virtuoso のインストール、利用方法・RDF/SPARQL のアプリケーション開発 @ 第 4 回 RDF 講習会 ](https://togotv.dbcls.jp/20191212.html)

:::

- [オープンデータ時代の標準 Web API SPARQL (NextPublishing) | 加藤 文彦, 川島 秀一, 岡別府 陽子, 山本 泰智, 片山 俊明 | 工学 | Kindle ストア | Amazon](https://www.amazon.co.jp/%E3%82%AA%E3%83%BC%E3%83%97%E3%83%B3%E3%83%87%E3%83%BC%E3%82%BF%E6%99%82%E4%BB%A3%E3%81%AE%E6%A8%99%E6%BA%96Web-API-SPARQL-NextPublishing-%E5%8A%A0%E8%97%A4-%E6%96%87%E5%BD%A6-ebook/dp/B017LQG9XC)
- [知識グラフ，セマンティックウェブを構成する RDF と問い合わせ言語 SPARQL - 情報の科学と技術| J-STAGE](https://www.jstage.jst.go.jp/article/jkg/70/8/70_392/_article/-char/ja/)
- [RDF と SPARQL による多様なデータの活用 - 情報の科学と技術| J-STAGE](https://www.jstage.jst.go.jp/article/jkg/70/8/70_399/_article/-char/ja/)

## 実例を見つつ実際に手を動かしてみる人向け

※クエリを実行する際には，SPARQL クライアントが必要です．
（筆者のおすすめは [YASGUI](https://yasgui.triply.cc/) です）

- [直感 RDF!!シリーズ（2013 年の記事）](http://maoring.hatenablog.com/entry/2013/11/29/001031)

:::details more info

- [直感 RDF!!　その１-RDF とは。 - Qiita](https://qiita.com/maoringo/items/4742b5cd01c9e698260d)
- [直感 RDF!!　その 2 -使いやすい RDF を作って，検索しよう。 - Qiita](https://qiita.com/maoringo/items/0d48a3d967a35581cc24)
- [直感 RDF!!　その 3 -外部のデータと繋げて使える検索をしよう。 - Qiita](https://qiita.com/maoringo/items/f9a5b33b36beaa6b427b)

:::

- [ウィキデータ:SPARQL チュートリアル - Wikidata](https://www.wikidata.org/wiki/Wikidata:SPARQL_tutorial/ja) （※英語を含むがもっとも体系的で丁寧）

:::details more info

- [Wikidata:SPARQL query service/queries/examples/ja - Wikidata](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/queries/examples/ja)

:::

- [合同会社 緑ＩＴ事務所](https://midoriit.com/) さん の入門記事

:::details more info

- [データビジュアライゼーション - 合同会社 緑ＩＴ事務所](https://midoriit.com/2014/03/%e3%83%87%e3%83%bc%e3%82%bf%e3%83%93%e3%82%b8%e3%83%a5%e3%82%a2%e3%83%a9%e3%82%a4%e3%82%bc%e3%83%bc%e3%82%b7%e3%83%a7%e3%83%b31.html)
- [LOD と SPARQL 入門 - 合同会社 緑ＩＴ事務所](https://midoriit.com/2014/03/lod%e3%81%a8sparql%e5%85%a5%e9%96%801.html)
- [ウィキデータの調査 - 合同会社 緑ＩＴ事務所](https://midoriit.com/2017/09/%e3%82%a6%e3%82%a3%e3%82%ad%e3%83%87%e3%83%bc%e3%82%bf%e3%81%ae%e8%aa%bf%e6%9f%bb.html)

:::

# SPARQL をやっている人々，組織，その関連情報ほか

- [croMisaP (@croMisa)](https://twitter.com/croMisa) さん

:::details more info

- [im@sparql](https://sparql.crssnky.xyz/imas/)

:::

- [LOD ハッカソン関西](http://wp.lodosaka.jp/) さん

:::details more info

- [LOD ハッカソン関西とは | Linked Open Data ハッカソン関西](http://wp.lodosaka.jp/about/)
- [SPARQL クエリ集 | Linked Open Data ハッカソン関西](http://wp.lodosaka.jp/tool/sparqlquery/)
- [SPARQL でオープンデータ検索!: LOD ハッカソン関西](https://techbookfest.org/product/5642815304368128?productVariantID=5389336753209344)

:::

- [uedayou さん (@uedayou)](https://twitter.com/uedayou) さん

:::details more info

- [@uedayou が作成にかかわったものを紹介するページ](http://uedayou.net/)
- [利用可能な SPARQL エンドポイントリスト(2020 年 8 月版) - Qiita](https://qiita.com/uedayou/items/9e4c6029a2cb6b76de9f)

:::

- [ばびぶべぼん (@bbbbbo_n)](https://twitter.com/bbbbbo_n) さん

:::details more info

- [ばびぶべぼ研究室 - babibubebo.org](https://babibubebo.org/lab/)
  - [SPARQL 50 本ノック: ばびぶべぼ研究室](https://techbookfest.org/product/5789247489441792?productVariantID=6553018430390272)
- [Metadata.Moe](https://metadata.moe/) - [とある SPARQL - 『とあるシリーズ』好きのための SPARQL エンドポイント](https://metadata.moe/toaru-sparql/) - [メディア芸術データベース LOD - Metadata.Moe](https://metadata.moe/madb-lod/)

:::

- [frogcat (Yuzo Matsuzawa)](https://github.com/frogcat) さん

:::details more info

- [frogcat さんの投稿記事一覧 - Qiita](https://github.com/frogcat) - [SPARQL 1.1 Property Paths の紹介 - Qiita](https://qiita.com/frogcat/items/c4b398e50bfc7479cea6) - [curl で SPARQL - Qiita](https://qiita.com/frogcat/items/9150dd3fe8ce3a9e79c5) - [SPARQL で一番長い法人名を調べてみる - Qiita](https://qiita.com/frogcat/items/4903125a4e0efed6b919) - [SPARQL Endpoint に AJAX でアクセスする方法 - Qiita](https://qiita.com/frogcat/items/beb8888bb334699e21ed)

:::

- [神崎 正英](https://twitter.com/_masaka) さん

:::details more info

- [The Web KANZAKI - 作者（神崎正英|masaka）について](https://www.kanzaki.com/info/who) - [Masahide Kanzaki (0000-0003-2953-7963) - ORCID | Connecting Research and Researchers](https://orcid.org/0000-0003-2953-7963)

:::

- [gBizINFO （METI）経済産業省](https://info.gbiz.go.jp/about/index.html)

:::details more info

- [API 利用方法 | gBizINFO](https://info.gbiz.go.jp/api/index.html)
- [詳細検索](https://info.gbiz.go.jp/hojin/AdvancedSearchTop) - 実は裏側で `SPARQL` クエリが走っているっぽいのだが，`jQuery` わからんマンなのでどういう仕組みなのかわからず……少なくとも `yasqe` + `Fuseki` の構成であるっぽいことはデベロッパーツールで見つけてきた `https://info.gbiz.go.jp/hojin/common/js/Meti.sparql.js` でわかった - （そもそもこういう実装の方法を共有してほしいものである）

:::

- [DBCLS ｜ ライフサイエンス統合データベースセンター](https://dbcls.rois.ac.jp/)

:::details more info

- [提供されているサービスの一覧](https://dbcls.rois.ac.jp/services.html)
  - [d3sparql.js](https://dbcls.rois.ac.jp/services.html#d3sparql.js)
  - [SPARQList](https://dbcls.rois.ac.jp/services.html#SPARQList)
  - [SPARQL_support](https://dbcls.rois.ac.jp/services.html#SPARQL_support)
    - などなど
- [Members ｜ DBCLS](https://dbcls.rois.ac.jp/members.html) - [片山 俊明 KATAYAMA, Toshiaki, PhD](https://github.com/ktym) - [川島 秀一 KAWASHIMA, Shuichi, PhD](https://github.com/skwsm) - [守屋 勇樹 MORIYA, Yuki, PhD](https://github.com/moriya-dbcls) - [山本 泰智 YAMAMOTO, Yasunori, PhD](https://github.com/yayamamo)

:::

# 各種イベント

- [SPARQLthon](http://wiki.lifesciencedb.jp/mw/SPARQLthon)
  - 気軽に参加すると DBCLS の中の人達と直接お話することが出来ます．
  - 身内の定期連絡回の側面は小さくないので，それなりに知識を身に着けてから応用的なことを聞いてみたいときに参加するといい気がします．
- [国内版バイオハッカソン](http://wiki.lifesciencedb.jp/mw/%E5%9B%BD%E5%86%85%E7%89%88BH)
- [LOD チャレンジ - Linked Open Data Challenge](https://twitter.com/LodJapan)

# d3sparql.js

:::details read more

- [d3sparql.js - JavaScript による SPARQL 検索結果の可視化ライブラリ Toshiaki Katayama | SlideShare](https://www.slideshare.net/ToshiakiKatayama/d3sparqljs)
- [d3sparql.js を使ってみた - Qiita](https://qiita.com/fumi1/items/b446848543ff21fed1b2)

:::

# JSON Format で 検索結果を受け取りたい時の型定義

~~"[SPARQL 1.1 Query Results JSON Format | W3C Recommendation 21 March 2013](http://www.asahi-net.or.jp/~ax2s-kmtn/internet/rdf/REC-sparql11-results-json-20130321.html)" に準拠したものを自作してみた．ご参考まで．~~

[SPARQL のための型安全なバリデータをつくった](https://zenn.dev/ningensei848/articles/validator_for_sparql_query_result_json) のでこちらを参照のこと: TypeScript を主体として書いているが，Python / Ruby / Java / Go / C# / Rust でも使えるので何卒

# 未分類.zip

:::details read more

- [Rust 製の SPARQL サーバー Oxigraph を JSON-LD で触る ⋅ Plume](https://bit.ly/2SUiqUE) - [oxigraph/oxigraph: SPARQL graph database | Github](https://github.com/oxigraph/oxigraph)

:::

# 検索用シソーラス（仮）

- `LOD`
- `RDF`
- `SPARQL`
