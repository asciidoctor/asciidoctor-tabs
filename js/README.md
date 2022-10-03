# Asciidoctor Tabs

An Asciidoctor.js extension that adds a tabs block to the AsciiDoc syntax.

## Install

This package depends on the `asciidoctor` package (>= 2.2.0, < 3.0.0), but does not declare it as a dependency.
Therefore, you must install that package when installing this package.

```console
$ npm i asciidoctor @asciidoctor/tabs
```

## Syntax

```asciidoc
[tabs]
====
Tab A:: Contents of tab A.

Tab B::
+
Contents of tab B.

Tab C::
+
--
Contents of tab C.

Contains more than one block.
--
====
```

## Usage

### CLI

```console
$ npx asciidoctor -r @asciidoctor/tabs document-with-tabs.adoc
```

The `asciidoctor` command automatically registers the tabs extension group when the package is required.

### API

There are two ways to use the extension with the Asciidoctor.js API.
In each case, you must require the Asciidoctor.js module before requiring this extension.

You can call the exported `register` method with no arguments to register the extension as a global extension.

```js
const Asciidoctor = require('asciidoctor')()

require('@asciidoctor/tabs').register()

Asciidoctor.convertFile('document-with-tabs.adoc', { safe: 'safe' })
```

Or you can pass a registry to the `register` method to register the extension with a scoped registry.

```js
const Asciidoctor = require('asciidoctor')()

const registry = Asciidoctor.Extensions.create()
require('@asciidoctor/tabs').register(registry)

Asciidoctor.convertFile('document-with-tabs.adoc', { extension_registry: registry, safe: 'safe' })
```

You can also require `@asciidoctor/tabs/extensions` to access the `Extensions` class.
Attached to that object are the `Block`, `Docinfo.Styles`, and `Docinfo.Behavior` extension classes.
You can use these classes to register a bespoke tabs extension.

## Copyright and License

Copyright (C) 2018-present Dan Allen (OpenDevise Inc.) and the individual contributors to this project.
Use of this software is granted under the terms of the MIT License.
