# General outline of how this works:
#
# 1. Xray metadata code is inserted during asset compilation.
#    a. For Backbone.Views, JS is inserted that will record the Backbone.View
#       constructor with its metadata in window.XrayData
#    b. For templates, <script> tags are inserted at the beginning and the end
#       of the template.
#
# 2. After DOM is loaded, go through XrayData, hooking into Backbone.View to
#    add view instances to Xray.elements as they're instantiated. NOTE: This
#    means Xray has to be included into a page before any app code runs so its
#    DOM loaded callback can happen first. Not a big deal.
#
# 3. Xray is invoked via keyboard shortcut
#    a. Go through the DOM looking for template script tags. Create Elements
#       representing them. (regenerate on each invocation?)
#    b. Turn created Xray.elements into boxes and display them in the overlay.

window.Xray = {}

# Container for Xray.Element instances
Xray.elements = []

# Initialize Xray - hook into Backbone.View to create Xray.Elements as the views
# are instantiated.
Xray.init = ->
  return if Xray.initialized
  Xray.initialized = true

  if window.XrayData and window.Backbone?.View
    _delegateEvents = Backbone.View::delegateEvents
    Backbone.View::delegateEvents = ->
      _delegateEvents.apply(this, arguments)
      if info = Xray.constructorInfo(this.constructor)
        Xray.add this.el, JSON.parse(info)
    _remove = Backbone.View::remove
    Backbone.View::remove = ->
      _remove.apply(this, arguments)
      Xray.remove this.el

Xray.constructorInfo = (constructor) ->
  for own info, func of window.XrayData
    return info if func is constructor

Xray.scanTemplates = ->
  for beginScript in $('.xray-template-start')
    Xray.add $(beginScript).next(),
      name: '(Partial)',
      path: $(beginScript).attr('data-xray-path')


# Open the given filesystem path by calling out to Xray's server.
# TODO: error handling of any kind, XSS warnings
Xray.open = (path) ->
  $.post "http://localhost:62010/open", path

# Add a DOM element with associated metadata to be tracked by Xray
Xray.add = (el, info = {}) ->
  Xray.elements.push new Xray.Element(el, info)

# Remove a DOM element from Xray
Xray.remove = (el) ->
  if el instanceof Xray.Element
    Xray.elements.splice(Xray.elements.indexOf(el), 1)
  else
    Xray.remove Xray.findElement(el)

Xray.findElement = (el) ->
  el = el[0] if el instanceof jQuery
  for element in Xray.elements
    if element.el == el
      return element

# Show the Xray overlay
Xray.show = ->
  console.log 'X-raying'
  Xray.Overlay.instance().show()

# Hide the Xray overlay
Xray.hide = ->
  console.log 'Hiding X-ray'
  Xray.Overlay.instance().hide()

# Wraps a DOM element that Xray is tracking
class Xray.Element
  constructor: (el, @attrs = {}) ->
    @el = if el instanceof jQuery then el[0] else el
    @$el = $(@el)
    @name = @attrs.name
    @path = @attrs.path

  isVisible: ->
    @$el.is(':visible')

  makeBox: ->
    offset = @$el.offset()
    @$box = $('<div>').css
      position   : 'absolute'
      left       : offset.left
      top        : offset.top
      width      : @$el.outerWidth()
      height     : @$el.outerHeight()
      background : 'rgba(255,255,255,0.8)'
      color      : '#999'
      fontFamily : '"Helvetica Neue", sans-serif'
      zIndex     : 99999
    @$box.click => Xray.open @path
    @$box.text @name
    @$box

# Singleton class for the Xray "overlay" invoked by the keyboard shortcut
class Xray.Overlay
  @instance: ->
    @singletonInstance ||= new this

  constructor: ->
    @$overlay = $('<div>').css
      position   : 'fixed'
      left       : 0
      top        : 0
      bottom     : 0
      right      : 0
      background : 'rgba(0,0,0,0.5)'
      zIndex     : 99999

  show: ->
    Xray.isShowing = true
    $('body').append @$overlay
    @shownBoxes = []
    Xray.scanTemplates()
    for element in Xray.elements
      continue unless element.isVisible()
      element.makeBox()
      $('body').append element.$box
      @shownBoxes.push element.$box

  hide: ->
    Xray.isShowing = false
    @$overlay.remove()
    $box.remove() for $box in @shownBoxes
    @shownBoxes = []



# Initialize on DOM ready.
$ -> Xray.init()

# Register keyboard shortcuts
$(document).keydown (e) ->
  if Xray.isShowing and e.keyCode is 27 # esc
    Xray.hide()
  if e.ctrlKey and e.metaKey and e.keyCode is 88 # cmd+ctrl+x
    if Xray.isShowing then Xray.hide() else Xray.show()
