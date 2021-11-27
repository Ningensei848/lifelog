---
title: "SPARQL のための型安全なバリデータをつくった"
emoji: "🦾"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["sparql", "JSONTypedDefinition", "validation", "JTD"]
published: true
---

:::message
この記事は [Linked Open Data Challenge 2021 (LOD チャレンジ 2021)](https://2021.lodc.jp/entry.html) の **データ活用部門** にエントリーしています
:::

# JTD によるスキーマ定義

`sparqlQueryResult.jtd.json` としてスキーマを定義しました．その際に [SPARQL 1.1 Query Results JSON Format | W3C Recommendation 21 March 2013](http://www.asahi-net.or.jp/~ax2s-kmtn/internet/rdf/REC-sparql11-results-json-20130321.html) の和訳版を参照しています．また，スキーマを記述する際の規格としては，[JSON Typed Definition](https://jsontypedef.com/) [^1] を採用しました．

[^1]: [RFC 8927](https://datatracker.ietf.org/doc/rfc8927/) _(Experimental)_

:::details sparqlQueryResult.jtd.json
@[gist](https://gist.github.com/Ningensei848/7c5806189f5734932c45bf201830beae?file=sparqlQueryResult.jtd.json)
:::

# Ajv による型安全なバリデータの生成

:::message
理想的には，スクリプトの外部に `sparqlQueryResult.jtd.json` を置き，そこからスキーマを静的にインポートして _const assertion_ したいと考えられます．しかし TypeScript 側の仕様上の都合もあり，いまだ実現されていません（2021 年 11 月末現在）[^2]
:::

[^2]: ただし，[ぜひとも標準機能としてほしいという声が多数あり](https://github.com/microsoft/TypeScript/issues/32063)，遠からず実現する可能性がある

上述したスキーマ定義を `schema.ts` としてスクリプト上に移植します．

::: details schema.ts
@[gist](https://gist.github.com/Ningensei848/7c5806189f5734932c45bf201830beae?file=schema.ts)
:::

`schema.ts` 内で _const assertion_ されたことで，`JSONResponseSchema` オブジェクトが _NonWidening_ な _Literal Types_ として得られました．

## Ajv: JSON Validator

JavaScript における老舗 validator である [Ajv](https://ajv.js.org/guide/typescript.html#utility-type-for-jtd-data-type) は，この _Literal Types_ を "いい感じに解釈して変換" する `JTDDataType` という _Utility Types_ を持っています．すなわち，`JTDDataType` にリテラル化したスキーマ定義を渡してやるだけで，本来我々が必要としていた〈TypeScript における型定義〉および 〈**型安全なバリデータ**〉 [^3]が手に入ることになります．やったぜ．

[^3]: なお，ついでに[パーサーとシリアライザも手に入る](https://ajv.js.org/guide/typescript.html#type-safe-parsers-and-serializers)し，これらもまた型安全です

::: details validator.ts
@[gist](https://gist.github.com/Ningensei848/7c5806189f5734932c45bf201830beae?file=validator.ts)
:::

# 他の言語への流用

本記事では TypeScript にのみ焦点を当てましたが，JTD を採用して定義されたスキーマは他にも **Python** や **Ruby**, **Java**, **Golang**, **C#** 果ては**Rust** といった言語にも転用することができます．これでフロントエンド側の TypeScript とバックエンド側の Java / Ruby / Go 等でも同じスキーマを使えますし，Python / C# / Rust 等でリクエストを投げてデータ分析する際にも，より型安全にハンドリングすることができるでしょう．

（※実装の詳細については[こちら](https://jsontypedef.com/docs/implementations)を参照のこと）

https://jsontypedef.com/docs/implementations

# demo

@[stackblitz](https://stackblitz.com/edit/react-ts-rbngxp?embed=1&file=Demo.tsx&hideExplorer=1&view=preview)
