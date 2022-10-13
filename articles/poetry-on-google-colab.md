---
title: "Google Colaboratory 上で Poetry の仮想環境をカーネルとして使う"
emoji: "🔥"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---

# TL; DR

以下の Gist に全部書いてあるので、こちらを見よ：

@[gist](https://gist.github.com/Ningensei848/dc0061f85966e16210ac49fd477c8dd1?file=poetry_on_google_colab.ipynb)

# Background

「AI 絵師」なるものの勃興により、手軽に実行できる `python` 環境の需要は高止まり状態にある。
Google Colaboratory は、計算環境のみならずクラウドストレージ（Google Drive）との相性も抜群で、誰もが必要不可欠な存在として認識している。

一方で、内部環境はかなり悪化しつつある； もとい、時代の変化に追随しきれていない部分がある。
例えば `python` について、バージョン 3.11 が GA しようかという段でも未だカビが生えかけた 3.7 を使っている。

機械学習を筆頭にどこでも必須である `NumPy` やら `Pandas` が軒並み 3.7 へのサポートを打ち切り始めていることからも、ことの深刻さが伝わるだろうか。
Google 公式がシステムアップデートを行なってくれればそれで済む話ではあるが、いつ来るかわからない機会をいつまでも待ち続けるわけには行かない。

---

このようなモチベーションを原点として、以下の課題に取り組んだ：

- なるたけ新しいバージョンの `python` が使えるようにする
- `jupyter` の利点を損なわない（セルに書いたコードを非同期・インタラクティブに実行する）
- `poetry` を使って `pyproject.toml` で管理する

# Imakita Industry

実際にノートブックで行なっていることを３行でまとめると、以下のようになる：

1. `.ipynb` を直接開き、 _"kernelspec"_ の欄に任意の識別名 (e.g. _"py39"_) を書き込む
2. [Google Colaboratory](https://colab.research.google.com/) における `Python` のバージョンを 3.7 から 3.9 にする
3. いい感じでパスを通した後 [`poetry`](https://python-poetry.org/) で仮想環境を作ってカーネルとして登録し、ランタイムの設定を反映させて完了！

これらの内容はすべて上述の [gist](https://gist.github.com/Ningensei848/dc0061f85966e16210ac49fd477c8dd1) にかかれているので、何も考えずポチポチ実行していくだけで 3.9 環境が手に入るだろう。

以下では、内容について詳細に解説してある。
もし興味があれば、一読してほしい。

1. _kernelspec_ を書き換える
2. `python` のバージョンを上げる
3. `poetry` を通じてカーネルを登録する

# 1. Rewrite _kernelspec_

Colab 上で `.ipynb` としてダウンロードしてきたノートブックは、 **テキストファイルとして開く**ことで直接編集できるようになる。

実体は JSON となっているのが見てわかるが、この内 `metadata` > `colab` > `kernelspec` を追記、あるいは既存のものを更新する。

![metadata.colab.kernelspec](https://github.com/Ningensei848/lifelog/blob/zenn/static/img/poetry-on-google-colab/ipynb_metadata_colab_kernelspec.png?raw=true)
_`display_name` に `python` 3.9 とつけておくと、後々わかりやすいかもしれない_

その後、編集済みの `.ipynb` を colab から読み直すことで準備が整う。

（ページ左上の \[ファイル\] > \[ノートブックを開く\]　をえらび、\[アップロード\]のタブから対象ファイルを選択すればよい）

ただしく読み込まれていれば、 「ランタイム `py39` は認識されていません」という警告が左下に表示される（**が、現時点では無視する**）。

![warning: kernel not found](https://github.com/Ningensei848/lifelog/blob/zenn/static/img/poetry-on-google-colab/ipynb_kernel_not_found_alert.png?raw=true)
_自動的につなぎ直してくれる優しさ、これが Google クォリティやなって……_

# 2. Version update of Python

任意のセルで `!python --version` と実行してもらえばわかるように、現時点（2022-10-12）での Colab 上の `python` は `3.7.x` となっている。

これをどうにかして `3.9.x` まで上げたい。

色々やり方はあるが、標準的な `python` で準備しようとすると依存解決のところでコケてしまうことがある。

:::message

`python 3.10.7`, `pip 22.2.2 (from python 3.10)` を認識している `poetry` で　 `pandas==0.24.2` を入れようとすると、以下のエラーが出てしまう……

（最新の `pandas` ならおそらく問題はないが、 Colab を使うために必要な `google-colab==1.0.0` の依存先は `pandas==0.24.x` であるから、依存解決しようとしてエラーを吐いて止まる）

:::details エラーの詳細

> ERROR: Could not build wheels for pandas, which is required to install pyproject.toml-based projects

```shell
  • Removing cachetools (5.2.0): Pending...
  • Removing cachetools (5.2.0): Removing...
  • Removing cachetools (5.2.0)
  • Removing certifi (2022.9.24): Pending...
  • Removing certifi (2022.9.24): Removing...
  • Removing certifi (2022.9.24)
  • Removing chardet (3.0.4): Pending...
  • Removing chardet (3.0.4): Removing...
  • Removing chardet (3.0.4)
  • Removing google-auth (1.4.2): Pending...
  • Removing google-auth (1.4.2): Removing...
  • Removing google-auth (1.4.2)
  • Removing idna (2.8): Pending...
  • Removing idna (2.8): Removing...
  • Removing idna (2.8)
  • Removing portpicker (1.2.0): Pending...
  • Removing portpicker (1.2.0): Removing...
  • Removing portpicker (1.2.0)
  • Removing pyasn1 (0.4.8): Pending...
  • Removing pyasn1 (0.4.8): Removing...
  • Removing pyasn1 (0.4.8)
  • Removing pyasn1-modules (0.2.8): Pending...
  • Removing pyasn1-modules (0.2.8): Removing...
  • Removing pyasn1-modules (0.2.8)
  • Removing requests (2.21.0): Pending...
  • Removing requests (2.21.0): Removing...
  • Removing requests (2.21.0)
  • Removing rsa (4.9): Pending...
  • Removing rsa (4.9): Removing...
  • Removing rsa (4.9)
  • Removing urllib3 (1.24.3): Pending...
  • Removing urllib3 (1.24.3): Removing...
  • Removing urllib3 (1.24.3)
  • Installing pandas (0.24.2): Pending...
  • Installing pandas (0.24.2): Installing...
  • Installing pandas (0.24.2): Failed

  CalledProcessError

  Command '['/content/.venv/bin/python', '-m', 'pip', 'install', '--use-pep517', '--disable-pip-version-check', '--prefix', '/content/.venv', '--no-deps', '/root/.cache/pypoetry/artifacts/11/24/30/f092cb04f54c456635068c3b48ccd078819f1d4f7078d0e80cd79d4546/pandas-0.24.2.tar.gz']' returned non-zero exit status 1.

  at /usr/lib/python3.10/subprocess.py:524 in run
       520│             # We don't call process.wait() as .__exit__ does that for us.
       521│             raise
       522│         retcode = process.poll()
       523│         if check and retcode:
    →  524│             raise CalledProcessError(retcode, process.args,
       525│                                      output=stdout, stderr=stderr)
       526│     return CompletedProcess(process.args, retcode, stdout, stderr)
       527│
       528│

The following error occurred when trying to handle this error:


  EnvCommandError

  Command ['/content/.venv/bin/python', '-m', 'pip', 'install', '--use-pep517', '--disable-pip-version-check', '--prefix', '/content/.venv', '--no-deps', '/root/.cache/pypoetry/artifacts/11/24/30/f092cb04f54c456635068c3b48ccd078819f1d4f7078d0e80cd79d4546/pandas-0.24.2.tar.gz'] errored with the following return code 1, and output:
  Looking in indexes: https://pypi.org/simple, https://us-python.pkg.dev/colab-wheels/public/simple/
  Processing /root/.cache/pypoetry/artifacts/11/24/30/f092cb04f54c456635068c3b48ccd078819f1d4f7078d0e80cd79d4546/pandas-0.24.2.tar.gz
    Installing build dependencies: started
    Installing build dependencies: finished with status 'done'
    Getting requirements to build wheel: started
    Getting requirements to build wheel: finished with status 'done'
    Installing backend dependencies: started
    Installing backend dependencies: finished with status 'done'
    Preparing metadata (pyproject.toml): started
    Preparing metadata (pyproject.toml): finished with status 'done'
  Building wheels for collected packages: pandas
    Building wheel for pandas (pyproject.toml): started
    error: subprocess-exited-with-error

    × Building wheel for pandas (pyproject.toml) did not run successfully.
    │ exit code: 1
    ╰─> See above for output.

    note: This error originates from a subprocess, and is likely not a problem with pip.
    Building wheel for pandas (pyproject.toml): finished with status 'error'
    ERROR: Failed building wheel for pandas
  Failed to build pandas
  ERROR: Could not build wheels for pandas, which is required to install pyproject.toml-based projects


  at ~/.local/share/pypoetry/venv/lib/python3.10/site-packages/poetry/utils/env.py:1476 in _run
      1472│                 output = subprocess.check_output(
      1473│                     command, stderr=subprocess.STDOUT, env=env, **kwargs
      1474│                 )
      1475│         except CalledProcessError as e:
    → 1476│             raise EnvCommandError(e, input=input_)
      1477│
      1478│         return decode(output)
      1479│
      1480│     def execute(self, bin: str, *args: str, **kwargs: Any) -> int:

The following error occurred when trying to handle this error:


  PoetryException

  Failed to install /root/.cache/pypoetry/artifacts/11/24/30/f092cb04f54c456635068c3b48ccd078819f1d4f7078d0e80cd79d4546/pandas-0.24.2.tar.gz

  at ~/.local/share/pypoetry/venv/lib/python3.10/site-packages/poetry/utils/pip.py:51 in pip_install
       47│
       48│     try:
       49│         return environment.run_pip(*args)
       50│     except EnvCommandError as e:
    →  51│         raise PoetryException(f"Failed to install {path.as_posix()}") from e
       52│
```

:::

唯一成功したパターンを紹介する： `miniconda` を採用するパターンだ。

```terminal
wget -O mini.sh https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh
chmod +x mini.sh
bash ./mini.sh -b -f -p /usr/local
```

cf. [Google Colaboratory の Python 実行環境をアップデートする](https://zenn.dev/tk42/articles/92e34bb8910fd9)
https://zenn.dev/tk42/articles/92e34bb8910fd9

[このページ](https://repo.anaconda.com/miniconda)から必要なヴァージョンを見繕い、それをインストールするシェルスクリプトを適当に配置して実行している。

定期的に追加されているが、それでも半年に一度くらいのペースなので 3.10 への対応はまだ先になるだろう。

https://repo.anaconda.com/miniconda

---

さらに、Google Colaboratory を動かすのに必要なライブラリも **`conda install` を用いて** インストールする。

```terminal
conda install -q -y jupyter
conda install -q -y google-colab -c conda-forge
```

ここまでで、 `python` の更新とカーネル変更の受け入れ体制が整った。

:::message
カーネルを切り替えた際に、これらのライブラリが存在していない場合は **自動的にセッションがクラッシュ** する。

**ランタイムを再起動しても _kernelspec_ に書いてあるカーネルにつなぎ直そうとし続けるので、永遠に接続できない状態に陥る**。

一旦削除して最初からやり直す羽目になるので、上記ライブラリ群は必ずインストールすること。
:::

# 3. Register kernel derived from `poetry`

次は、 インストールした `python` に依存する `poetry` もインストールして、**その仮想環境を実体とするカーネルを登録する**。

1. `poetry` のインストール
2. `poetry` の設定
3. カーネルを登録

という流れになる。

まず、`poetry` をインストールする。
公式ドキュメントに従って、以下のコマンドを実行すればよい。

```shell
curl -sSL https://install.python-poetry.org | python -
```

https://python-poetry.org/docs/#installation

`cURL` で持ってきたスクリプトをそのまま `python` に渡して実行させている。

:::message
少し昔には "get-poetry.py" やら "install-poetry.py" がスクリプトと指定されていたが、そちらはもう _deprecated_ であることに留意されたい。
:::

---

さて、無事にインストールできたあとは `poetry` の設定を行なう必要がある。

a. 実行パスを通す
b. カレントディレクトリ直下に `.venv` フォルダをつくる
c. グローバルな `python` に存在するライブラリを使えるようにする

```jupyter
# python の変数宣言とコマンド実行が混じっていることに注意せよ

os.environ['PATH'] = f"/content/.venv/bin:/root/.local/bin:{os.environ['PATH']}"

!poetry --version
!which poetry

# 任意の場所に .venv フォルダを作り仮想環境を管理したい
!poetry config virtualenvs.in-project true

# グローバルな `python` に存在するライブラリを使えるように
!poetry config virtualenvs.options.system-site-packages true
```

パスを通す方法として、 CLI とは全く異なるアプローチになっていることに注目してほしい。
この方法でも変数 PATH は同ランタイム中であれば永続するし、適宜動的に追加・削除することができるようになるため便利である。

また、`/content/.venv/bin` を最優先とすることで、仮想環境を作ったあとで実行する `python` コマンドはすべて `.venv` 内に含まれる `python` を参照するようになる

（加えて、`/root/.local/bin` は `poetry` を実行するために必要なパスである）

そして、キモとなるのは `--system-site-packages` を `true` にして仮想環境を作るというところだろう。
これがないと、`conda` でインストールした必須ライブラリ群を認識することができず、無限クラッシュ編に突入してしまう。
もちろん `poetry` でそれらをインストールしようとしても、上述の依存解決エラーが起こってしまう。

コードの実行に必要なライブラリ管理は `poetry` で行いつつ、 Colab を動かす必須ライブラリについては特に意識させないために、この設定が必要だといえよう。

---

最後にカーネルを登録する。

```terminal
poetry install
poetry add ipykernel
poetry run python -m ipykernel install --name "py39" --user
```

`poetry install` は `.venv` を作成するコマンドだが、**`pyproject.toml` がないと動作しない**。

`poetry init` でインタラクティブに作成するか、任意のセル上でファイルを作成しておくといいだろう。

:::details pyproject.toml (ver. vanilla)

```pyhton
# @title `pyproject.toml` を準備する
# @markdown ※このノートブックではひとまずデフォルト設定のままとしておく

import os
import sys

PYPROJECT_TOML = """
[tool.poetry]
name = "content"
version = "0.0.0"
description = ""
authors = ["Your Name <you@example.com>"]
readme = "README.md"

[tool.poetry.dependencies]
python = "^3.9"


[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

"""

with open("/content/pyproject.toml", mode='w') as f:
    f.write(PYPROJECT_TOML)
```

:::

---

これで、カーネル登録が完了した。

以下のコマンドを実行すれば、実際に登録できているのか・どこにあるのか・実体は何なのかが見て取れるだろう：

```terminal
# 利用可能なカーネルの一覧を表示
jupyter kernelspec list
ls -la /root/.local/share/jupyter/kernels/py39
cat /root/.local/share/jupyter/kernels/py39/kernel.json
```

:::details expected stdouts

```terminal
Available kernels:
  py39       /root/.local/share/jupyter/kernels/py39
  ir         /usr/local/share/jupyter/kernels/ir
  python3    /usr/local/share/jupyter/kernels/python3

total 32
drwxr-xr-x 2 root root 4096 Oct 13 06:30 .
drwxr-xr-x 3 root root 4096 Oct 13 06:30 ..
-rw-r--r-- 1 root root  196 Oct 13 06:30 kernel.json
-rw-r--r-- 1 root root 1084 Oct 13 06:30 logo-32x32.png
-rw-r--r-- 1 root root 2180 Oct 13 06:30 logo-64x64.png
-rw-r--r-- 1 root root 9605 Oct 13 06:30 logo-svg.svg

{
 "argv": [
  "/content/.venv/bin/python",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "py39",
 "language": "python",
 "metadata": {
  "debugger": true
 }
}
```

:::

`jupyter/kernels/py39/kernel.json` の中身を見て `argv` が `/content/.venv/bin/python` で始まっていれば成功だ。

# Swich runtime

現在接続しているカーネルから切り替えることで初めて、今回登録したカーネルが認識されることになる。

\[ランタイム\] > \[ランタイムのタイプを変更\] から、_kernelspec_ で指定した名前に変更して\[保存\]するだけでよい

最後に、再度セルを実行してなんの警告もでなければ成功！

```python
import sys

# カーネルが py39 を認識していない場合、こちらは 3.7.x と表示される
print("User Current Version:-", sys.version)
print(sys.executable)
```

![User Current Version:- 3.9.1 (default, Dec 11 2020, 14:32:07)](https://github.com/Ningensei848/lifelog/blob/zenn/static/img/poetry-on-google-colab/ipynb_kernel_new_version.png?raw=true)
_セルで実行している python 実体のバージョンと所在_

# Summary

1. Colab 上で実行する `python` のバージョンを 3.7 から 3.9 に更新
2. `poetry` を導入して仮想環境を作成
3. 仮想環境をカーネルに登録してライブラリを管理

# Future work

- `miniconda` を使わないアプローチ
- `python` >3.9 への対応
- 別ウィンドウにフォーカスを移してから再度戻ってきて実行すると、うまく動作しないときがある（Colab 側の frontend の問題？）
