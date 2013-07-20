@h ||= {}

Meteor._onLogin =  (userId) -> h._sendStatusMessage(userId, true)
Meteor._onLogout = (userId) -> h._sendStatusMessage(userId, false)

@h._sendStatusMessage = (userId, online) ->
  user = Meteor.users.findOne(userId)
  word = if online then 'entered' else 'left'
  message = "#{h.getNick(user)} has #{word} the room."
  h._sendMessage(userId, message, undefined, true)

@h._sendMessage = (userId, text, roomId, system = null) ->
  user = h.findUser(userId)
  msg =
    userId: user._id
    roomId: roomId
    name: if system then 'System message' else h.getNick(user)
    time: new Date
    body: text
    system: system
    picUrl: h.gravatarUrl(user)

  Messages.insert(msg)

Meteor.methods
  sendMessage: (text, roomId = null) -> h._sendMessage(@userId, text, roomId)
  removeMessage: (id) ->
    throw new Meteor.Error('403', 'Unauthorized') unless h.isAdmin(@userId)
    Messages.remove(id)
  setAdmin: ->
    user = Meteor.users.findOne({'emails.address': 'erundook@gmail.com'})
    Meteor.users.update(user._id, $set: {'profile.admin': true})
  changeNickname: (nick) ->
    user = h.findUser(@userId)
    existing = Meteor.users.findOne({'profile.nickname': nick})
    throw new Meteor.Error('403', 'Nickname is busy') if existing
    h._sendMessage(@userId, "#{h.getNick(user)} is now known as #{nick}.", undefined, true)
    Meteor.users.update @userId, $set: {'profile.nickname': nick}
    return true
