Meteor.publish 'messages', ->
  if @userId
    selector =
      $or: [{roomId: @userId}, {roomId: null}, {userId: @userId}]
  else selector = {roomId: null}
  Messages.find(selector, {limit: 100, sort: {time: -1}})

Meteor.publish 'onlineUsers', ->
  makeRec = (user) ->
    name: h.getNick(user)

  observer = Meteor.users.find({'profile.online': true}).observe
    added: (user) =>
      record = makeRec(user)
      @added('onlineUsers', user._id, record)
    changed: (newDoc, oldDoc) =>
      record = makeRec(newDoc)
      @changed('onlineUsers', oldDoc._id, record)
    removed: (user) => @removed('onlineUsers', user._id)

  init = false
  @ready()
  @onStop -> observer.stop()
