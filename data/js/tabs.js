;(function () { /*! Asciidoctor Tabs | Copyright (c) 2018-present Dan Allen | MIT License */
  'use strict'

  var forEach = Array.prototype.forEach

  init(document.querySelectorAll('.tabset'))

  function init (tabsets) {
    if (!tabsets.length) return
    forEach.call(tabsets, function (tabset) {
      var tabs = tabset.querySelectorAll('.tabs li')
      var syncIds = tabset.classList.contains('is-sync') ? {} : undefined
      forEach.call(tabs, function (tab, idx) {
        var id = tab.id
        if (!id) {
          var anchor = tab.querySelector('a[id]')
          if (!anchor) return // invalid state
          tab.id = id = anchor.parentNode.removeChild(anchor).id
        }
        tab.className = idx ? 'tab' : 'tab is-active'
        var pane = tabset.querySelector('.tab-pane[aria-labelledby~="' + id + '"]')
        if (!pane) return // invalid state
        if (!idx) pane.classList.add('is-active')
        var onClick = activateTab
        var instance = { tabset: tabset, tab: tab, pane: pane }
        var syncId
        if (syncIds && !((syncId = tab.textContent.trim()) in syncIds)) {
          syncIds[(tab.dataset.syncId = syncId)] = true
          onClick = activateTabSync
        }
        tab.addEventListener('click', onClick.bind(instance))
      })
    })
    onHashChange()
    forEach.call(tabsets, function (tabset) {
      tabset.classList.remove('is-loading')
    })
    window.addEventListener('hashchange', onHashChange)
  }

  function activateTab (e) {
    var tab = this.tab
    var tabset = this.tabset || tab.closest('.tabset')
    var pane = this.pane || tabset.querySelector('.tab-pane[aria-labelledby~="' + tab.id + '"]')
    forEach.call(tabset.querySelectorAll('.tabs li, .tab-pane'), function (el) {
      el === tab || el === pane ? el.classList.add('is-active') : el.classList.remove('is-active')
    })
    if (!e) return
    var loc = window.location
    var hashIdx = loc.hash ? loc.href.indexOf('#') : -1
    if (~hashIdx) window.history.replaceState(null, '', loc.href.slice(0, hashIdx))
    e.preventDefault()
  }

  function activateTabSync (e) {
    activateTab.call(this, e)
    var thisTab = this.tab
    forEach.call(document.querySelectorAll('.tabs li'), function (tab) {
      if (tab !== thisTab && tab.dataset.syncId === thisTab.dataset.syncId) activateTab.call({ tab: tab })
    })
  }

  function onHashChange () {
    var id = window.location.hash.slice(1)
    if (!id) return
    var tab = document.getElementById(~id.indexOf('%') ? decodeURIComponent(id) : id)
    if (!(tab && tab.classList.contains('tab'))) return
    tab.dataset.syncId ? activateTabSync.call({ tab: tab }) : activateTab.call({ tab: tab })
  }
})()
