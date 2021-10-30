---
title: "５分で理解する JSON Type Definition"
emoji: "🖐"
type: "tech"
topics: ["json", "JTD", "validation", "TypeScript"]
published: false
---

:::message alert
この記事は [Learn JSON Typedef in 5 Minutes | JSON Type Definition](https://jsontypedef.com/docs/jtd-in-5-minutes/) を（勝手に）和訳したものです．
:::

この記事は JSON Type Definition schema を理解するためのチュートリアルです．
もしかするとあなたは（中略）JTD が正式に定義されている [RFC 8927](https://tools.ietf.org/html/rfc8927) に興味を持っているかもしれません．
しかし多くの人にとっては，このチュートリアルのほうが理解しやすいでしょう．さっそく始めましょう！

<!-- This article is a tutorial that will teach you everything you need to know to understand any JSON Type Definition schema. If you’re the sort of person who really loves extreme specificity and/or standards-ese, you may find RFC 8927, where JTD is formally defined, to be interesting. But for most folks, this tutorial will be easier to understand. Let’s get started! -->

# JSON Type Definition schema とはなにか

"JSON Type Definition" とは，単なる JSON 文書です（JSON Typedef とか `JTD` とも呼びます）．

<!-- JSON Type Definition (aka “JSON Typedef”, or just “JTD”) schemas are just JSON documents. Here is a JTD schema: -->

```json
{
  "properties": {
    "name": { "type": "string" },
    "isAdmin": { "type": "boolean" }
  }
}
```

これを YAML 形式で書くと，次のようになります：

<!-- You might also see schemas written as YAML instead, for example: -->

```yaml
properties:
  name:
    type: string
  isAdmin:
    type: boolean
```

技術的には JSON で書かれたスキーマのみが有効ですが，まずスキーマを YAML で書き，最後の最後で JSON に変換することはかなり一般的な手法でしょう．

<!-- Technically, only the JSON representation of a schema is valid. But writing schemas in YAML, and then converting them to JSON at the last minute, is a pretty common practice. -->

また，スキーマには ８つの形式があります．あるスキーマがどの形式を採用しているかは，そのスキーマに含まれるキーワードからわかります．また，８つの形式とは以下のことを指しています：

<!-- Schemas can take on one of eight forms. You know which form a schema is using based on what keywords are in the schema. The eight forms are: -->

#### eight forms

- [`empty`](http://localhost:8000/articles/jtd-in-5-minutes#empty): Java でいう `Object` や Typescript でいう `any` を扱う形式
<!-- The empty form is like a Java Object or TypeScript any. -->

- [`type`](http://localhost:8000/articles/jtd-in-5-minutes#type): Java や Typescript でいう `primitive type` を扱う形式
<!-- The type form is like a Java or TypeScript primitive type. -->

- [`enum`](http://localhost:8000/articles/jtd-in-5-minutes#enum): Java や Typescript でいう `enum` を扱う形式
<!-- The enum form is like a Java or TypeScript enum. -->

- [`elements`](http://localhost:8000/articles/jtd-in-5-minutes#elements): Java でいう `List<T>` や Typescript でいう `T[]` を扱う形式
<!-- The elements form is like a Java List<T> or TypeScript T[]. -->

- [`properties`](http://localhost:8000/articles/jtd-in-5-minutes#properties): Java でいう `Class` や Typescript でいう `interface` を扱う形式
<!-- The properties form is like a Java class or TypeScript interface. -->

- [`values`](http://localhost:8000/articles/jtd-in-5-minutes#values): Java でいう `Map<String, T>` や Typescript でいう `{ [key: string]: T}` を扱う形式
<!-- The values form is like a Java Map<String, T> or TypeScript { [key: string]: T}. -->

- [`discriminator`](http://localhost:8000/articles/jtd-in-5-minutes#discriminator): タグ付き Union を扱う形式[^1]
<!-- The discriminator form is like a tagged union. -->

- [`ref`](http://localhost:8000/articles/jtd-in-5-minutes#ref): スキーマを再利用するためのもの．通常は同じことを繰り返さないようにする．
<!-- The ref form is for re-using schemas, usually so you can avoid repeating yourself. -->

[^1]: cf. [TypeScript 4.6 で起こるタグ付きユニオンのさらなる進化 | Zenn](https://zenn.dev/uhyo/articles/ts-4-6-destructing-unions)

スキーマは，これらのうちどれか一つに正確に従わねばなりません．すなわち，ある形式のキーワードと他の形式のキーワードを混在させることはできません．

<!-- Schemas have to be exactly one of these forms. You can’t mix keywords from one form with keywords from another. -->

## `Empty`

次のスキーマは有効です：

<!-- Here’s a valid schema: -->

```json:schema
{}
```

これは「空」のスキーマです．あらゆる JSON の値を受け入れ，いかなるものも拒否しません．

<!-- This is an “empty” schema. It accepts any JSON value, and rejects nothing. -->

## `Type`

スキーマで `type` を使うと，ある値がプリミティブな JSON であることを指定できます．たとえば，次のように表せます．

<!-- You can use type in a schema to specify that something is a primitive JSON value. For example, -->

```json:schema
{ "type": "boolean" }
```

`true` あるいは `false` のみ受け入れ，その他のすべては拒否します．

<!-- Accepts true or false, and rejects everything else. -->

以下に，`type` に設定できるすべての値を紹介します.

<!-- Here are all the values you can put for type: -->

> | type      | What it accepts                                                                     | Example                   |
> | --------- | ----------------------------------------------------------------------------------- | ------------------------- |
> | boolean   | true or false                                                                       | true                      |
> | string    | JSON strings                                                                        | "foo"                     |
> | timestamp | JSON strings containing an [RFC3339 timestamp](https://tools.ietf.org/html/rfc3339) | "1985-04-12T23:20:50.52Z" |
> | float32   | JSON numbers                                                                        | 3.14                      |
> | float64   | JSON numbers                                                                        | 3.14                      |
> | int8      | Whole JSON numbers that fit in a signed 8-bit integer                               | 127                       |
> | uint8     | Whole JSON numbers that fit in an unsigned 8-bit integer                            | 255                       |
> | int16     | Whole JSON numbers that fit in a signed 16-bit integer                              | 32767                     |
> | uint16    | Whole JSON numbers that fit in an unsigned 16-bit integer                           | 65535                     |
> | int32     | Whole JSON numbers that fit in a signed 32-bit integer                              | 2147483647                |
> | uint32    | Whole JSON numbers that fit in an unsigned 32-bit integer                           | 4294967295                |

## `Enum`

`enum` を使うと，あるリストに含まれる文字列であるとすることができます．

<!-- You can use enum in a schema to say that something has to be a string in a given list. For example, -->

```json:schema
{ "enum": ["FOO", "BAR", "BAZ"] }
```

"FOO"、"BAR"、"BAZ "のみ受け入れ，それ以外は拒否します．ただし，JTD では〈_文字列の列挙のみが可能_〉で，**数字の列挙はできません**．

<!-- Accepts only "FOO", "BAR", and "BAZ". Nothing else is accepted. You can only do enums of strings; you can’t have an enum of numbers in JTD. -->

## `Elements`

配列を記述するには `elements` を使います． `elements` の値となるのは 別の JTD スキーマ です．

<!-- To describe an array, use elements. The value of elements is another JTD schema. For example, -->

```json:schema
{ "elements": { "type": "string" } }
```

各要素が文字列である配列を受け付けます．つまり，`["foo", "bar"] ` と `[]` は OK ですが，`"foo"` （文字列型）と `[1, 2, 3]` （数値型の配列）は NG です．

<!-- Accepts arrays where every element is a string. So ["foo", "bar"] and [] are OK, but "foo" and [1, 2, 3] are not. -->

## `Properties`

各キーが別々の型を持つの値がある JSON オブジェクトを記述するには， `properties` スキーマを使います．

<!-- To describe a JSON object where each key has a separate type of value, use a “properties” schema. For example, -->

```json:schema
{
  "properties": {
    "name": { "type": "string" },
    "isAdmin": { "type": "boolean" }
  }
}
```

この例では，`name` プロパティ（文字列でなければならない）と `isAdmin` プロパティ（ブール値でなければならない）を持つオブジェクトを受け入れます．
もしオブジェクトに**余分なプロパティがある場合は無効となります**．よって，次のようなオブジェクトの場合では OK です．

<!-- Accepts objects that have a name property (which must be a string) and a isAdmin property (which must be a boolean). If the object has any extra properties, then it’s invalid. So this is OK: -->

```json:example OK
{ "name": "Abraham Lincoln", "isAdmin": true }
```

しかし，次のような場合では NG です．

<!-- But neither of these are: -->

```json:example NG; isAdmin must be boolean
{ "name": "Abraham Lincoln", "isAdmin": "yes" }
```

```json:example NG; extra key is invalid
{ "name": "Abraham Lincoln", "isAdmin": true, "extra": "stuff" }
```

#### Optional properties

プロパティが欠けていてもいいのであれば， `optionalProperties` を使うことができます．

<!-- If it’s OK for a property to be missing, then you can use optionalProperties: -->

```json:schema
{
  "properties": {
    "name": { "type": "string" },
    "isAdmin": { "type": "boolean" }
  },
  "optionalProperties": {
    "middleName": { "type": "string" }
  }
}
```

例えば，もしオブジェクトに `middleName` プロパティが含まれていれば，その値は文字列でなければなりません．しかし，そもそも `middleName` プロパティが含まれていなかった場合，それはそれとして OK と見做されます．
つまり，次のような場合は OK であると言えます：

<!-- If there’s a middleName property on the object, it has to be a string. But if there isn’t one, that’s OK. So these are valid: -->

```json:example OK
{ "name": "Abraham Lincoln", "isAdmin": true }
```

```json:example OK
{ "name": "William Sherman", "isAdmin": false, "middleName": "Tecumseh" }
```

一方で，次の場合はダメです：

<!-- But this is not: -->

```json:example NG
{ "name": "John Doe", "isAdmin": false, "middleName": null }
```

#### Extra properties

デフォルトでは，`properties` / `optionalProperties` は「追加」プロパティ，つまり〈スキーマで明示的に言及されていないプロパティ〉を許可しません．

<!-- By default, properties / optionalProperties does not permit for “extra” properties, i.e. properties not mentioned explicitly in the schema.  -->

余分なプロパティがあっても構わない場合は，`"additionalProperties": true` を使用してください．例えば次のように使います：

<!-- If you’re OK with extra properties, you can use "additionalProperties": true. For example: -->

```json:schema
{
  "properties": {
    "name": { "type": "string" },
    "isAdmin": { "type": "boolean" }
  },
  "additionalProperties": true
}
```

これは，次に示すオブジェクトを受け入れます：

<!-- Would accept: -->

```json:example OK
{ "name": "Abraham Lincoln", "isAdmin": true, "extra": "stuff" }
```

## `Values`

「キーはわからないが値のタイプはわかる」という辞書のような JSON オブジェクトを記述するには，`values` を使います．

<!-- To describe a JSON object that’s like a “dictionary”, where you don’t know the keys but you do know what type the values should have, use a “values” schema.  -->

`values` をキーとしたときの値は，別の JTD スキーマとなります．

<!-- The value of the values keyword is another JTD schema. For example, -->

```json:schema
{ "values": { "type": "boolean" } }
```

この例では，すべての値が _boolean_ であるオブジェクトを受け入れます．つまり，`{}` とか `{"a": true, "b": false}` は受け入れますが，`{"a": 1}` は拒否します．

<!-- Accepts objects where all the values are booleans. So it would accept {} or {"a": true, "b": false}, but not {"a": 1}. -->

## `Discriminator`

[タグ付きユニオン](https://en.wikipedia.org/wiki/Tagged_union)[^2]のように機能する JSON オブジェクトを記述するには， `discriminator` スキーマを使用します。
[^2]: 別名として，[判別可能な Union 型 (`discriminated union`)](https://typescript-jp.gitbook.io/deep-dive/type-system/discriminated-unions)，直和型(`sum type`) 等が挙げられる

<!-- To describe a JSON object that works like a tagged union (aka: “discriminated union”, “sum type”), use a “discriminator” schema. -->

`discriminator` スキーマには２つのキーワードがあります：

- `discriminator`: どのプロパティが _tag_ プロパティであるかを教える役割
- `mapping`: _tag_ プロパティの値に基づいて，どのスキーマを使用するかを示す役割

<!-- A “discriminator” schema has two keywords: discriminator tells you what property is the “tag” property, and mapping tells you what schema to use, based on the value of the “tag” property. -->

例えば，次のような「メッセージ」があったとします：

<!-- For example, let’s say you have messages that look like this: -->

```json:examples of message
{ "eventType": "USER_CREATED", "id": "users/123" }
{ "eventType": "USER_CREATED", "id": "users/456" }

{ "eventType": "USER_PAYMENT_PLAN_CHANGED", "id": "users/789", "plan": "PAID" }
{ "eventType": "USER_PAYMENT_PLAN_CHANGED", "id": "users/123", "plan": "FREE" }

{ "eventType": "USER_DELETED", "id": "users/456", "softDelete": false }
```

これらの「メッセージ」には，基本的に３つの種類があるとします．例えば **USER_CREATED** の実体は次のように表すとします：

<!-- Basically, there are three kinds of messages: USER_CREATED messages look like this: -->

```json:USER_CREATED
{
  "properties": {
    "id": { "type": "string" }
  }
}
```

**USER_PAYMENT_PLAN_CHANGED**, **USER_DELETED** についても同様に表現されているとしましょう：

<!-- USER_PAYMENT_PLAN_CHANGED messages look like this: -->

```json:USER_PAYMENT_PLAN_CHANGED
{
    "properties": {
        "id": { "type": "string" },
        "plan": { "enum": ["FREE", "PAID"]}
    }
}
```

<!-- And USER_DELETED messages look like this: -->

```json:USER_DELETED
{
    "properties": {
        "id": { "type": "string" },
        "softDelete": { "type": "boolean" }
    }
}
```

`discriminator` スキーマを使用すると，これら３つのスキーマをすべて結びつけることができ，さらに（この例の場合） _eventType_ の値に基づいてどれが関連しているかを JTD に伝えることができます．

<!-- With a “discriminator” schema, you can tie all three of those schemas together, and tell JTD that you decide which one is relevant based on the value of eventType.  -->

上述のいくつかの「メッセージ」に対するスキーマは次のとおりです：

<!-- So here’s the schema for our messages: -->

```json:schema
{
  "discriminator": "eventType",
  "mapping": {
    "USER_CREATED": {
      "properties": {
        "id": { "type": "string" }
      }
    },
    "USER_PAYMENT_PLAN_CHANGED": {
      "properties": {
        "id": { "type": "string" },
        "plan": { "enum": ["FREE", "PAID"] }
      }
    },
    "USER_DELETED": {
      "properties": {
        "id": { "type": "string" },
        "softDelete": { "type": "boolean" }
      }
    }
  }
}
```

このスキーマは，例に挙げたすべての「メッセージ」を受け入れます．

<!-- That schema would accept all of the messages in our example above.  -->

もし入力が _eventType_ プロパティを持っていなかったり， _eventType_ プロパティが `mapping` で記述されている３つの値のうちの一つでない場合，入力は拒否されます．

<!-- If the input doesn’t have a eventType property, or if the eventType property isn’t one of the three values mentioned in the mapping, then the input is rejected. -->

`mapping` 内に直にスキーマを記述できるのは， `properties`, `optionalProperties`, `additionalProperties` だけです．

<!-- You can only use properties / optionalProperties / additionalProperties in the schemas you put directly in mapping.  -->

**他の種類のスキーマを `mapping` 内に使用することはできません**．もし使うと "物事が曖昧になってしまう" からです．

<!-- You can’t use any other kind of schema, otherwise things would become ambiguous. -->

## `Ref`

あるサブスキーマを複数回再利用したい場合や，あるサブスキーマに特定の名前を付けたい場合があります．このような場合には，`ref` スキーマを使用することができます．

<!-- Sometimes, you want to re-use a sub-schema multiple times, or you want to give some sub-schema a particular name. You can use a “ref” schema to do this. -->

例を挙げて説明するのが一番簡単です，次のスキーマをみてください：

<!-- This is easiest to explain with an example. This schema: -->

```json:schema
{
    "definitions": {
        "coordinates": {
            "properties": {
                "lat": { "type": "float32" },
                "lng": { "type": "float32" }
            }
        }
    },
    "properties": {
        "userLoc": { "ref": "coordinates" },
        "serverLoc": { "ref": "coordinates" }
    }
}
```

このスキーマは次のオブジェクトを受け入れます：

<!-- Will accept things like: -->

```json:example OK
{ "userLoc": { "lat": 50, "lng": -90 }, "serverLoc": { "lat": -15, "lng": 50 }}
```

`{"ref": "coordinates"}` という部分は，基本的に `definitions` 内にある `coordinates` スキーマで「置き換え」られます．

<!-- The {"ref": "coordinates"} basically gets “replaced” by the coordinates schema in definitions. -->

`definitions` は JTD スキーマのルート（トップレベル）にしか現れないことに注意してください．それ以外の場所で `definitions` を持ってはいけません．

<!-- Note that definitions can only appear at the root (top level) of a JTD schema. It’s illegal to have definitions anywhere else. -->

# The `nullable` keyword

どんなスキーマでも，すなわちそれがいかなる「[形式](http://localhost:8000/articles/jtd-in-5-minutes#eight-forms)」であっても，`nullable` を付けることができます．また，それによって `null` がそのスキーマで受け入られうる値となります．

<!-- You can put nullable on any schema (regardless of which “form” it takes), and that will make null be an acceptable value for the schema. For example, -->

```json:schema
{ "type": "string" }
```

これは，`"foo"` を受け入れますが，`null` は拒否します．しかし，`"nullable": true` を付け足すことで……，

<!-- Will accept "foo" and reject null. But if you add "nullable": true, -->

```json:schema
{ "type": "string", "nullable": true }
```

このスキーマは `"foo"` と `null` の両方を受け入れるようになります．

<!-- That schema will accept both "foo" and null. -->

:::message
ただし， [`discriminator` における `mapping` 内](http://localhost:8000/articles/jtd-in-5-minutes#discriminator)においては，スキーマに `nullable` をつけることはできません．

<!-- Note: you can’t put nullable on a schema in a discriminator mapping.  -->

`discriminator` に `nullable` をつけたい場合は， `discriminator` や `mapping` キーワードと同じレベルに置いてください．

<!-- If you want a discriminator to be nullable, you have to put it at the same level as the discriminator and mapping keywords. -->

:::

# The `metadata` keyword

`metadata` キーワードはどのスキーマでも有効ですが，もし存在する場合は JSON オブジェクトでなければなりません．また，`metadata` は _validation_ に影響を与えません．

<!-- The metadata keyword is legal on any schema, and if it’s present it has to be a JSON object. There are no constraints on what you can put in metadata beyond that, and metadata has no effect on validation. -->

通常，`metadata` はコードジェネレータのための説明やヒントなど，ツールが利用できるようなものを置くためのものであることに留意してください．

<!-- Usually, metadata is for putting things like descriptions or hints for code generators, or other things tools can use. -->

# That’s it

あなたが生産的であるために JTD について知っておくべきことは，これですべてです！

<!-- That’s all you really need to know about JTD to be productive.  -->

もし JTD を使い始めようと思ってくれたなら，次のステップは[〈自分の好きなプログラミング言語での実装を見つけること〉](https://jsontypedef.com/docs/implementations/)となるでしょう．

<!-- If you want to get started using JTD, your next step would be to find an implementation in your preferred programming language. -->

# Refference

- [Learn JSON Typedef in 5 Minutes | JSON Type Definition](https://jsontypedef.com/docs/jtd-in-5-minutes/)
