---
title: "Virtuso on GCP: Faster with Container-Optimised OS"
emoji: "🚢"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["Virtuoso", "GCP", "LOD", "SPARQL"]
published: true
---

# 先行事例：

- [Google Cloud Platform の無期限無料枠を利用した Virtuoso の構築方法 - Qiita](https://megalodon.jp/2021-1214-2256-07/https://qiita.com:443/mirkohm/items/30991fec120541888acd)
  - なお[LOD チャレンジ 2020 年度受賞作品（LOD プロモーション賞）](https://2020.lodc.jp/awardSymposium2020Report.html#:~:text=%E3%81%AF%E3%81%98%E3%82%81%E3%82%8B%EF%BC%81%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0%E3%82%BB%E3%83%83%E3%83%88-,%E3%83%86%E3%83%BC%E3%83%9E%E8%B3%9E%EF%BC%9A%20LOD%E3%83%97%E3%83%AD%E3%83%A2%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E8%B3%9E,-%E4%BD%9C%E5%93%81%E5%90%8D)でもある
- [Google Cloud Platform に構築した Virtuoso を無料で SSL 化 - Qiita](https://megalodon.jp/2021-1214-2259-59/https://qiita.com:443/mirkohm/items/95cac0ab26007f8bade4)

https://qiita.com/mirkohm/items/30991fec120541888acd
https://qiita.com/mirkohm/items/95cac0ab26007f8bade4

## 唯一にして最大の欠点

**インストールにメチャクチャ時間がかかる** → `make` を[わざわざ貧弱な計算機にやらせている](https://qiita.com/mirkohm/items/30991fec120541888ac#virtuoso-のインストール)ため

解決策：Virtuoso の Image を使って Docker コンテナとして使えば良い

## 立ち塞がる第二の問題点

データのロードにめちゃくちゃ時間がかかる or 失敗して起動しなくなる → 貧弱な計算機で（ｒｙ

先行事例は確かに有用だが，そのために支払う**時間的コストが大きすぎる**

## そしてもっと手前にある深い溝

多くの人にとっては，GCP は当然として，**そもそもサーバー環境に触れたくない**！ → より少ない手順で/より少ない負担でオリジナルの SPARQL エンドポイントを公開できるようにしたい

# 手順

- ローカル環境に Docker を用意する
- 読み込ませたいデータを任意のディレクトリに配置
- `docker-compose.yml` に対象ディレクトリまでのパスを追加
- コマンド実行してロードさせると，`virtuoso` ディレクトリ以下に `virtuoso.db` が作成される
- これを GCS にアップロード by GSUTIL 等

～～～～～～ローカル作業終わり～～～～～～～～

ドメインを取得する

- gcloud コマンドを使うとワンライナーで終わるのでこれをつかう
- (ここに Gcloud コマンド)

# memo

- Virtuoso のインストール
- 巨大なファイルのロード

GCP 上での作業が必要 → サーバ側には触れたくない

Container-Optimized OS と Docker で頑張る

ローカルで RDF データを読み込んで，処理済みの DB を GCP 上の Virtuso コンテナと同期させる
