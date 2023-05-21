'use strict'

const { env: ENV } = require('node:process')
const fs = require('node:fs')
const ospath = require('node:path')

let opalCompilerPath = 'opal-compiler'
try {
  require.resolve(opalCompilerPath)
} catch {
  const npxInstallDir = ENV.PATH.split(':')[0]
  if (npxInstallDir?.endsWith('/node_modules/.bin') && npxInstallDir.startsWith(ENV.npm_config_cache + '/')) {
    opalCompilerPath = require.resolve('opal-compiler', { paths: [ospath.dirname(npxInstallDir)] })
  }
}

const transpiled = require(opalCompilerPath).Builder
  .create()
  .build('../lib/asciidoctor/tabs/block.rb')
  .build('../lib/asciidoctor/tabs/docinfo.rb')
  .build('../lib/asciidoctor/tabs/extensions.rb')
  .toString()
fs.mkdirSync('dist', { recursive: true })
fs.writeFileSync('dist/index.js', transpiled)
fs.cpSync('../data', 'dist', { recursive: true })
