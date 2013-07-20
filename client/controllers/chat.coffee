@h ||= {}

@h.resetMsgCounter = (key = null) ->
  if key
    return unless window._msgCounters
    c = window._msgCounters[key] || 0
    total = (h.getMsgCounter() - c) || undefined
    Session.set("msgCounter-#{key}", undefined)
    Session.set("msgCounter", total)
    delete window._msgCounters[key]
  else
    for k, v of window._msgCounters
      Session.set("msgCounter-#{k}", undefined)
      Session.set("msgCounter", undefined)
    window._msgCounters = {}

@h.updateMsgCounters = ->
  total = 0
  for k, v of window._msgCounters
    total += v
    Session.set("msgCounter-#{k}", v)
  if total then Session.set('msgCounter', total)
  else Session.set('msgCounter', undefined)

@h.incrementMsgCounter = (key) ->
  window._msgCounters ||= {}
  window._msgCounters[key] ||= 0
  window._msgCounters[key]++
  h.updateMsgCounters()

@h.getMsgCounter = (key = null) ->
  if key then Session.get "msgCounter-#{key}"
  else Session.get "msgCounter"

@h.messageNotifier = (msg) ->
  return unless h.checkNotifySupport() and h.checkNotifyPermission()
  h.notify("New private message from #{msg.name}", msg.body)

@h.msgObserver = ->
  return false unless Meteor.user()
  window.msgObs?.stop()
  init = true
  selector = $or: [
    { roomId: Meteor.userId() }
    { roomId: null }
  ]
  window.msgObs = Messages.find(selector).observe
    added: (msg) =>
      key = if msg.roomId then msg.userId else undefined
      return if init or Meteor.loggingIn()
      return if window._focus and Session.equals('roomId', key)
      h.incrementMsgCounter(key || 'room')
      h.messageNotifier(msg) if key
  init = false

@h.sendMessage = ->
  text = $('#message').val()
  throw new Meteor.Error('500', 'Empty message') unless text
  if nick = text.match(/^\/nick (.*)/)?[1]
    Meteor.call('changeNickname', nick)
  else
    Meteor.call('sendMessage', text, Session.get('roomId'))
  $('#message').val('')

Template.chat.rendered = ->
  $('span[rel=timeago]').timeago()
  h.autoScroll('#messageList')
  $(window).focus ->
    h.resetMsgCounter(Session.get('roomId') || 'room')
  unless @_rendered
    @_rendered = true
    window._focus = true

Template.chat.events
  'click #sendMessage': (e) ->
    h.prevent(e)
    h.sendMessage()
  'click .deleteMessage': (e) ->
    h.prevent(e)
    Meteor.call('removeMessage', @_id)
  'click #closeRoom': (e) ->
    h.prevent(e)
    Session.set('roomId', undefined)
    Session.set('roomName', undefined)
  'keydown #message': (e) ->
    if e.keyCode is 9 #tab
      h.prevent(e)
      val = $('#message').val()
      scan = val.match(/(.*\s+)?(.*)$/)
      query = scan?[2]
      msg = scan?[1] || ''
      return unless query
      match = OnlineUsers.findOne({name: {$regex: "^#{query}"}})?.name
      return unless match
      $('#message').val(msg + match)
  'keyup #message': (e) ->
    return true unless e.keyCode is 13
    mods = e.shiftKey or e.altKey or e.ctrlKey
    return true if e.keyCode is 13 and mods
    h.sendMessage()
  'click #loginPlease': (e) ->
    h.prevent(e)
    $('#login-dropdown-list a[data-toggle=dropdown]').trigger('click')
    $('#login-email').focus()
  'click .appendNickname': (e) ->
    h.prevent(e)
    val = $('#message').val()
    $('#message').val(val + @name)
    $('#message').focus()

Template.chat.helpers
  pageTitle: ->
    title = "Chat"
    if c = h.getMsgCounter()
      title += " | #{c} new messages"
    return title
  private: -> not Session.equals('roomId', undefined)
  roomName: -> Session.get 'roomName'
  roomId: -> Session.get 'roomId'
  roomMsgCounter: -> h.getMsgCounter('room')
  msgClass: ->
    if @system? then return 'system'
    if @userId is Meteor.userId() then return 'own'
    if @body.match(h.getNick(Meteor.user())) then return 'highlight'
  messages: ->
    roomId = Session.get('roomId')
    userId = Meteor.userId()
    if roomId
      selector =
        $or: [
          {userId: userId, roomId: roomId}
          {userId: roomId, roomId: Meteor.userId()}
        ]
    else selector = {roomId: null}
    Messages.find(selector, {sort: {time: 1}})
