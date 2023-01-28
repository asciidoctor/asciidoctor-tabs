;(function () { /*! Asciidoctor Tabs | Copyright (c) 2018-present Dan Allen | MIT License */
  'use strict'

  var forEach = Array.prototype.forEach

  init(document.querySelectorAll('.tabs'))

  function init (tabsBlocks) {
    if (!tabsBlocks.length) return
    forEach.call(tabsBlocks, function (tabs) {
      var syncIds = tabs.classList.contains('is-sync') ? {} : undefined
      var tablist = tabs.querySelector('.tablist ul')
      tablist.setAttribute('role', 'tablist')
      forEach.call(tablist.querySelectorAll('li'), function (tab, idx) {
        tab.setAttribute('role', (tab.className = 'tab')) // NOTE converter may not have set class on li
        var id, anchor
        if (!(id = tab.id)) {
          if (!(anchor = tab.querySelector('a[id]'))) return // invalid state
          tab.id = id = anchor.parentNode.removeChild(anchor).id
        }
        var panel = tabs.querySelector('.tabpanel[aria-labelledby~="' + id + '"]')
        if (!panel) return // invalid state
        tab.tabIndex = -1
        tab.setAttribute('aria-controls', panel.id)
        panel.setAttribute('role', 'tabpanel')
        idx ? toggleHidden(panel, true) : toggleSelected(tab, true)
        forEach.call(panel.querySelectorAll('table.tableblock'), function (table) {
          var container = Object.assign(document.createElement('div'), { className: 'tablecontainer' })
          table.parentNode.insertBefore(container, table).appendChild(table)
        })
        var onClick = activateTab
        var instance = { tabs: tabs, tab: tab, panel: panel }
        var syncId
        if (syncIds && !((syncId = tab.textContent.trim()) in syncIds)) {
          syncIds[(tab.dataset.syncId = syncId)] = true
          onClick = activateTabSync
        }
        tab.addEventListener('click', onClick.bind(instance))
      })
    })
    onHashChange()
    forEach.call(tabsBlocks, function (tabs) {
      tabs.classList.remove('is-loading')
    })
    window.addEventListener('hashchange', onHashChange)
  }

  function activateTab (e) {
    var tab = this.tab
    var tabs = this.tabs || (this.tabs = tab.closest('.tabs'))
    var panel = this.panel || (this.panel = document.getElementById(tab.getAttribute('aria-controls')))
    forEach.call(tabs.querySelectorAll('.tablist .tab'), function (el) {
      toggleSelected(el, el === tab)
    })
    forEach.call(tabs.querySelectorAll('.tabpanel'), function (el) {
      toggleHidden(el, el !== panel)
    })
    if (!e) return
    var loc = window.location
    var hashIdx = loc.hash ? loc.href.indexOf('#') : -1
    if (~hashIdx) window.history.replaceState(null, '', loc.href.slice(0, hashIdx))
    e.preventDefault()
  }

  function activateTabSync (e) {
    activateTab.call(this, e)
    var tabs = this.tabs
    var thisTab = this.tab
    var initialY = tabs.getBoundingClientRect().y
    forEach.call(document.querySelectorAll('.tabs .tablist .tab'), function (tab) {
      if (tab !== thisTab && tab.dataset.syncId === thisTab.dataset.syncId) activateTab.call({ tab: tab })
    })
    var shiftedBy = tabs.getBoundingClientRect().y - initialY
    if (shiftedBy && (shiftedBy = Math.round(shiftedBy))) window.scrollBy({ top: shiftedBy, behavior: 'instant' })
  }

  function toggleHidden (el, state) {
    el.classList.toggle('is-hidden', (el.hidden = state))
  }

  function toggleSelected (el, state) {
    el.setAttribute('aria-selected', '' + state)
    el.classList.toggle('is-selected', state)
    el.tabIndex = state ? 0 : -1
  }

  function onHashChange () {
    var id = window.location.hash.slice(1)
    if (!id) return
    var tab = document.getElementById(~id.indexOf('%') ? decodeURIComponent(id) : id)
    if (!(tab && tab.classList.contains('tab'))) return
    tab.dataset.syncId ? activateTabSync.call({ tab: tab }) : activateTab.call({ tab: tab })
  }
})()
