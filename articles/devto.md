---
title: "Ajv × JTD: Get Typedefs and its Validator at the Same Time"
published: false
topics: ["Ajv", "JSONTypedDefinition", "JTD", "validation", "TypeScript"]
cover_image: https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ytbixlgalliwp8hqiymy.png
emoji: "🔍"
type: "tech" # tech: 技術記事 / idea: アイデア
---

## TL; DR

1. Introduce [Ajv](https://ajv.js.org/) JSON Validator
2. and adopt [JSON Typed Definition](https://jsontypedef.com/)
3. Cross-platform **typed definitions** and **validators** at your fingertips!

Note: This article you reading has been written with reference to [this page](https://ajv.js.org/guide/getting-started.html).

## Introduction

It is adopted as a common standard for both the front-end and the back-end, and is universally understandable and writable by many people ―――

In programming, data structures can take many forms, depending on their use; e.g. CSV / XML / YAML / TOML. While there are many examples of these, none are as widespread or as easily understood by everyone as JSON. It is often used for human reading and writing, as well as for client-server interaction.

![a computer on a network exchanging data with a smartphone or PC](https://4.bp.blogspot.com/-dVbfTZcofUU/VGX8crT5GiI/AAAAAAAApG4/CB7GF5UmMqE/s400/computer_cloud_system.png)

On the other hand, its flexibility also makes it difficult to handle safely: When communicating with an arbitrary API server and receiving data, it's common to give up defining type of the response and treat it as `any` type. In this way, the data can be received, but the subsequent handling will be difficult.

This is when you want a _validator_, a device that verifies and guarantees the correctness of your data. Validators can be used to detect and successfully handle property excess or deficiency and invalid values.

![Illustration of a female detective, like Sherlock Holmes, holding a magnifying glass and investigating for clues](https://4.bp.blogspot.com/-ZxdZh4JD7XM/VnE3E_EWN3I/AAAAAAAA1xA/5Zpsqd6hu0I/s400/job_tantei_woman.png)

Of course, it's possible to code it yourself from scratch, for the sake of experience, but we'd rather use a framework that already exists ! In this article, introducing [Ajv](https://ajv.js.org) as a JSON validator library for JavaScript / TypeScript. I would also show you how to define a innovative schema, called [JSON Typed Definition](https://jsontypedef.com/).

Note: JSON Typed Definition is proposed in [RFC8927](https://datatracker.ietf.org/doc/rfc8927/) and its current status is `Experimental`.

## What is Ajv ?

![Ajv JSON schema validator | Security and reliability for JavaScript applications](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kl6vdjf0kget5aq2cui9.png)

{% details  read more ... %}

[Ajv](https://ajv.js.org/) is a JSON validator used in a general JavaScript environment. It has the following three features :

### 1. Write less code

> Ensure your data is valid as soon as it's received
>
> Instead of having your data validation and sanitization logic written as lengthy code, you can declare the requirements to your data with concise, easy to read and cross-platform JSON Schema or JSON Type Definition specifications and validate the data as soon as it arrives to your application.
>
> TypeScript users can use validation functions as type guards, having type level guarantee that if your data is validated - it is correct.

### 2. Super fast & secure

> Compiles your schemas to optimized JavaScript code
>
> Ajv generates code to turn JSON Schemas into super-fast validation functions that are efficient for v8 optimization.

In the early days it was very popular for its speed and rigor, but it also had many security flaws. However, over the years and with the help of many user reports, these flaws have been fixed and secure code generation has been re-established in v7.

### 3. Multi-standard

> Use JSON Type Definition or JSON Schema
>
> In addition to the multiple JSON Schema drafts, including the latest draft 2020-12, Ajv has support for JSON Type Definition - a new RFC8927 that offers a much simpler alternative to JSON Schema.
> Designed to be well-aligned with type systems, JTD has tools for both validation and type code generation for multiple languages.

{% enddetails %}

## Before you start with Ajv ...

On JTD, the schema is defined using eight different _forms_ e.g. `Properties` / `Elements` / `Values` etc.. If you would like to know more about these first, please see [this article](https://jsontypedef.com/docs/jtd-in-5-minutes/).

- [Learn JSON Typedef in 5 Minutes | JSON Typedef Docs](https://jsontypedef.com/docs/jtd-in-5-minutes/)

## Getting started with Ajv on JTD

So let's get started with Ajv!

First of all, we need to install the `npm` package:

```shell
npm install ajv
# or
yarn add ajv
```

Before you can actually validate in Ajv, you need to go through the following steps:

1. define your schema on JSON Typed Definition
2. get the type definition from the schema object by using _"utility types"_
3. initialize the `Ajv()` constructor (and do some configurations)
4. get a validator (+{% katex inline %}\alpha{% endkatex %}) from the type definition

Let's look at them in turn!

## 1. Define your schema on JSON Typed Definition

First, here is an example of a schema definition on JSON Typed Deifinition.

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

Some of you may have noticed `as const` at the end of the code. This feature is called [_const assertion_](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions), implemented since TypeScript 3.4.

{% details more descriptions ... %}

TypeScript has a feature called _type assertion_ by `as`, which explicitly overriding an inferred type. In the case of _const assertion_, which is an extension of _type assertion_, it causes the following effects:

```typescript
// Type '"hello"'
let x = "hello" as const;
// Type '{ readonly text: "hello" }'
let z = { text: "hello" } as const;
// Type 'readonly [10, 20]'
let y = [10, 20] as const;
```

- Literals in expressions are not extended
- _object_ literals become (recursively all) read-only properties
- _array_ literal becomes a read-only tuple

{% enddetails %}

Thanks to this feature, the schema is cast as follows:

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

All properties are now `readonly`, and each `type` property is now defined as a literal (`"int32"`, `"string"`) instead of `string;` !

## 2. Get the type definition from the schema object by using _"utility types"_

Now, we have the variable `schema`, which is type-asserted via `as const`. What if we further apply the `typeof` operator to this variable? It is also used in [type guards](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#typeof-type-guards), which are often used to determine `undefined`; that is, the `typeof` operator is used to get the type of a variable `schema`.

```ts
type MyData = JTDDataType<typeof schema>;
```

Next, `typeof schema` is passed as an argument to `JTDataType<T>`, which is provided by the Ajv as [_utility types_](https://www.typescriptlang.org/docs/handbook/utility-types.html) .

> Utility types are types that derive another type from a type; if functions are functions in the runtime world, then utility types are functions in the type world.
> cf. [book.yyts.org](https://book.yyts.org/reference/type-reuse/utility-types)

That is, `JTDataType<T>` convert from the argument `typeof schema` to `MyData`. At this point, this type definition has been cast as follows:

```ts
type MyData = {
  foo: number;
} & {
  bar?: string | undefined;
};
```

🤔?🤔?🤔?🤔?🤔?🤔?🤔?🤔?🤔?🤔?🤔?🤔?

![I'm sure you don't understand what I'm saying, but I don't understand it either - Jean Pierre Polnareff (JoJo's Bizarre Adventure Part 3. Stardust Crusaders)](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/nk303a2bzhp9ok63805o.png)

＿人人人人人人人人人人人人人人人人人人＿
＞ **When we defined the schema in JTD,** ＜
￣ Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y ￣

＿人人人人人人人人人人人人人人人人人人人人＿
＞ **we also finished defining the TS typedefs!** ＜
￣ Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y ￣

## 3. Initialize the `Ajv()` constructor (and do some configurations)

Let's calm down for a moment and think about the following ...

```js
// import Ajv from "ajv"; // <----- not for JTD
import Ajv from "ajv/dist/jtd";
const ajv = new Ajv();
```

Here, we import the necessary modules and initialize the constructor. Note that the source of this import is `ajv/dist/jtd`, since JTD is used. If you want to add more settings, you can pass [Option](https://ajv.js.org/options.html#usage) as an argument to the constructor.

```ts
/*
 * For example, to report all validation errors (rather than failing on the first errors)
 * you should pass allErrors option to constructor:
 */
const ajv = new Ajv({ allErrors: true });
```

## 4. Get a validator (+{% katex inline %}\alpha{% endkatex %}) from the type definition

The `compile` constructor method can be used to convert a schema definition into a validator function.

```ts
// type inference is not supported for JTDDataType yet
const validate = ajv.compile<MyData>(schema);
```

What a surprise! 🤣 Just by defining the schema on JTD, we got a TypeScript typedef and a validator that uses it.

```ts
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

This is the beauty of Ajv on JTD. The amount of writing is much less, just like the goal of **_Write less code_**.

---

And there's more good news! Ajv also provide `compileParser` and `compileSerializer` to meet the demand for a "more type-safe" parser and serializer. In other words, we can now do `JSON.parse()` / `JSON.stringfy()` in a more type-safe way.

```ts
const parse = ajv.compileParser<MyData>(schema);
const serialize = ajv.compileSerializer<MyData>(schema);
```

{% collapsible how to parse / serialize %}

```ts
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

{% endcollapsible %}

Excellent!

## _JSON Typed Definition Validator_

"OK, I'll give JTD a go!", this thought occurred to me at the end of last month. However, at the time, I had no idea how to define scheme on JSON Typed Definition. I even tried to translate [the official explanations](https://jsontypedef.com/docs/jtd-in-5-minutes/) into [my native language](https://zenn.dev/ningensei848/articles/jtd-in-5-minutes) to get a better understanding, but it didn't feel quite right. Or, to start with, it was bad for me because I didn't know if the schema definition was correct or not until I actually ran the code.

🤮

I couldn't just give up here, so I decided to build my own webApp using Next.js, which I've been working on a lot lately.

![JSON Typed Definition Validator](https://storage.googleapis.com/zenn-user-upload/28c4a3872b4e44ea7e1d88ed.png)

_Next.js + TypeScript + Mui + CodeMirror_ [on Vercel](https://jtd-validator.vercel.app/)

Please try it! And I would love it if you gave me a star or something! 🥳

## Conclusion

So far, we have actually done the following two things:

1. Schema definition based on _JSON Typed Definition_
2. Initial configuration of _Ajv_

Here's what we got out of these:

1. **typedefs** in TypeScript derived from _JTD_
2. type-safe **_Validator_** based on 1.
3. type-safe **_Parser_** based on 1.
4. type-safe **_Serializer_** based on 1.

![Illustrations of so-called "god" who have descended on the internet to pass on useful information](https://2.bp.blogspot.com/-y2bo0WxJCiU/V4-O0nuVH0I/AAAAAAAA8Zc/lxv7lgGGBY49qw7jBMhMkQpH-sC1qfn3ACLcB/s500/internet_god.png)

> _JSON Typed Definition brings type-safety_

Haha! After all the hard work and effort in the past, we can now get """everything""" just by defining the schema on JTD. 🥲

I hope you enjoy the best schema-driven development tomorrow with [**_JSON Typed Definition_**](https://jsontypedef.com/) and [**_Ajv JSON Validator_**](https://ajv.js.org/)! 👍

![TypeScript × Ajv × JSON Typed Definition](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dpy2nbr6uiq9wxcn4dra.png)

### 追記１

[JSON Typed Definition の未来の話](https://zenn.dev/link/comments/bf72e86ed6ce37) という _small idea_ をスクラップとして残したので，TypeScript ガチ勢の知見をぜひともお借りしたい
https://zenn.dev/link/comments/bf72e86ed6ce37
