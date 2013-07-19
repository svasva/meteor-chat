@h ||= {}
@h.findUser = (id, force = true) ->
  throw new Meteor.Error('403', 'Unauthorized') if force and not id
  user = Meteor.users.findOne(id)
  throw new Meteor.Error('403', 'Unauthorized') if force and not user
  return user

@h.isAdmin = (id = Meteor.user()) ->
  switch typeof(id)
    when 'string' then user = h.findUser(id)
    when 'object' then user = id
  return !!user.profile?.admin

@h.getNick = (user) ->
  nickname = user.profile?.nickname
  nickname ||= user.emails[0].address.replace(/@.*/, '')

@h.sameId = (obj1, obj2) -> obj1?._id == obj2?._id
