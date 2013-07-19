@Messages = new Meteor.Collection 'messages',
  transform: (doc) -> new Message(doc)

@Messages.allow
  insert: -> false
  update: -> false
  remove: -> false

class @Message
  constructor: (doc) -> _.extend @, doc

Meteor.users.deny
  insert: -> true
  update: -> true
  remove: -> true

if Meteor.isClient #client-only collections
  @OnlineUsers = new Meteor.Collection 'onlineUsers'
