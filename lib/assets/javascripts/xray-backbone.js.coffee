return unless window.Backbone && window.Xray

# Wrap Backbone.View::_ensureElement to add the view to Xray once
# its element has been setup.
_ensureElement = Backbone.View::_ensureElement
Backbone.View::_ensureElement = ->
  _.defer =>
    info = Xray.constructorInfo @constructor
    Xray.ViewSpecimen.add @el, info
  _ensureElement.apply(this, arguments)

# Cleanup when view is removed.
_remove = Backbone.View::remove
Backbone.View::remove = ->
  Xray.ViewSpecimen.remove @el
  _remove.apply(this, arguments)
