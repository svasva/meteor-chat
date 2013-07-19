Meteor.publish 'messages', ->
  if @userId
    selector =
      $or: [{roomId: @userId}, {roomId: null}, {userId: @userId}]
  else selector = {roomId: null}
  Messages.find(selector, {limit: 100, sort: {time: -1}})

Meteor.publish 'onlineUsers', ->
  console.log 'subscribe', @userId
  Meteor._onlineUsers ||= []
  observer = Meteor.users.find({'profile.online': true}).observe
    added: (user) =>
      record =
        id: user._id
        name: h.getNick(user)

      Meteor._onlineUsers.push record
      @added('onlineUsers', record.id, record)
    removed: (user) =>
      onlineUsers = _.reject onlineUsers, (u) ->
        u.id == user._id
      console.log 'removed', user
      @removed('onlineUsers', user._id)

  init = false
  # @added('onlineUsers', id, onlineUsers)
  @ready()
  @onStop =>
    console.log 'unsubscribe', @userId
    observer.stop()
