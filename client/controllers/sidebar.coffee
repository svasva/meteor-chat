Template.sidebar.helpers
  users: -> OnlineUsers.find({}, {sort: {name: 1}})
  msgCounter: (roomId) -> Session.get("msgCounter-#{roomId}")
  userClass: (user) ->
    return 'disabled' if h.sameId(Meteor.user(), user)
    return 'active' if Session.equals('roomId', user._id)
  roomId: -> Session.get 'roomId'
  activeRoom: (roomId) -> Session.equals('roomId', roomId)
  needNotifyPermission: -> h.needNotifyPermission()

Template.sidebar.events
  'click .openPrivate': (e) ->
    return false unless Meteor.user()
    if Session.get('roomId')
      Session.set('roomId', undefined)
      Session.set('roomName', undefined)
      h.resetMsgCounter('room')
    else
      h.prevent(e)
      Session.set('roomId', @_id)
      Session.set('roomName', @name)
      h.resetMsgCounter(@_id)
    Meteor.defer -> $('#message').focus()
