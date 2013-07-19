@h ||= {}
@h.prevent = (e) ->
  e.preventDefault()
  e.stopPropagation()
@h.page = (ask = null) ->
  page = Meteor.Router.page()
  if ask then page == ask else page

@h.autoScroll = (selector, interval = false) ->
  if interval
    set   = Meteor.setInterval
    clear = Meteor.clearInterval
    timer = 300
  else
    set   = Meteor.setTimeout
    clear = Meteor.clearTimeout
    timer = 50

  clear(@_scroller) if scroller?
  @_scroller = set (->
    $(selector).scrollTop $(selector)[0]?.scrollHeight), timer

Handlebars.registerHelper 'sameId', (obj1, obj2) -> h.sameId(obj1, obj2)

Handlebars.registerHelper 'admin', ->
  user = Meteor.user()
  user && user.profile && user.profile.admin

Handlebars.registerHelper 'isOnline', (userId) ->
  !!OnlineUsers.findOne(userId)

Handlebars.registerHelper 'page', (page) -> h.page(page)
Handlebars.registerHelper 'session', (param) ->
  val = Session.get(param)
  if val == null then '' else val

Handlebars.registerHelper 'activeLink', (page, pageParam = false) ->
  if Meteor.Router.page() == page
    if pageParam
      'active' if Session.get('pageParam') == pageParam
    else 'active'
Handlebars.registerHelper 'isoDate', (date) ->
  return unless date
  switch typeof(date)
    when 'string' then new Date(date).toISOString()
    when 'number' then new Date(date * 1000).toISOString()
    when 'object' then date.toISOString()
