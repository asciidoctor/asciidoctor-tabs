'use strict'

require('../dist')

const { Block, Docinfo, Extensions } = Opal.Asciidoctor.Tabs

module.exports = Object.assign(Extensions, { Block, Docinfo })
