;(function () { /*! Asciidoctor Tabs | Copyright (c) 2018-present Dan Allen | MIT License */
  'use strict'

  init(find('.tabset'))

  function init (tabsets) {
    if (!tabsets.length) return
    var fragment = decodeFragment(window.location.hash)
    tabsets.forEach(function (tabset) {
      var tabs = tabset.querySelector('.tabs')
      if (!tabs) return tabset.classList.remove('is-loading')
      var active, first
      find('li', tabs).forEach(function (tab, idx) {
        var id = tab.id
        if (!id) {
          var anchor = tab.querySelector('a[id]')
          if (!anchor) return // invalid state
          tab.id = id = anchor.parentNode.removeChild(anchor).id
        }
        tab.className = 'tab'
        var pane = tabset.querySelector('.tab-pane[aria-labelledby~="' + id + '"]')
        if (!pane) return // invalid state
        var instance = { tabset: tabset, tab: tab, pane: pane }
        if (!idx) first = instance
        if (!active && fragment === id) {
          active = true
          tab.classList.add('is-active')
          pane.classList.add('is-active')
        }
        tab.addEventListener('click', activateTab.bind(instance))
      })
      if (!active && first) {
        first.tab.classList.add('is-active')
        first.pane.classList.add('is-active')
      }
      tabset.classList.remove('is-loading')
    })
    window.addEventListener('hashchange', onHashChange)
  }

  function activateTab (e) {
    var tab = this.tab
    var tabset = this.tabset || tab.closest('.tabset')
    var pane = this.pane || tabset.querySelector('.tab-pane[aria-labelledby~="' + tab.id + '"]')
    find('.tabs li, .tab-pane', tabset).forEach(function (el) {
      el === tab || el === pane ? el.classList.add('is-active') : el.classList.remove('is-active')
    })
    if (!e) return
    var hashIdx = window.location.hash ? window.location.href.indexOf('#') : -1
    if (~hashIdx) window.history.replaceState(null, '', window.location.href.slice(0, hashIdx))
    e.preventDefault()
  }

  function decodeFragment (hash) {
    return hash && (~hash.indexOf('%') ? decodeURIComponent(hash.slice(1)) : hash.slice(1))
  }

  function onHashChange () {
    var id = decodeFragment(window.location.hash)
    if (!id) return
    var tab = document.getElementById(id)
    if (tab && tab.classList.contains('tab')) activateTab.call({ tab: tab })
  }

  function find (selector, from) {
    return Array.prototype.slice.call((from || document).querySelectorAll(selector))
  }
})()
