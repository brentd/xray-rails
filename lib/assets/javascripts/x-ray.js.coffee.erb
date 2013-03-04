# General outline of how this works:
#
# 1. Xray metadata code is inserted during asset compilation.
#    a. For Backbone.Views, JS is inserted that will record the Backbone.View
#       constructor with its metadata in window.XrayData
#    b. For templates, HTML comments are inserted at the beginning and the end
#       of the template.
#
# 2. After DOM is loaded, go through XrayData, hooking into Backbone.View to
#    add view instances to Xray.specimens as they're instantiated. NOTE: This
#    means Xray has to be included into a page before any app code runs so its
#    DOM loaded callback can happen first. Not a big deal.
#
# 3. Xray is invoked via keyboard shortcut
#    a. Go through the DOM looking for template script tags. Create Elements
#       representing them. (regenerate on each invocation?)
#    b. Turn created Xray.specimens into boxes and display them in the overlay.

window.Xray = {}

bm = (name, fn) ->
  time = new Date
  result = fn()
  console.log "#{name} : #{new Date() - time}ms"
  result

# Initialize Xray - hook into Backbone.View to create Xray.specimens as the views
# are instantiated.
Xray.init = ->
  return if Xray.initialized
  Xray.initialized = true

  if window.XrayData and window.Backbone?.View
    _delegateEvents = Backbone.View::delegateEvents
    Backbone.View::delegateEvents = ->
      _delegateEvents.apply(this, arguments)
      if info = Xray.constructorInfo(this.constructor)
        Xray.ViewSpecimen.add this.el, JSON.parse(info)
    _remove = Backbone.View::remove
    # Backbone.View::remove = ->
    #   _remove.apply(this, arguments)
    #   Xray.remove this.el

Xray.specimens = ->
  Xray.ViewSpecimen.all.concat Xray.TemplateSpecimen.all

Xray.constructorInfo = (constructor) ->
  for own info, func of window.XrayData
    return info if func == constructor
  null

# Scans the document for templates, creating Xray.specimens for them.
Xray.addTemplates = -> bm 'addTemplates', ->
  # Find all <!-- XRAY START ... --> comments
  comments = $('*:not(iframe,script)').contents().filter ->
    this.nodeType == 8 and this.data[0..10] == " XRAY START"
  # Find the <!-- XRAY END ... --> comment for each. Everything between the
  # start and end comment becomes the contents of an Xray.Specimen.
  for comment in comments
    [_, id, path] = comment.data.match(/^ XRAY START (\d+) (.*) $/)
    $templateContents = new jQuery
    el = comment.nextSibling
    until !el or (el.nodeType == 8 and el.data == " XRAY END #{id} ")
      if el.nodeType == 1 and el.tagName != 'SCRIPT'
        $templateContents.push el
      el = el.nextSibling
    Xray.TemplateSpecimen.add $templateContents,
      name: path.split('/').slice(-1)[0]
      path: path

# Open the given filesystem path by calling out to Xray's server.
# TODO: error handling of any kind
Xray.open = (path) ->
  $.ajax
    url: "/xray/open?path=#{path}"
    dataType: 'script'

# Remove a DOM element from Xray
# Xray.remove = (el) ->
#   if el instanceof Xray.Specimen
#     Xray.specimens.splice(Xray.specimens.indexOf(el), 1)
#   else
#     Xray.remove Xray.find(el)

# Show the Xray overlay
Xray.show = ->
  Xray.Overlay.instance().show()

# Hide the Xray overlay
Xray.hide = ->
  Xray.Overlay.instance().hide()


# Wraps a DOM element that Xray is tracking
class Xray.Specimen
  @add: (el, attrs = {}) ->
    unless @find(el)
      @all.push new this(el, attrs)

  @find: (el) ->
    el = el[0] if el instanceof jQuery
    for specimen in @all
      return specimen if specimen.el == el
    null

  constructor: (contents, attrs = {}) ->
    @el = if contents instanceof jQuery then contents[0] else contents
    @$contents = $(contents)
    @name = attrs.name
    @path = attrs.path

  remove: ->
    idx = @all.indexOf(this)
    @all.splice(idx, 1) unless idx == -1

  isVisible: ->
    @$contents.length and @$contents.is(':visible')

  makeBox: ->
    bbox = @_computeBoundingBox()
    @$box = $("<div class='xray-specimen #{@constructor.name}'>").css
      top    : bbox.top
      left   : bbox.left
      width  : bbox.width
      height : bbox.height
    # If the element is fixed, override its document position and inherit its
    # CSS position.
    if @$contents.css('position') == 'fixed'
      @$box.css
        position : 'fixed'
        top      : @$contents.css('top')
        left     : @$contents.css('left')
    @$box.click =>
      console.log "Opening #{@path}"
      console.log @$contents
      Xray.open @path
    @$box.append @makeLabel

  makeLabel: =>
    $("<div class='xray-specimen-handle #{@constructor.name}'>").append(@name).click =>
      Xray.open @path

  _computeBoundingBox: (contents = @$contents) ->
    @bbox = {}
    # Edge case: the container may not wrap its children, for example if they
    # are floated and no clearfix is present.
    if contents.length == 1 and contents.height() <= 0
      return @_computeBoundingBox(contents.children())

    boxFrame =
      top    : Number.MAX_VALUE
      left   : Number.MAX_VALUE
      right  : 0
      bottom : 0

    # `contents` is a jQuery object that normally is wrapping one parent
    # element, but occassionally we're wrapping multiple sibling elements
    # (think about a partial with no direct container), so we iterate here
    # just in case.
    for el in contents
      $el = $(el)
      continue unless $el.is(':visible')
      frame = $el.offset()
      frame.right  = frame.left + $el.outerWidth()
      frame.bottom = frame.top + $el.outerHeight()
      boxFrame.top    = frame.top if frame.top < boxFrame.top
      boxFrame.left   = frame.left if frame.left < boxFrame.left
      boxFrame.right  = frame.right if frame.right > boxFrame.right
      boxFrame.bottom = frame.bottom if frame.bottom > boxFrame.bottom
    @bbox =
      left   : boxFrame.left
      top    : boxFrame.top
      width  : boxFrame.right - boxFrame.left
      height : boxFrame.bottom - boxFrame.top
    return @bbox


class Xray.ViewSpecimen extends Xray.Specimen
  @all = []

  makeLabel: ->
    if @template
      handles = $("<div class='xray-specimen-multi-handle'>")
      handles.append(super).append(@template.makeLabel())
    else
      super


class Xray.TemplateSpecimen extends Xray.Specimen
  @all = []

  @add: (el, info = {}) ->
    if view = (Xray.ViewSpecimen.find(el) || Xray.ViewSpecimen.find $(el).parent())
      view.template = new this(el, info)
    else if !@find(el)
      @all.push new this(el, info)


# Singleton class for the Xray "overlay" invoked by the keyboard shortcut
class Xray.Overlay
  @instance: ->
    @singletonInstance ||= new this

  constructor: ->
    @$overlay = $('<div id="xray-overlay">')
    @$overlay.click => @hide()

  show: -> bm "show", =>
    Xray.isShowing = true
    $('body').append @$overlay
    @shownBoxes = []
    Xray.addTemplates()
    for element in Xray.specimens()
      continue unless element.isVisible()
      element.makeBox()
      element.$box.css(zIndex: Math.ceil((10000 + element.bbox.top + element.bbox.left)))
      @shownBoxes.push element.$box
      $('body').append element.$box

  hide: ->
    Xray.isShowing = false
    @$overlay.detach()
    $box.remove() for $box in @shownBoxes
    @shownBoxes = []


class Xray.DevBar
  initialize: ->
    @$el = $('<div id="xray-dev-bar"></div>')


# Initialize on DOM ready.
$ -> Xray.init()

# Register keyboard shortcuts
$(document).keydown (e) ->
  if Xray.isShowing and e.keyCode is 27 # esc
    Xray.hide()
  if e.ctrlKey and e.metaKey and e.keyCode is 88 # cmd+ctrl+x
    if Xray.isShowing then Xray.hide() else Xray.show()
