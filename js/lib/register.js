'use strict'

module.exports.register = (registry) => {
  Opal.Asciidoctor.Tabs.Extensions.$register(registry)
}
