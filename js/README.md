# Asciidoctor Tabs

An Asciidoctor.js extension that adds a tabs block to the AsciiDoc syntax.

## Install

This package depends on the `asciidoctor` package, but does not declare it as a dependency.
Therefore, you must install that package when installing this package.

```console
npm i asciidoctor @asciidoctor/tabs
```

## Syntax

```asciidoc
[tabs]
====
Tab A::
+
Contents of tab A.

Tab B::
+
--
Contents of tab B.

Contains more than one block.
--
====
```

## Usage

```console
npx asciidoctor -r @asciidoctor/tabs document-with-tabs.adoc
```

The `asciidoctor` command automatically registers the tabs extension group when the package is required.

## Copyright and License

Copyright (C) 2018-present Dan Allen (OpenDevise Inc.) and the individual contributors to this project.
Use of this software is granted under the terms of the MIT License.
