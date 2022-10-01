'use strict'

module.exports.register = (registry) => {
  const Tabs = Opal.Asciidoctor.Tabs
  const toProc = (fn) => Object.defineProperty(fn, '$$arity', { value: fn.length })
  const extGroup = toProc(function () {
    this.block('tabs', Tabs.Block)
    if (this.document.hasAttribute('embedded')) return
    this.docinfoProcessor(Tabs.Docinfo.Styles)
    this.docinfoProcessor(Tabs.Docinfo.Behavior)
  })
  registry.$groups().$send('[]=', 'tabs', extGroup)
}
