---
title: "docstring から PDF を出力し push するたびに Google Drive へ同期させる"
emoji: "📘"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["docstring", "pdf", "mkdocs", "rclone", "自動化"]
published: true
published_at: 2023-04-07 22:00 # 未来の日時を指定する
---

# TL; DR

1. `docstring` から PDF 出力される
2. GitHub Actions から Google Drive に同期
3. Push するたびにドキュメントが最新に保たれて ✨𝓗𝓪𝓹𝓹𝔂✨

っていうモノをつくった ↓
https://ningensei848.github.io/docstring2pdf/

![嬉しいことがあって喜ぶパソコンを使う人のイラスト](https://4.bp.blogspot.com/-zTvzECyWEsk/VwIjHWMdszI/AAAAAAAA5e4/W_kAnVythXoHGzGO3AkgrHImS3cpvMiuQ/s400/internet_kanki_man1.png)
_Happy で埋め尽くして R.I.P. まで行こうぜ_

# ドキュメント書きたくないけどドキュメントは必要

日々コードを書いていると、昔書いた処理の内容なんて一週間もしないうちに忘れてしまう。
自分の書いたものでさえままならないのだから、それがチーム開発となると大きな問題として顕在化する。

かといって、ドキュメント書け〜と云われると書きたくなくなるのが怠惰なエンジニアたちの定めである。
誰が読むかもわからない文章を読みやすくわかりやすく書けと言われても、その時点では十分に自分では理解できているつもりなので、どうしても億劫に感じてしまう。
というか、コード以外に向き合う時間をなるべく作りたくないというのが本音だろう。

![コンピューターが苦手な女性が、マニュアルを片手に難しそうな顔をしているイラスト](https://2.bp.blogspot.com/-udBXvU-T2fE/Vh4ot0CAPLI/AAAAAAAAzjc/aFK9ePO-ds8/s400/computer_manual_woman.png)
_先任者の引継書がチグハグで困惑する図_

# 書いたはいいが、公開できない

また、せめて慣れ親しんだ Markdown 形式で書けるように [`Docusaurus`](https://docusaurus.io/),[`GitBook`](https://docs.gitbook.com/) や [`docsify`](https://docsify.js.org/) を導入しても、今度は「表に出せないドキュメントをどうやってホスティングするのか」という問題も生じる（というかそもそもこれらのツールを活用しても、根本的に「コード以外に向き合いたくない」を解消できていない）。

そりゃあ体力のあるところはそんな些細なことには拘らず、内部向けにサイトを設置するなんて簡単にできるのだろうが、スタートアップやら急造チームやらでは、そこまで知見がないというのが現実といえる。
結局 MS Word や Google Docs に書いて PDF 等で出力して間に合わせる形となり、怠惰なエンジニアたちの心は離れ、知見は散逸し、ドキュメントは永遠に質が上がらない。

![ノートパソコンのモニタを見ながら、泣いている男性のイラスト](https://1.bp.blogspot.com/-iG3QVEWl4dE/Wn1Vwtu1PwI/AAAAAAABKE8/8KR9vfXirfU5yXepByewkYZcrWqT-2EtQCLcBGAs/s400/computer_man3_cry.png)
_色々やっても結局は身内向けだし、貢献として評価されにくい問題_

# そこで `docstring2pdf` をつくった

`Python` には `docstring` という素晴らしい機能がある。

https://en.wikipedia.org/wiki/Docstring

これを利用してコードを書きながら、ついでに使い方もちょろっとメモ的に書き残して、それがそのままドキュメントになったらいいな〜というのが最初の発想だった。
もちろんこれは先人も思いついていて実装されていたのだが、

1. PDF として出力したい
2. GitHub Actions で実行して、最新のソースでビルドしたい
3. ついでに Google Drive に同期したい

っていう要件が満たされているものはまだなさそうだった（無いよね？）。

こうしていろいろなプラグインやらソフトウェアやらを組み合わせて実現したのが `docstring2pdf` である。

https://ningensei848.github.io/docstring2pdf/

# 感想

詳しい使い方とかは、[`docstring2pdf`のページ](https://ningensei848.github.io/docstring2pdf/)に書いたので、そちらを参照してほしい。
さっそく自分のチームにも新年度から導入し、メンバー全員が `docstring` も書きつつコードも書きつつ頑張っていこう！というよい感触が得られたのでとても嬉しい。

ぜひ皆様もどうぞ〜😊

![キラキラとした笑顔で横並びで前に向かって走る、肩を組む男性会社員と女性会社員のイラスト](https://1.bp.blogspot.com/-8YI11SOhcYs/WM9XjJMIAXI/AAAAAAABCrQ/HExowxAmLLY8Dc6Obp5iWdbQQ5a30coegCLcB/s400/business_kyouryoku.png)
_新年度もチーム一丸で頑張ろう！_

# 改善点

当然ながら、まだこれだけでは改善すべき点はある。例えば、

- PDF 出力がガタつく
- デザインを変えたい
- フォントもうちょいどうにかしたい
- サービスアカウントじゃなくて [`OIDC`](https://docs.github.com/ja/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect) 使って [_Workload Identity_ 連携](https://cloud.google.com/iam/docs/workload-identity-federation) にしたい
- Google Drive 以外のクラウドストレージにも対応したい

などなど…

このあたりのことも、ぜひ [**Issue**](https://github.com/Ningensei848/docstring2pdf/issues) に書くとか [PR を投げる](https://github.com/Ningensei848/docstring2pdf/pulls)とか

なにとぞよろしくおねがいしまーす！！ 💪
