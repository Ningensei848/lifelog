---
title: "Docusaurus 活用のための Tips (2022年2月版)"
emoji: "🦕"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Docusaurus", "documentation", "Markdown", "React", "MDX"] # タグ．["markdown", "rust", "aws"]のように指定する
published: true
---

:::message

（初心者向け情報）この記事は[『ドキュメント作成ツールの決定版！Markdown + React の体験を Docusaurus で』](https://zenn.dev/ningensei848/articles/docusaurus_intro)を先に読んでおくと理解がしやすい内容となっています

:::

![静的サイトジェネレータ Docusaurus のマスコットキャラクターである Docusaurus Keytar くん](https://docusaurus.io/img/slash-introducing.svg)
_Docusaurus Keytar くんをすこれ，そして崇めよ_

# はじめに

[Docusaurus](https://docusaurus.io/)，みなさま使いこなされているでしょうか？

まさかもう令和４年にもなってまだ [Sphinx](https://www.sphinx-doc.org/) を使って奴隷労働に勤しむ人類はいないかと思いますが，各位いかがお過ごしでしょう？

![過酷な労働環境でコンピューターに向かいながら働く、俗に「IT土方（デジタル土方）」と呼ばれる男性](https://4.bp.blogspot.com/-OtfkvQ6YhEI/V5XczoV8lOI/AAAAAAAA8uM/ks16au6Xssw78rdg9F6VDRhv6naz2jqlgCLcB/s200/job_it_dokata.png)
_現代の「奴隷」に救いはあるのか_

約一年前に[『ドキュメント作成ツールの決定版！Markdown + React の体験を Docusaurus で』](https://zenn.dev/ningensei848/articles/docusaurus_intro)という記事を執筆し，たくさんの方に読んでいただきました．昨年２月時点では α 版でしかなかったこのプロジェクトも，今となっては bata.15 までバージョンアップを重ねており，非常に快適な使い心地が実現されています．私も，執筆前までのチュートリアル体験だけで終えることなく，その後も Docusaurus に定期的に触れ続けてきました．そのおかげで，それなりに知見も貯まりました（~~とはいえだいぶ Next.js SSG に浮気していたのですが~~）．

https://zenn.dev/ningensei848/articles/docusaurus_intro

本記事では，上記の記事で紹介しきれなかったカスタマイズのアプローチについて，初級・中級・上級といったグレードごとに手法をご紹介します！

バニラ感が否めずイマイチしっくり来ていないビギナー諸兄におかれましては，ぜひ一段階ランクアップのためにご一読いただければと思います．

# 初級：remark/rehype がクール

Docusaurus は [MDX をサポートしている](https://docusaurus.io/docs/markdown-features/react)のですが，それは Markdown (`.md`) も MDX (`.mdx`) も，両方とも [remark](https://remark.js.org/) + [rehype](https://github.com/rehypejs/rehype) を通じて html+js に書き出しているという技術的な背景[^1]があります．

[![remark - markdown processor powered by plugins](https://raw.githubusercontent.com/remarkjs/remark/main/logo.svg)](https://remark.js.org/)

https://github.com/remarkjs/remark

[![rehype - HTML processor powered by plugins](https://raw.githubusercontent.com/rehypejs/rehype/main/logo.svg)](https://unifiedjs.com/)

https://github.com/rehypejs/rehype

[^1]: Docusaurus そちのけで「`Unified` エコシステム」が気になってしまった方は，まず[この記事](https://vivliostyle.github.io/vivliostyle_doc/ja/vivliostyle-user-group-vol2/spring-raining/index.html)を読むのがおすすめです

これらの「`Unified` エコシステム」は，好きなようにプラグインを付け足してカスタマイズするのが非常に簡単です．公式でもかなりの数が紹介されています：

- [remark/plugins.md at main · remarkjs/remark](https://github.com/remarkjs/remark/blob/main/doc/plugins.md)
- [rehype/plugins.md at main · rehypejs/rehype](https://github.com/rehypejs/rehype/blob/main/doc/plugins.md)

例えば [`remark-gfm`](https://github.com/remarkjs/remark-gfm) は，GitHub で使われている [GFM 記法](https://github.github.com/gfm/)からの変換をサポートする remark プラグインです．本来であれば GitHub 上でしか認識されないはずの Markdown 文字列が，このプラグインを通じて意味のある HTML タグへと変換されています（URL っぽい文字列を検出してアンカーリンクにする，脚注・打ち消し・テーブル・チェックリストをつくるなど）．

https://github.com/remarkjs/remark-gfm

あるいは，ただ URL 文字列を見つけてアンカーリンクにするだけでなく，Zenn 記法の[**リンクカード**](https://zenn.dev/zenn/articles/markdown-guide#リンクカード)のように，リッチなコンテンツに見せるアプローチも考えられます．それに近いものを実現するのが [`@remark-embedder/core`](https://github.com/remark-embedder/core) と [`@remark-embedder/transformer-oembed`](https://github.com/remark-embedder/transformer-oembed) です．

https://github.com/remark-embedder/transformer-oembed

---

これらのプラグインは，`docusaurus.config.js` 内の各 `plugin-content-{blog,docs,pages}` 内のオプションから設定することができます（詳細は以下のページからご確認ください）：

https://docusaurus.io/docs/markdown-features/plugins

# 中級：Swizzle は怖くない

[![シェーカーを振ってカクテルを作っている女性のバーテンダー（マスター・バーメイド）](https://1.bp.blogspot.com/-RMh9VMFLwkE/X3SJ7OKIVsI/AAAAAAABbjU/9W8Q_uq8v3UE363sQKrQWtG4PKF5lJLHACNcBGAsYHQ/s200/bar_shaker_woman.png) _カクテル？なんのこっちゃ……_](https://docusaurus.io/docs/advanced/swizzling)

> Docusaurus Themes' components are designed to be replaceable. The replacing is called "swizzle". In Objective C, method swizzling is the process of changing the implementation of an existing selector (method).
> **In the context of a website, component swizzling means providing an alternative component that takes precedence over the component provided by the theme.**

"Swizzle" で検索してなんもわからんとなった Docusaurus ビギナーは数多く居ることと思います．あまり見慣れない・聞き慣れない言葉なのは当然，由来は Objective-C のメソッドだったようです．ズバリ日本語で説明してくれているページがあったので以下に引用します：

> Swizzling とは、メソッドの実装を別のものに置き換えることで、メソッドの機能を変更する行為のことで、通常は実行時に行われます。Swizzling を使用したいと思う理由は様々で、イントロスペクション、デフォルトの動作のオーバーライド、あるいは動的なメソッドのロードなどがあります。
> [By 松川 晋士, New Relic 株式会社　シニアテクニカルサポートエンジニア](https://newrelic.com/jp/blog/authors/shinji-matsukawa)
> cf. https://newrelic.com/jp/blog/best-practices/the-right-way-to-swizzle-in-objective-c

---

さて，Docusaurus においてはどうなっているのかというと，各 theme で使われているコンポネントを (1) `src/theme` 以下に書き出す[^2] (2) その名前のコンポネントだけは，ライブラリ側でなくローカルに置いてある物を使う　ということらしいです．ローカル環境を経由させて少し味付けし，それを元のライブラリ側と「混ぜる」という感覚なのかもしれません（というのが自分の理解だがあっているだろうか）．

[^2]: いくら `swizzle` してもローカルにコンポネントを書き出すだけで，実際には本元のコンポネントは失われていない

この機能を活用して，Docusaurus をコンポネント単位でカスタマイズできることがわかります………ましたが，じゃあその **「コンポネント単位」ってのはどうやって探すんだ？** というのが次なる障壁となります．たしかに `docusaurus swizzle THEME_NAME --list` とすればコンポネントの一覧を得ることができますが，それがどこでどのように機能しているのかについてはイマイチわかりません．

となれば，[ソースを覗いてみる](https://github.com/facebook/docusaurus/tree/main/packages/docusaurus-theme-classic)のがいいでしょう．`docusaurus-theme-classic` をルートディレクトリとしたときに，`src/theme` 以下に構成要素コンポネントが並んでいることがわかります．

例えば，「_Edit this page_ ってのが気に入らないから "このページの編集をリクエスト" に変えたい」と思ったとします（この文言を外部から変更するような設定は，今後もわざわざ追加されるようなことはないでしょう）．[この文言が含まれるコンポネント](https://github.com/facebook/docusaurus/blob/main/packages/docusaurus-theme-classic/src/theme/EditThisPage/index.tsx)を探し，Swizzling してローカルにコピーを作った後，文言を上書きした後にビルドし直します：

```shell
$ yarn run swizzle @docusaurus/theme-classic EditThisPage --typescript
# => 実行後に src/theme/EditThisPage/index.tsx が出力されていることを確認
```

:::details src/theme/EditThisPage.tsx

```tsx:src/theme/EditThisPage.tsx
import React from "react";
import Translate from "@docusaurus/Translate";

import type { Props } from "@theme/EditThisPage";
import IconEdit from "@theme/IconEdit";
import { ThemeClassNames } from "@docusaurus/theme-common";

export default function EditThisPage({ editUrl }: Props): JSX.Element {
  return (
    <a
      href={editUrl}
      target="_blank"
      rel="noreferrer noopener"
      className={ThemeClassNames.common.editThisPage}
    >
      <IconEdit />
      <Translate
        id="theme.common.editThisPage"
        description="The link label to edit the current page"
      >
        Edit this page  {/* <= Change this text */}
      </Translate>
    </a>
  );
}
```

:::

この EditThisPage コンポネントが `src/theme` 以下に存在する限り， @docusaurus/theme-classic に含まれる `@theme/EditThisPage` コンポネントは無視され続けます．そしてもちろん，**`src/theme/EditThisPage.tsx` が削除されれば，`@theme/EditThisPage` が優先されるようになります**（つまり，元の状態に戻ります）

**`Swizzling` コマンドはコンポネントを復元不能な状態に変化させるものではありません**（もし不可逆的な変化を引き起こす場合，`Swizzle` とは命名されないでしょう）．「必要なコンポネントをローカルに持ってきてちょこっと味付けしたものと "混ぜる" 」というのは，そういうニュアンスを表現するためのものと言えます．

# 上級：Plugin はサイコー

いよいよ [Docusaurus Plugins](https://docusaurus.io/docs/advanced/plugins) を紹介します．[こちらのリスト](https://docusaurus.io/docs/api/plugins)にもある通り，公式が提供するプラグインもすでにいくつかあるため，本格的に自作したい場合はまずこちらを参考にすると良いでしょう．

まず手を付けやすいのは，[`docusaurus.config.js` に直接的に処理を書いてしまうこと](https://docusaurus.io/docs/advanced/plugins#function-definition)でしょう．設定ファイルは JS として読み込まれるため，比較的小さな処理であればそこに書き込んでしまうのもアリかもしれません．`Plugin` オブジェクトさえ返してくれれば，どのような関数であってもかまいません．

![焦りながら文章を書いている女性会社員](https://1.bp.blogspot.com/-RE5hsv_zWcM/WWXXM71J53I/AAAAAAABFgU/fRReDdQKtT038k1gZ9TT3aUjFRTdnbK_wCLcBGAs/s200/shimekiri_report_businesswoman.png)
_急いでるし，生 JS を直接書き込んじゃえ～_

:::details 直接的に処理を書く場合

```js:docusaurus.config.js
module.exports = {
  // ...
  plugins: [
    async function myPlugin(context, options) {
      // ...
      return {
        name: 'my-plugin',
        async loadContent() {
          // ...
        },
        async contentLoaded({content, actions}) {
          // ...
        },
        /* other lifecycle API */
      };
    },
  ],
};
```

:::

---

流石に設定ファイルに直接書き込んでしまうのは，ファイルが肥大化する原因なのでやめたとします．次に考えられるアプローチは**別ファイルとして作ってインポートすること**です．仮に `src/plugins` というフォルダをつくれば，`src/plugins/myPlugin.js` というファイルに処理を書けばよいでしょう．その後，[`docusaurus.config.js` の `plugins` 配列の中にプラグインまでの相対パスを置いてください](https://docusaurus.io/docs/advanced/plugins#module-definition)（プロジェクトルート直下に `docusaurus.config.js` があるなら `./src/plugins/myPlugin`）．

肝心な中身については，[Plugin Method References | Docusaurus](https://docusaurus.io/docs/api/plugin-methods) を隅から隅まで目を皿のようにして精読するのが一番の近道と思います．とても自由度が高く設定されているため，いくらでも HACK できてしまうでしょう．醍醐味でもある部分だと思うので，ここは一旦個人の裁量に任せます．

:::details 例）別ファイルとして作ってインポートする書き方

```js:docusaurus.config.js
module.exports = {
  // ...
  plugins: [
    // without options:
    './myPlugin',
    // or with options:
    ['./myPlugin', options],
  ],
};
```

```js:src/plugins/myPlugin.js
module.exports = async function myPlugin(context, options) {
  // ...
  return {
    name: 'my-plugin',
    async loadContent() {
      /* ... */
    },
    async contentLoaded({content, actions}) {
      /* ... */
    },
    /* other lifecycle API */
  };
};
```

:::

---

![「かたぬき」という提灯がかかったお祭りの屋台で一生懸命型ぬきをしている男の子](https://3.bp.blogspot.com/-llS6ZcTQQgY/U6llVeKR_lI/AAAAAAAAhvM/ZD0d_-Ba-_I/s200/omatsuri_katanuki.png)
_男の子は型抜きがすき（筆者の私見）_

最後に，型が欲しくて仕方がない TypeScript ジャンキーへのハウツーをお伝えします．

現状，**プラグインモジュールを TypeScript で書いて直接的に `docusaurus.config.js` で読み込むことはできません**（2022/02/23 現在）．コンポネントが TypeScript でかけるならプラグインも †_Zero-config_† で書けるようになってほしいというのはありがちな願望かと思いますが，ともあれ beta.15 の段階ではまだサポートされていません．

が，そこであきらめるのではなく，**だったら自分でトランスパイルすればええやん！** というのが開発者のあるべき姿と考えます．

理想的には，docusaurus のビルドが走るたびに，その直前に `myPlugin.ts` を `myPlugin.js` へと変換してやればよいでしょう．が，それを [tsc](https://github.com/microsoft/TypeScript) にまかせてしまうと，毎回何十秒も待たされる「最悪体験」に直面してしまうかもしれません．

https://swc.rs/

代わりに，[`swc`](https://swc.rs/) を採用します．型チェックこそしません[^3]が，Rust による速度の暴力で爆速変換を実現してくれます．やったぜ．

[^3]: 型検証については，[プロジェクトルート直下にある `tsconfig.json`](https://docusaurus.io/docs/typescript-support#setup) に対応した [ESLint の設定 (`.eslintrc.js`)](https://typescript-eslint.io/docs/linting/type-linting/) を行なうのが良いだろう

:::details swc による設定の詳細

```shell:terminal
yarn add --dev @swc/cli @swc/core
```

```json:package.json
{
  "scripts": {
    "emit": "swc src/plugins -d src --config-file src/plugins/.swcrc",
    "start": "yarn emit && docusaurus start",
    "build": "yarn emit && docusaurus build",
    "swizzle": "docusaurus swizzle",
    "serve": "docusaurus serve"
  }
}
```

```json:src/plugins/.swcrc
{
    "minify": true,
    "module": {
        "type": "commonjs",
        "strict": true,
        "noInterop": true,
        "ignoreDynamic": true
    },
    "exclude": [
        ".*.js$",
        ".*.map$"
    ],
    "jsc": {
        "externalHelpers": true,
        "parser": {
            "syntax": "typescript",
            "tsx": false,
            "decorators": false,
            "dynamicImport": false
        },
        "target": "es2022",
        "baseUrl": ".",
        "paths": {
            "@site/*": [
                "./*"
            ]
        }
    }
}
```

:::

# 終わりに

[Docusaurus](https://docusaurus.io/) をカスタマイズしていく方法を三段階に分けてご紹介しました．そうはいってもまだまだ β 版ということもあり，今後はなにかしらの破壊的な変更が加えられるかもしれません．本記事の情報はあくまでも現時点（2022/02/23）での情報であることにご留意ください．

いずれは「[ドキュメンテーションジェネレータの比較（英語版）](https://en.wikipedia.org/wiki/Comparison_of_documentation_generators)」ってページにも Docusaurus が掲載され，ぶっちぎりの支持を得るような時代が来ることを切に願います．

> （本記事の内容も含め Docusaurus について何かわからないことがあれば，お気軽にコメント・ご質問ください．また，**もし人事権を持つ方がこの記事とワイのプロフィールを読んで興味持ったら，ぜひともご一報ください……切実に** 😢）

![卵から生まれたばかりの恐竜の赤ちゃん](https://docusaurus.io/img/slash-birth.png)
_ようやくのぼりはじめたばかりだからな　このはてしなく遠い 🦖 坂をよ…_
