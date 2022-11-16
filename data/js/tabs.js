/*! Asciidoctor Tabs | Copyright (c) 2018-present Dan Allen | MIT License */
;(function () {
  'use strict'

  var fragment = decodeFragment(window.location.hash)
  find('.tabset').forEach(function (tabset) {
    var active
    var tabs = tabset.querySelector('.tabs')
    if (tabs) {
      var first
      find('li', tabs).forEach(function (tab, idx) {
        var id = (tab.querySelector('a[id]') || tab).id
        if (!id) return
        var pane = tabset.querySelector('.tab-pane[aria-labelledby~="' + id + '"]')
        if (!pane) return
        if (!idx) first = { tab: tab, pane: pane }
        if (!active && fragment === id && (active = true)) {
          tab.classList.add('is-active')
          if (pane) pane.classList.add('is-active')
        } else if (!idx) {
          tab.classList.remove('is-active')
          if (pane) pane.classList.remove('is-active')
        }
        tab.addEventListener('click', activateTab.bind({ tabset: tabset, tab: tab, pane: pane }))
      })
      if (!active && first) {
        first.tab.classList.add('is-active')
        if (first.pane) first.pane.classList.add('is-active')
      }
    }
    tabset.classList.remove('is-loading')
  })

  function activateTab (e) {
    var tab = this.tab
    var pane = this.pane
    find('.tabs li, .tab-pane', this.tabset).forEach(function (it) {
      it === tab || it === pane ? it.classList.add('is-active') : it.classList.remove('is-active')
    })
    window.history.replaceState(null, '', '#' + tab.id)
    e.preventDefault()
  }

  function decodeFragment (hash) {
    return hash && (~hash.indexOf('%') ? decodeURIComponent(hash.slice(1)) : hash.slice(1))
  }

  function find (selector, from) {
    return Array.prototype.slice.call((from || document).querySelectorAll(selector))
  }
})()
