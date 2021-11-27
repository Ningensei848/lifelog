---
title: "Ajv × JTD で JSON の型定義とバリデータを同時に得る" # <-- "JSON Typed Definition で始める Ajv 入門"
emoji: "🔍"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Ajv", "JSONTypedDefs", "JTD", "validation", "TypeScript"]
published: true
---

# TL; DR

1. [Ajv](https://ajv.js.org/) っていう JSON バリデータを紹介
2. [JSON Typed Definition](https://jsontypedef.com/) っていう規格を使う；ただし [RFC 8927](https://datatracker.ietf.org/doc/rfc8927/) _(Experimental)_ なことに留意すること
3. クロスプラットフォーム対応な **型定義**と**バリデータ**がサクッと手に入って最高！

# はじめに

フロントエンドでもバックエンドでも共通の規格として採用され，かつ一般的な人類が普遍的に理解できるし書ける ―――

プログラミングにおいて，データ構造はその用途によって様々なカタチであらわれます．CSV / XML / YAML / TOML といった例は数あれど，特に **JSON** ほど広く普及し，かつ誰でも理解されやすいものは未だありません．人が読み書きするのはもとより，クライアント・サーバの双方でやりとりする場合にも多く採用されています．

![ペンキの入った缶と刷毛を持って壁に色を塗っている塗装屋（ペンキ屋）で働く職人さんのイラスト](https://2.bp.blogspot.com/-WOc5pWn15o8/V0Qnj4aJF7I/AAAAAAAA68A/w2osMzrYwUcHBXsngSH3gw2d_K1n1JtdgCLcB/s400/penki_tosou_man.png)
_JSON 色付け職人の朝は早い_

一方で，その柔軟性から安全に扱いにくいという難点もあります：任意の API サーバを叩いてデータを受け取る際に，そのレスポンスに型をつけるのを諦めて `any` として扱うのはよくあることでしょう．こうすると，データを受け取ることはできても，その後のハンドリングに苦労することになります．こんなときに欲しくなるのが「データの整合性を検証すること」すなわち _Validation_ です．プロパティの過不足や不正な値を検出して，うまく処理できるように支援してくれる存在となり得ます．

もちろん自分でフルスクラッチするのも後々の経験のためにアリですが，どうせならすでにある枠組みに乗っかりたいものです！本稿では，JavaScript / TypeScript における _validator_ ライブラリとして，[Ajv](https://ajv.js.org) を紹介します．また，実際の活用法に触れる際に _JSON Typed Definition_ というスキーマ定義の方法もお伝えします．

# What is Ajv ?

![Ajv JSON schema validator | Security and reliability for JavaScript applications](https://storage.googleapis.com/zenn-user-upload/ec185b33a51c428999427243.png)
_記述量を減らし，速くてセキュア，さらに Multi-standard な規格を採用_

:::details read more ...
[Ajv](https://ajv.js.org) は あらゆる JavaScript 環境で使われている _JSON Validator_ です．特徴としては以下の 3 つが挙げられています：

## 1. Write less code: 記述を減らす

データを受け取った時点で有効であることを確認できれば，自ずと検証やサニタイズのロジックは減らせます．
加えてクロスプラットフォームに対応した [JSON Schema](https://ajv.js.org/json-schema.html) (drafts 04, 06, 07, 2019-09 and 2020-12) 或いは [JSON Type Definition](https://ajv.js.org/json-type-definition.html) を用いてデータ要件を宣言すれば，フロントエンド / バックエンド ともに負担を減らすことができるようになります．

## 2. Super fast & secure: 速くて安全

Ajv では，与えられたスキーマを最適化済みの JavaScript コードにコンパイルします．
（ V8 エンジンに最適化した超高速な関数を生成できるようになっています）

（※ベンチマーク等は[こちら](https://ajv.js.org/guide/why-ajv.html#super-fast-secure)をご参照ください）

開発当初は速度と厳密さを追求し多くの支持を得ていましたが，セキュリティ的な欠陥も多くありました．しかしそれらは長い年月と多くのユーザの報告によって修正され，v7 では安全なコード生成が再構築されました．

（※さらに詳細に知りたい場合は[こちら](https://ajv.js.org/codegen.html)をご覧下さい）

## 3. Multi-standard: 多数の規格をサポート

JSON Schema における多数の _drafts_ へのサポートに加えて，[RFC 8927](https://datatracker.ietf.org/doc/rfc8927/)[^1] _(Experimental)_ である JSON Typed Definition も採用しています．
[^1]: JSON Type Definition は \[[RFC8927](https://datatracker.ietf.org/doc/rfc8927/)\] (_Experimental_) である

型システムとの整合性を考慮して設計された JTD は，**複数の言語の検証と型コード生成の両方を行うツール**も備えていて，将来的にも期待大と言えるでしょう．

（※本稿ではこの JTD を採用して Ajv を扱います）

:::

# Ajv に入門する前に

JTD では，`properties` を筆頭に８種類の _form_ を用いてスキーマを定義しています．
Ajv を知る前に JTD について詳しく知りたい方は[こちら](https://zenn.dev/ningensei848/articles/jtd-in-5-minutes)をご覧ください．

https://zenn.dev/ningensei848/articles/jtd-in-5-minutes

# Getting started (with JSON Typed Definition)

それでは，[こちら](https://ajv.js.org/guide/getting-started.html)を参照しつつ，Ajv へ入門していきましょう！

まずはともあれ，パッケージのインストールから始めます：

```shell
$ npm install ajv
// or
$ yarn add ajv
```

Ajv で実際にバリデーションを行なうまでには，以下のステップをこなす必要があります：

1. スキーマを定義
2. コンストラクタを初期化（設定もここで行なう）
3. スキーマのコンパイル → 型定義とバリデータを取得
4. 嬉しい副産物

順番に見ていきましょう．

## 1. スキーマを定義

JSON Typed Deifinition でのスキーマ定義の例を挙げます：

```ts
const schema = {
  properties: {
    foo: { type: "int32" },
  },
  optionalProperties: {
    bar: { type: "string" },
  },
} as const;
```

`as const` とあるのは，TypeScript 3.4 以降の機能である [_const assertion_](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions) のことです．

:::details より詳しい説明:

`as` による [型アサーション](https://typescript-jp.gitbook.io/deep-dive/type-system/type-assertion)は，単に推論された型を明示的に上書きするというだけのものでしたが，`as const` では以下のような作用が起こります：

```typescript:example.ts
// Type '"hello"'
let x = "hello" as const;
// Type '{ readonly text: "hello" }'
let z = { text: "hello" } as const;
// Type 'readonly [10, 20]'
let y = [10, 20] as const;
```

- 式の中の リテラル が拡張されない
- _object_ リテラル が（再帰的にすべて）読み取り専用のプロパティになる
- _array_ リテラル が読み取り専用のタプルになる

:::

これにより，スキーマは以下のようにキャストされます：

```ts
const schema: {
  readonly properties: {
    readonly foo: {
      readonly type: "int32";
    };
  };
  readonly optionalProperties: {
    readonly bar: {
      readonly type: "string";
    };
  };
};
```

すべてのプロパティに `readonly` が付与され，各 `type` プロパティは `string;` ではなく `"int32"`, `"string"` というリテラルとして定義されました！
なぜこのようにするのか？については後述します，しばしお待ちを……

## 2. コンストラクタを初期化（設定もここで行なう）

```js
// import Ajv from "ajv"; // <----- not fof JTD
import Ajv from "ajv/dist/jtd";
const ajv = new Ajv();
/*
* For example, to report all validation errors (rather than failing on the first errors)
* you should pass allErrors option to constructor:
const ajv = new Ajv({allErrors: true})
*/
```

JSON Schema を使う場合には `ajv` からのインポートですが，JTD を使う場合には `ajv/dist/jtd` からになることに留意してください．

また，コンストラクタの引数には `Options` を指定することができます．まず試してみるだけの場合には特に必要ありませんが，興味ある方は[こちら](https://ajv.js.org/options.html#ajv-options)をご覧ください．

https://ajv.js.org/options.html#ajv-options

## 3. スキーマのコンパイル → 型定義とバリデータを取得

```ts
type MyData = JTDDataType<typeof schema>;

// type inference is not supported for JTDDataType yet
const validate = ajv.compile<MyData>(schema);
```

よく `undefined` の判定などでもお世話になる [型ガード](https://typescript-jp.gitbook.io/deep-dive/type-system/typeguard) でよくみる `typeof` を活用し，schema の型を取得しています．ここできっちりとした型を得るために前述の `as const` が必要になってくるわけですね．

これを Ajv が提供している [_Utility types_](https://www.typescriptlang.org/docs/handbook/utility-types.html) であるところの `JTDDataType` を使って型変換させています……って，何をいっているかわからないと思いますが，この時点で `MyData` の持つ型定義は以下のようにキャストされます：

```ts
type MyData = {
  foo: number;
} & {
  bar?: string | undefined;
};
```

？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？

＿人人人人人人人人人人人人人人人人人人人人人人人人人＿
＞ **JTD でスキーマ定義したら TS の型定義も終わってた** ＜
￣ Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^ ￣

これが JTD x Ajv のヤバさです…… _Write less code_ の目標通り，**JTD スキーマだけ定義できれば，あとはいい感じに型定義が生成**されてしまいます．
加えて，変数 `validate` には `ajv.compile(schema)` の返り値として，データ検証用の関数すなわちバリデータ関数が与えられます．この関数の引数に任意のデータを渡すことで，それがスキーマに合致したデータなのかどうか検証することが出来ます．

```ts:validation sample
const validData = {
  foo: 1,
  bar: "abc",
};

if (validate(validData)) {
  // data is MyData here
  console.log(validData.foo); // 1
} else {
  console.log(validate.errors);
}
```

たったこれだけです！

## 4. 嬉しい副産物

さらにさらに，バリデータがあるならついでにパーサーとシリアライザもほしいよねという需要も応えるべく，`compileParser` と `compileSerializer` も用意されています．より型安全に `JSON.parse()` / `JSON.stringfy()` ができるとおもうとだいぶ嬉しいように思います．

:::details read more ...

```ts
const parse = ajv.compileParser<MyData>(schema);
const serialize = ajv.compileSerializer<MyData>(schema);

const data = {
  foo: 1,
  bar: "abc",
};

const invalidData = {
  unknown: "abc",
};

console.log(serialize(data));
console.log(serialize(invalidData)); // type error

const json = '{"foo": 1, "bar": "abc"}';
const invalidJson = '{"unknown": "abc"}';

console.log(parseAndLogFoo(json)); // logs property
console.log(parseAndLogFoo(invalidJson)); // logs error and position

function parseAndLogFoo(json: string): void {
  const data = parse(json); // MyData | undefined
  if (data === undefined) {
    console.log(parse.message); // error message from the last parse call
    console.log(parse.position); // error position in string
  } else {
    // data is MyData here
    console.log(data.foo);
  }
}
```

:::

https://ajv.js.org/guide/typescript.html#type-safe-parsers-and-serializers

# JSON Typed Definition Validator

「よっしゃ！JTD やってみたろ！」と思い立ったのが先月末の自分でしたが，その頃にはどうやったら「 JTD によるスキーマ定義」ができるのか何もわかりませんでした．
少しでも理解を深めるべく[公式解説を和訳してみる](https://zenn.dev/ningensei848/articles/jtd-in-5-minutes)なんてこともやったのですが，イマイチしっくりこない．というかそもそもスキーマ定義が合ってるのか間違ってるのかについて，実際にコードを走らせるまではわからないという状況が最悪でした……🤮

https://zenn.dev/ningensei848/articles/jtd-in-5-minutes

ここで諦めるのはどうしても許せなかったので，最近力を入れている Next.js を使って自分で作ることにしました．

https://github.com/Ningensei848/jtd-validator

![JSON Typed Definition Validator](https://storage.googleapis.com/zenn-user-upload/28c4a3872b4e44ea7e1d88ed.png)
_Next.js + TypeScript + Mui + CodeMirror [on Vercel](https://jtd-validator.vercel.app/)_

https://jtd-validator.vercel.app/

ぜひ使ってみてください！ついでにスターとかも付けてくれると喜びます 🥳

# まとめ

ここまでで実際に行なったことは以下の二つです：

1. JSON Typed Definition によるスキーマ定義
2. Ajv の初期設定

これによって得られたものは以下のとおりです：

1. JTD 由来の型定義
2. ↑ をもとにした型安全な _Validator_
3. ↑ をもとにした型安全な _Parser_
4. ↑ をもとにした型安全な _Serializer_

![有益な情報を伝えるためにインターネットに降臨した神と呼ばれる人のイラスト](https://2.bp.blogspot.com/-y2bo0WxJCiU/V4-O0nuVH0I/AAAAAAAA8Zc/lxv7lgGGBY49qw7jBMhMkQpH-sC1qfn3ACLcB/s500/internet_god.png)
_JSON Typed Definition は安全をもたらす_

正直笑っています，いままで苦労していろいろ頑張ってたのに，JTD でスキーマ定義するだけで """全部""" が手に入ってしまった 🥲

みなさんもぜひ明日から _JSON Typed Definition_ こと **JTD** および **_Ajv JSON Validator_** でサイコーのスキーマドリブンな開発をお楽しみください 👍

## 追記１

[JSON Typed Definition の未来の話](https://zenn.dev/link/comments/bf72e86ed6ce37) という _small idea_ をスクラップとして残したので，TypeScript ガチ勢の知見をぜひともお借りしたい
https://zenn.dev/link/comments/bf72e86ed6ce37
