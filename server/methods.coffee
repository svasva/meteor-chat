Meteor.methods
  sendMessage: (text, roomId = null) ->
    user = h.findUser(@userId)
    msg =
      userId: user._id
      roomId: roomId
      name: h.getNick(user)
      time: new Date
      body: text

    console.log msg
    Messages.insert(msg)
    #stub
  removeMessage: (id) ->
    throw new Meteor.Error('403', 'Unauthorized') unless h.isAdmin(@userId)
    Messages.remove(id)
  setAdmin: ->
    user = Meteor.users.findOne({'emails.address': 'erundook@gmail.com'})
    Meteor.users.update(user._id, $set: {'profile.admin': true})
