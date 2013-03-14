window.Xray = {}
return unless $ = window.jQuery

bm = (name, fn) ->
  time = new Date
  result = fn()
  # console.log "#{name} : #{new Date() - time}ms"
  result

# Initialize Xray - hook into Backbone.View to create Xray.specimens as the views
# are instantiated.
Xray.init = ->
  return if Xray.initialized
  Xray.initialized = true

  console?.log "Ready to Xray. Press cmd+ctrl+x to scan your UI."

  # Register keyboard shortcuts
  $(document).keydown (e) ->
    if e.ctrlKey and e.metaKey and e.keyCode is 88 # cmd+ctrl+x
      if Xray.isShowing then Xray.hide() else Xray.show()
    if Xray.isShowing and e.keyCode is 27 # esc
      Xray.hide()

  $ ->
    new Xray.Overlay
    Xray.findTemplates()

Xray.specimens = ->
  Xray.ViewSpecimen.all.concat Xray.TemplateSpecimen.all

Xray.constructorInfo = (constructor) ->
  if window.XrayPaths
    for own info, func of window.XrayPaths
      return JSON.parse(info) if func == constructor
  null

# Scans the document for templates, creating Xray.TemplateSpecimens for them.
Xray.findTemplates = -> bm 'addTemplates', ->
  # Find all <!-- XRAY START ... --> comments
  comments = $('*:not(iframe,script)').contents().filter ->
    this.nodeType == 8 and this.data[0..10] == " XRAY START"
  # Find the <!-- XRAY END ... --> comment for each. Everything between the
  # start and end comment becomes the contents of an Xray.TemplateSpecimen.
  for comment in comments
    [_, id, path] = comment.data.match(/^ XRAY START (\d+) (.*) $/)
    $templateContents = new jQuery
    el = comment.nextSibling
    until !el or (el.nodeType == 8 and el.data == " XRAY END #{id} ")
      if el.nodeType == 1 and el.tagName != 'SCRIPT'
        $templateContents.push el
      el = el.nextSibling
    # Remove XRAY's template comments from the DOM.
    el.parentNode.removeChild(el) if el?.nodeType == 8
    comment.parentNode.removeChild(comment)
    # Add the template specimen
    Xray.TemplateSpecimen.add $templateContents,
      name: path.split('/').slice(-1)[0]
      path: path

# Open the given filesystem path by calling out to Xray's server.
Xray.open = (path) ->
  $.ajax
    url: "/xray/open?path=#{path}"
    dataType: 'script'

# Show the Xray overlay
Xray.show = (type = null) ->
  Xray.Overlay.instance().show(type)

# Hide the Xray overlay
Xray.hide = ->
  Xray.Overlay.instance().hide()

# Wraps a DOM element that Xray is tracking
class Xray.Specimen
  @add: (el, attrs = {}) ->
    @all.push new this(el, attrs)

  @remove: (el) ->
    @find(el)?.remove()

  @find: (el) ->
    el = el[0] if el instanceof jQuery
    for specimen in @all
      return specimen if specimen.el == el
    null

  @reset: ->
    @all = []

  constructor: (contents, attrs = {}) ->
    @el = if contents instanceof jQuery then contents[0] else contents
    @$contents = $(contents)
    @name = attrs.name
    @path = attrs.path

  remove: ->
    idx = @constructor.all.indexOf(this)
    @constructor.all.splice(idx, 1) unless idx == -1

  isVisible: ->
    @$contents.length and @$contents.is(':visible')

  makeBox: ->
    bbox = @_computeBoundingBox()
    @$box = $("<div class='xray-specimen #{@constructor.name}'>").css
      top    : bbox.top
      left   : bbox.left
      width  : bbox.width
      height : bbox.height
    # If the element is fixed, inherit its position for the bounding box.
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

    # `contents` is a jQuery object that normally wraps one parent element,
    # but occassionally we're wrapping multiple sibling elements (think about
    # a partial with no direct container element), so we iterate just in case.
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


# Singleton class for the Xray "overlay" invoked by the keyboard shortcut
class Xray.Overlay
  @instance: ->
    @singletonInstance ||= new this

  constructor: ->
    Xray.Overlay.singletonInstance = this
    @bar = new Xray.Bar($('#xray-bar'))
    @shownBoxes = []
    @$overlay = $('<div id="xray-overlay">')
    @$overlay.click => @hide()

  show: (type = null) ->
    @reset()
    Xray.isShowing = true
    bm 'show', =>
      unless @$overlay.is(':visible')
        $('body').append @$overlay
        @bar.show()
      switch type
        when 'templates'
          Xray.findTemplates()
          specimens = Xray.TemplateSpecimen.all
        when 'views'
          specimens = Xray.ViewSpecimen.all
        else
          Xray.findTemplates()
          specimens = Xray.specimens()
      for element in specimens
        continue unless element.isVisible()
        element.makeBox()
        element.$box.css(zIndex: Math.ceil((10000 + element.bbox.top + element.bbox.left)))
        @shownBoxes .push element.$box
        $('body').append element.$box

  reset: ->
    $box.remove() for $box in @shownBoxes
    @shownBoxes = []

  hide: ->
    Xray.isShowing = false
    @$overlay.detach()
    @reset()
    @bar.hide()


class Xray.Bar
  constructor: (el) ->
    @$el = $(el)
    @$el.css(zIndex: 2147483647)
    @$el.find('#xray-bar-controller-path .xray-bar-btn').click ->
      Xray.open($(this).attr('data-path'))
    @$el.find('.xray-bar-all-toggler').click       -> Xray.show()
    @$el.find('.xray-bar-templates-toggler').click -> Xray.show('templates')
    @$el.find('.xray-bar-views-toggler').click     -> Xray.show('views')

  show: ->
    @$el.show()
    @originalPadding = parseInt $('html').css('padding-bottom')
    if @originalPadding < 40
      $('html').css paddingBottom: 40

  hide: ->
    @$el.hide()
    $('html').css paddingBottom: @originalPadding

  toggleSettings: =>
    @$settings.show()


Xray.init()