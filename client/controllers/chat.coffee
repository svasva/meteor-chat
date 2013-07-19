@h ||= {}
@h.msgObserver = ->
  return false unless Meteor.user()
  window.msgObs?.stop()
  init = true
  window.msgObs = Messages.find({roomId: {$ne: null}}).observe
    added: (msg) =>
      return if init or Meteor.loggingIn()
      key = "msgCounter-#{msg.userId}"
      counter = Session.get(key) || 0
      Session.set(key, counter + 1)
  init = false

@h.sendMessage = ->
  text = $('#message').val()
  throw new Meteor.Error('500', 'Empty message') unless text
  Meteor.call('sendMessage', text, Session.get('roomId'))
  $('#message').val('')

Template.chat.rendered = ->
  $('span[rel=timeago]').timeago()
  h.autoScroll('#messageList')

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
  'keyup #message': (e) ->
    return true unless e.keyCode is 13
    mods = e.shiftKey or e.altKey or e.ctrlKey
    return true if e.keyCode is 13 and mods
    h.sendMessage()
  'click #loginPlease': (e) ->
    h.prevent(e)
    $('#login-dropdown-list a[data-toggle=dropdown]').trigger('click')
    $('#login-email').focus()

Template.chat.helpers
  private: -> not Session.equals('roomId', undefined)
  roomName: -> Session.get 'roomName'
  roomId: -> Session.get 'roomId'
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
