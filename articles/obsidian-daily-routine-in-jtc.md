---
title: "Obsidianで日々の業務にリズムをつくるin閉域環境なJTC"
emoji: "🏯"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["obsidian", "業務効率化", "日報", "JTC"]
published: false
---


## 結論

[`Embed a note in another note` 機能](https://obsidian.md/help/embeds#Embed+a+note+in+another+note)とか、ちょっと古いけど[External File Embed and Link](https://github.com/oylbin/obsidian-external-file-embed-and-link)ってコミュニティプラグイン使えばJTCでもいい感じにタスク管理がなんとかなる！

https://obsidian.md/help/embeds#Embed+a+note+in+another+note

https://github.com/oylbin/obsidian-external-file-embed-and-link

## 背景

以前、[Obsidian を「**チームで使えるようにしたい**」](https://zenn.dev/ningensei848/articles/obsidian-air-gapped-team-sync)という記事を書き、実際にいま弊部署ではObsidianを用いて業務効率化に取り組んでいる
……とはいうものの、ベースがそもそもITじゃないとか開発系じゃないし、なんなら脳みそ筋肉体育会系の社会で生きてきたフィジカルエリートたちを相手に、どうにかイロハを叩き込もうと躍起になっている。

https://zenn.dev/ningensei848/articles/obsidian-air-gapped-team-sync

ブラインドタッチはもとより、タイピングすらおぼつかない人々に対してまずやるべきは**眼の前にあるハコと自身の思考の距離を縮めること**であり、泥臭く反復練習するほかない。
学生時代ならいざ知らず、社会人においてそんな機会を提供できるはずがないので、代わりに日報[^1]を書いて習慣化しましょうという結論に至った。
もちろん、それと並行してObsidianにノートを取ることで思考整理と入力練習をやってもらうのだが。

[^1]: とはいうが、それをレビューするなどは面倒くてやってられないので、個々人の業務効率化に資するタスク管理枠組み、という感じだろうか

そんなとき、zenn を眺めていたら面白い取り組みがあることを知った。

https://zenn.dev/fukurou_labo/articles/obsidian_google_calendar


> ## できること
>
> 本記事で紹介する仕組みを導入すると、以下が自動化されます。
>
> - 前日の未完了タスクを当日の Daily Note に 自動引き継ぎ
> - Google Calendar の予定を Daily Tasks に 自動追加
> - Google Meet の Gemini メモを Obsidian に 自動取り込み

Google Calendar / Meet がそもそも使えない弊社としては歯ぎしりする思いだったが、「未完了タスクの自動引き継ぎ」はちょとオモロそうなのでやってみた。

---

丸パクリだと芸が無いし、TODOが完了しないとずっと残るという仕様にちょっとストレスを感じたので、「毎日引き継ぐタスク」と「中長期的なタスク」に分けることにした。

## 毎日引き継ぐタスク

[Obsidian の公式ドキュメント](https://obsidian.md/help/embeds#Embed+a+note+in+another+note)にある通り、ノートには別のノートを埋め込める。
しかも全体ではなく、一部セクションを切り取ることが可能という仕様だ。

これを使えば、デイリーノートの `## TODO` セクションだけと切り取って埋め込めばいいじゃん！とはじめは考えたが、更新のたびに当該ノートまで遡ることになる。
ウチでは[Obsidian Git](https://github.com/Vinzent03/obsidian-git) プラグインも使っており、あんまり頻繁に変更が生じるのも面倒だ。
過去に書いてCommitしたノートはそのまま変更せず、残りタスクだけ参照したい。うーんどうしたものか。

---

なんてことを考えていたら、偶然「レトロスペクティブ」なんて横文字を目にした。
ごちゃごちゃと様々御託はあれど、つまるところ「業務の振り返り」をするらしい。
これを個人で毎日やればいいんじゃね？（素人思考）ってことで以下がその発想でつくったデイリーノートのテンプレ：
（随所に templater に由来する js が残っているのは御愛嬌）

https://github.com/Ningensei848/Knewrova/blob/main/__Template/Daily.md

工夫ポイントは、「前回のあらすじ」と「Next Action」を Embed で繋いだこと

![Headings on my dailynote template](/static/img/daily-routine-obsidian/dailyNote.png)

こうすることで、`## Next Action` というセクションが、次の日以降のデイリーノートの `## 前回までのあらすじ` に埋め込まれて表示される。
上述した記事のように自動的に未完了タスクを集めて表示するのではなく、あくまで日ごとに個人が振り返りを実施し、NextAction を考え、きれいさっぱり業務内容を忘却して帰宅する枠組みを提供できた。

## 中長期的なタスク

使っているうちに、「うまく消化できなくて後回しになり、何日もタスクをバケツリレーしてしまう」という問題も生じた。
つまり、そのタスクは当日に終わるものではなく、もっと時間の掛かる長期的なものだった…というときにどう扱うか考えておきたい。

一人で悩むよりは、他の人の手を借りたほうがいい場合もある。
でもそのためには、他の人から見てどういうタスクを抱えているのか示す必要がある。

ってことで、どうにかしてタスク共有を図りたいと考えた。
しかしここは国内最大手のJTC環境、すなわち自由などありはしない。
バックログは使えないし GitLab も設置不能。
およそタスク管理といえば業者が出してくるエクセルシートくらいか。

---

[Obsidian を「チームで使えるようにしたい」](https://zenn.dev/ningensei848/articles/obsidian-air-gapped-team-sync)記事を書いた際に、共有フォルダさえ使えれば意外と可能性が残るという発見をしていた。
発想の転換で、共有フォルダへの通信さえ行えれば、それを静的コンテンツ配信サーバに転用することも可能である。

いくつかのGeminiとの壁打ちの後、[`External File Embed and Link`](https://github.com/oylbin/obsidian-external-file-embed-and-link)が最適っぽいことがわかった。
ファイルデータを読み込んでいい感じに表示してくれるプラグイン（最終更新：2025-05-29）であるらしい。
共有フォルダに生データソースを置いておけば誰でも編集できるし、誰に取ったも同じ情報源として機能しうる。

各人の抱えたタスクを Vault ではなく 共有フォルダ上の DailyUpdate.md として日々書き出すようにした。
こうして、重めのタスクはローカルになく、方や他の人の取り組みにも注視しうる環境が整った！


Templater のスニペット集
https://zenn.dev/ctxzz/articles/db7d4f67547622

コメント：なんかにつかえそう