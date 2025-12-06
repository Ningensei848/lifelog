---
title: "Obsidianをチームで使えるようにしたいin閉域環境なJTC"
emoji: "⛎"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["obsidian", "git", "Windows", "smb", "JTC"]
published: true
---

## Tl; DR

1. Obsidian Vault の一部を共有用サブモジュールとして切り出し、チーム全員から参照できるように
2. 接続点は共有フォルダ（SMB サーバ）のみ
3. いわゆる閉域環境（インターネットに繋がらない；イントラネット）で頑張ってる

## はじめに

本記事は [Obsidian Advent Calendar 2025](https://adventar.org/calendars/11440) における６日目の記事です（遅刻気味）

- 前日の記事は[六](https://kinkamome.hatenablog.com/about)さんの「[Obsidian の仕事での使い方（2025） - 0 番線デルタ](https://kinkamome.hatenablog.com/entry/2025/12/05/obsidian-advent-calendar-2025)」でした
- 明日の記事は[相戸ゆづな](https://lit.link/aidoyuzuna)さんの"「Obsidian Publish はとっても楽しいよ」的なやつ"です

いずれも仕事や趣味やらで活用していてすごい！
こういう知的生産術に漠然と憧れていて、そうこうしているうちに出会ったのが Obsidian だったなぁとか思い出していました

### 祝！仕事でも Obsidian が使えるよ～（2025 年 2 月）

さて弊職場においては、IT 系（自称）ということもありナレッジベース的なものが欲しいという話がずっと出ていました
されどここは国内でも有数の JTC……インストーラを一つ実行するにしてもアラートが上がり最悪の場合は停職や免職まで視野に入る厳しさです

でもそれは職場から与えられた端末を利用する場合の話で、個人の私有 PC でやる分にはなんの問題もないわけです（専従義務違反？）
当初、Obsidian は個人で使う範囲においては特段ライセンス等も必要なく、「（テレワークの際に私的空間において）勉強している」というテイで回避していました

しかし！[２０２５年２月に突然のライセンス無償化が通知](https://obsidian.md/blog/free-for-work/)され、業務でも堂々と使えるようになりました[^1]
こりゃあ、いかに閉鎖的な JTC たる我々としてもぜひ採用したいなぁ～と考えるに至ります

[^1]: [人気の Markdown ノートアプリ「Obsidian」が商用でも無償に - 窓の杜](https://forest.watch.impress.co.jp/docs/news/1664692.html)

そこから半年ほど経ち、紆余曲折あり、様々な申請を通過した後、ついに社内 PC で Obsidian が使えるようになりました～！
なんと！どさくさ紛れで申請していた Git + VSCode もついでに利用可能となり、嬉し～といった感じです

（改めて客観的に見ると、ソフトウェアのインストール程度でこんなに苦労してる弊職場ってホンマに。。。）

### 仕事で使いたい、それもチームで

「いよいよ Obsidian が使えるようになったのはいいものの、書き出すことがそこまであるかといえば、実はそこまでないのかも……？」

JTC あるあるだと思いたいんですが、文書至上主義というかやりとりはすべてメールか、MS Office 製品（word/excel/ppt）、そして万能たる PDF しか扱いません
それ以外の些末なメモ等はすべて付箋や紙ノートを物理媒体として手元に用意し、もっぱらボールペンで書き取るばかりです
本音を言えば、職場全体とか部署単位とかで Wiki 的なものを置いて、そこに個々人でガンガン出力していくのが理想的なのですが、上述したように規則ガチガチなので独立サーバ設置するのに面倒な手続きが多すぎる上にそもそも許可してくれない可能性もあるし、さらに予算はどうするの？とかもあり。。。

閑話休題、つまるところ ① 一人で使うにはもったいないし ② みんなでつかえるようにしたら Wiki っぽくなって便利 ということを Obsidian でやれないかな～と考えたわけです
そして就業時間後にウンウンと頑張ること２ヶ月弱、ようやくなんとなく形が見えたので、ここで紹介させていただく次第です

## つくったものの紹介 (WIP)

https://github.com/Ningensei848/Knewrova

インターネットもロクに繋げない（堅牢なイントラネット環境下であるため）ところから、どうにか持ち出して参りました
徐々に年末進行となりゆるっと帰宅できるようになりつつあるので、そのスキマ時間を活用し年内にはパブリックインターネットでも使いやすい仕様に直したいですね～
（前提として、弊職場という環境的特性に対抗できるように強烈な縛りが掛かっているのですが、そうじゃない環境に置かれましてはとっても柔軟に運用ができるものと思料）

### 使い方

**これ(Knewrova)をフォークしたものを「チームのリポジトリ」として使い、その大半を `sparse-checkout` することで「個人のリポジトリ」として切り出し、そこからさらにチームに還元したいフォルダを切って「サブモジュールとして分離」して管理する**

一言で述べるとこんな感じなんですが、Git に詳しかったとしても初見では意味不明かつ意図不鮮明かと思いますので、解説していきます

### 0. 全体のアーキテクチャ

おおきく３種類のリポジトリがあります

1. チームのリポジトリ（仮称：`Nexus` リポジトリ）
2. 個人のリポジトリ（仮称：`UsersVault` リポジトリ）
3. ↑ のうち、チームに還元したいフォルダ（をサブモジュールとして切り出したリポジトリ）

なんでこんな複雑なことを……Git サーバさえあればそこに集約するだけでいいじゃん……（それはそう）
とはいうものの、新規にサーバを建てられないという縛りの元では、既存のサーバ、それも共有フォルダを動かす SMB サーバ上に Git リポジトリを置いて擬似的に運用するしか手はなかったのです……

縛りなくナイーヴに考えれば、集約用のチームのリポジトリを用意し、そのサブモジュールとして各個人の Vault をリポジトリにすれば済む話かもしれません
しかし、その場合は「工夫しなければ全公開かつ全共有」だし「Vault のリンクが作りづらい」といった問題がありました
また、これは SMB で Git リポジトリを運用する際の課題ですが、複数同時 Push に脆弱という性質も挙げられます
（監査が入っているせいもあるが、I/O が増えるととてもつらくなる）

よって、衝突競合を避けるためにも「共有フォルダへの Push 回数を最小化、ないしゼロにする」ことが仕様の大きな柱となっています

:::details 余談：弊職場(JTC)で使う上での制約事項
余談：弊職場(JTC)で使う上での制約事項
弊職場においては、以下のような縛りがありました

1. SMB
2. 閉域環境
3. AV/EDR
4. 規則等

イントラネットかつ監視付き共有フォルダ、加えて規則でもガチガチなのでおとなしく Office 系でも使っとけと言わんばかりの環境ですね～ｸｿが
こんなんでもそれなりにデカい図体維持して生き延びていけるわけですから、取引先というか、すべての人々に感謝して生きねばなりません、ありがとう～！
:::

そして、この構成にしたことで得られるメリットも副次的に生まれました

- 共有フォルダ(SMB)の権限管理(AD)に相乗りできる
- すべてのリソースがローカルに置かれるので通信は最小限かつスタンドアロンでも活用可能
- 全員が同じ構造の絶対パスでリンクする運用にすれば、各人の共有用 Vault をそのままマージできる
- 別の部署にいっても文書は残るし、持ち運べる
- そのまま Copilot に食わせて Agent 化する未来も視野に入る

……あれ、意外とスジがいい気がしてきましたね笑

### 1. チームのリポジトリ

```
.
├── .obsidian                 # submodule
├── .script
│   └── __DoNotTouch
│       └── hooks
├── MyWork
│   ├── Daily
│   └── Misc
├── Shared
│   ├── Project
│   │   └── <ProjectName>
│   │       ├── {{USER_ID}}
│   │       └── Ningensei848  # submodule
│   └── User
│       ├── {{USER_ID}}
│       └── Ningensei848      # submodule
├── __Attachment
├── __Document
└── __Template
```

`.obsidian` および `Shared/User`, `Shared/Project/<ProjectName>` 配下のユーザごとのリポジトリをサブモジュールとしています
前者は当然、チームとして設定やプラグイン等の統一のために、各環境への再配布を簡易にする機能として存在しています
後者のうち、`User` の方はチーム全員参加、`Project` の方はそれぞれの `ProjectName` ごとに参集人員を区別できるようにしたものです

いずれにしても `git submodule add <repo-path> <directory>` のように追加します

---

重要なのは、**チームの一般メンバーは基本的にこのチームのリポジトリに触ることはない**ということです
あくまで Git や Obsidian その他、開発周りに詳しい管理者的な人だけが触るものであり、他のメンバーはもっぱらこれを `sparse-checkout` した個人のリポジトリにだけ触れるようにしています
全員が全員 Git を使いこなすベテラン開発者であればこんな workaround は必要ないのかもしれません
しかし、初心者や全く関係ない総務系の人員にも使ってもらえるようにすることを考えると、うかつにマスタ的なリポジトリは触れさせたくありませんのでェ゙～～致し方なし！

### 2. 個人のリポジトリ

`sparse-checkout` ってなに？`fork` じゃないの？

と思うかもしれませんが、これは文字通り「薄く」チェックアウトするものです[^2]
親リポジトリをそのまま `fork` すると、それはすべて個人のリポジトリに受け継がれてしまいますが、`sparse-checkout` すると、継承する内容を選択的に得られます

[^2]: [Git - git-sparse-checkout Documentation](https://git-scm.com/docs/git-sparse-checkout)

より詳しく言えば、普段からチームのリポジトリを `upstream` として登録し、日々更新をマージするという運用を行なうことになります

前項で個人のリポジトリとして切り出したのは workaround といいましたが、もしそうしなかった場合、チームのリポジトリに対して Push が集中し、結局は競合が避けられずスケールしないということにも陥りかねません
普段の Push リクエストの分散機構として、個人のリポジトリとして分割したと言えるのかな～と思いました

---

そうして日々ノートを書いていると、やがて他のメンバーにも共有したい情報とかも増えてくることでしょう
これらを `MyWork` から `Shared` に移すことで、他の人からも参照できるようになります

### 3. サブモジュール

`Shared/User/` 配下に、`git submodule add <repo-path> <name>` することで、`Shared/User/<name>`をサブモジュールとして管理できるようになります
既存の Vault をそのまま追加するのもできるでしょうが、個人のリポジトリが新たな ROOT になることでパス構造に支障をきたす可能性が高いです
よって、空のリポジトリを作成してサブモジュールとして登録し、そこに新たにノートを追加していくことになります
（履歴の合流とかできればいいんだけど、それをやるのはあまりに Git の猛者じゃあないとわからん気がする）

個人のリポジトリの管理範囲内に置かれるので、普段もその人の責任でサブモジュールを更新・管理していきます
チームのメンバーは、① 各人が持つ個人のリポジトリ ＋ ② その中に自分が作成したサブモジュール という２つのリポジトリを管理することになるわけですね

---

上述したのはあくまで自分が管理する範囲に関してのことがらにすぎません
`Shared/User/<name>` からも分かる通り、`<name>` を複数並べることが可能です
つまり、複数のユーザが書いたサブモジュールを、一つのリポジトリの中に共存させることができるようになります、嬉し～～～～～～！！！

`git submodule update --remote --recursive` と実行することで、親リポジトリに登録サブモジュール情報をそれぞれの最新コミットに参照を移し、ワークツリーも更新します
ローカルのサブモジュールに自分で特段の変更を加えていなければ、履歴はただ前に進むだけなのでコンフリクトも生じません
（というより、自分以外が所掌するサブモジュールに変更加えると競合が爆増するので、運用ルール上それを禁止しておく）
（なお、`<name>` と例示しましたが、上記を踏まえて責任範囲を明確にするためにも、`<username>` とか `<user_id>` とかにするのがよいかもしれません）

こうして、SMB による共有フォルダ上に設置した Git リポジトリに対するファイル競合問題を回避した設計の Obsidian チーム活用のためのリポジトリ群が完成しました！いぇ～い

## 進行中なこと

？「いやいや、これでは単に設計思想を公開しただけですよね？そしておそらくじゃ全然言及していない問題がたくさん隠れてそうだし……」

まさにご指摘通りで、実はまだ全然表に出せるレベルにはなっていません…少なくとも GitHub 前提のエコシステムには作り変えられていない……
具体的には、以下の部分で至らぬ点があります

- 「運用でカバー」をどうにかスクリプト側でガードレールする制御機構
- hook 等の ps1 から sh への移植
- 諸々突貫工事でつくったもののリファクタリング
- ドキュメント整備

うわぁ、たいへんなことになっちゃったぞ

※以下に memo を置いておきます、こんな感じで導入進めていくとよい（ドキュメント未更新）

:::details 実際の導入手順とサンプル例示
工夫点として、技術に疎い人にもポチポチで使ってもらえるように、Git の煩わしい操作はすべて `pre-commit` hook に委ねて隠蔽している

```
1085  git clone --no-checkout --single-branch git@github.com:Ningensei848/Knewrova.git Ningensei848
1086  code .
1087  cd Ningensei848
1088  git sparse-checkout init --cone
1089  git sparse-checkout set .obsidian/ .vscode/ .script/ MyWork/ Shared/Project/ Shared/User/ __Attachment/ __Document/ __Template/
1090  git checkout main
git remote rename origin upstream
git remote set-url --push upstream DISABLED
git remote add origin git@github.com:Ningensei848/L45EN.git
```

```
git remote -v
origin  git@github.com:Ningensei848/L45EN.git (fetch)
origin  git@github.com:Ningensei848/L45EN.git (push)
upstream        git@github.com:Ningensei848/Knewrova.git (fetch)
upstream        DISABLED (push)
```

```
# サブモジュールの追加（登録）
# -- git submodule add <リポジトリURL> <パス>
1112  git submodule add git@github.com:Ningensei848/.obsidian.git
1114  git submodule add git@github.com:Ningensei848/Ningensei848.git Shared/User/Ningensei848

# サブモジュールの初期化
git submodule init
git submodule update
git add .gitmodules .obsidian Ningensei848
git commit -m "Add: submodules"
```

`.gitmodules` の編集と設定更新は以下の通り

```ini
[submodule ".obsidian"]
	path = .obsidian
	url = git@github.com:Ningensei848/.obsidian.git
    branch = main    # 追記
    update = rebase  # 追記
    ignore = none    # 追記
[submodule "Shared/User/Ningensei848"]
	path = Shared/User/Ningensei848
	url = git@github.com:Ningensei848/Ningensei848.git
    branch = main    # 追記
    update = rebase  # 追記
    ignore = none    # 追記
```

```shell
git config -f .gitmodules submodule.".obsidian".branch main
git config -f .gitmodules submodule.".obsidian".update rebase
git config -f .gitmodules submodule.".obsidian".ignore none

git config -f .gitmodules submodule."Shared/User/Ningensei848".branch main
git config -f .gitmodules submodule."Shared/User/Ningensei848".update rebase
git config -f .gitmodules submodule."Shared/User/Ningensei848".ignore none

git submodule sync --recursive
```

```
git add .gitmodules
git commit -m "Update: params of .gitmodules"
```

※**clone 時には `--recursive` オプションを忘れない！**

```
git clone --recursive git@github.com:Ningensei848/L45EN.git
Cloning into 'L45EN'...
remote: Enumerating objects: 68, done.
remote: Counting objects: 100% (68/68), done.
remote: Compressing objects: 100% (59/59), done.
remote: Total 68 (delta 4), reused 68 (delta 4), pack-reused 0 (from 0)
Receiving objects: 100% (68/68), 110.07 KiB | 348.00 KiB/s, done.
Resolving deltas: 100% (4/4), done.
Submodule '.obsidian' (git@github.com:Ningensei848/.obsidian.git) registered for path '.obsidian'
Submodule 'Shared/User/Ningensei848' (git@github.com:Ningensei848/Ningensei848.git) registered for path 'Shared/User/Ningensei848'
Cloning into '/mnt/c/Users/ningensei848/Dev/L45EN/.obsidian'...
remote: Enumerating objects: 13, done.
remote: Counting objects: 100% (13/13), done.
remote: Compressing objects: 100% (12/12), done.
remote: Total 13 (delta 0), reused 13 (delta 0), pack-reused 0 (from 0)
Receiving objects: 100% (13/13), 5.74 KiB | 367.00 KiB/s, done.
Cloning into '/mnt/c/Users/ningensei848/Dev/L45EN/Shared/User/Ningensei848'...
remote: Enumerating objects: 73533, done.
remote: Counting objects: 100% (5463/5463), done.
remote: Compressing objects: 100% (572/572), done.
remote: Total 73533 (delta 5152), reused 5139 (delta 4891), pack-reused 68070 (from 2)
Receiving objects: 100% (73533/73533), 9.59 MiB | 6.09 MiB/s, done.
Resolving deltas: 100% (67021/67021), done.
Submodule path '.obsidian': checked out 'abcdefghijklmnopqrstuvwxyzf50xxxxaf0'
Submodule path 'Shared/User/Ningensei848': checked out 'abcdefghijklmnopqrstuvwxyz1fbc594ffd791xxxxxxxxxxxxc16b'
```

:::

## おわりに

といっても弊職場でも実装できたのはマジで最近（というか今週の半ばぐらい；；）← `pre-commit` hook 書くのがつらすぎた

年内にクオリティを挙げて、再度別の記事として投稿できたら幸いです（もちろん適宜追記もします！）
