'use strict'

const { Builder } = require('opal-compiler')
const fs = require('fs')

const transpiled = Builder
  .create()
  .build('../lib/asciidoctor/tabs/block.rb')
  .build('../lib/asciidoctor/tabs/docinfo.rb')
  .build('../lib/asciidoctor/tabs/extensions.rb')
  .toString()

fs.mkdirSync('dist', { recursive: true })
fs.writeFileSync('dist/index.js', transpiled)

fs.mkdirSync('data', { recursive: true })
fs.cpSync('../data', 'data', { recursive: true })
