@h ||= {}
@h.needNotifyPermission = ->
  return false unless h.checkNotifySupport()
  !Session.get('gotNotifyPermission') && !h.checkNotifyPermission()
@h.checkNotifySupport = ->
  return !!window.webkitNotifications
@h.checkNotifyPermission = ->
  return window.webkitNotifications.checkPermission() is 0
@h.requestPermission = ->
  window.webkitNotifications.requestPermission ->
    Session.set('gotNotifyPermission', true) if h.checkNotifyPermission()
@h.notify = (title, text, onclick = null) ->
  havePermission = window.webkitNotifications.checkPermission()
  return unless havePermission is 0
  n = window.webkitNotifications.createNotification('', title, text)
  n.onclick = onclick if typeof(onclick) is 'function'
  n.show()
