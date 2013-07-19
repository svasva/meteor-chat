Template.sidebar.helpers
  users: -> OnlineUsers.find()
  msgCounter: (roomId) -> Session.get("msgCounter-#{roomId}")
  userClass: (user) ->
    return 'disabled' if h.sameId(Meteor.user(), user)
    return 'active' if Session.equals('roomId', user._id)
  roomId: -> Session.get 'roomId'
  activeRoom: (roomId) -> Session.get('roomId') == roomId

Template.sidebar.events
  'click .openPrivate': (e) ->
    return false unless Meteor.user()
    if Session.get('roomId')
      Session.set('roomId', undefined)
      Session.set('roomName', undefined)
    else
      h.prevent(e)
      Session.set('roomId', @_id)
      Session.set('roomName', @name)
      Session.set("msgCounter-#{@_id}", undefined)
