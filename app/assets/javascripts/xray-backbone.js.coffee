# Xray Backbone integration. This involves hooking into the lifecycle
# of Backbone.View by monkey patching its prototype. Would love a cleaner
# way of doing this, as nobody wants to this stuff in their stack traces.

return unless window.Backbone && window.Xray

# Wrap Backbone.View::_ensureElement to add the view to Xray once
# its element has been setup.
_ensureElement = Backbone.View::_ensureElement
Backbone.View::_ensureElement = ->
  _.defer =>
    if info = Xray.constructorInfo @constructor
      Xray.ViewSpecimen.add @el, info
  _ensureElement.apply(this, arguments)

# Cleanup when view is removed.
_remove = Backbone.View::remove
Backbone.View::remove = ->
  Xray.ViewSpecimen.remove @el
  _remove.apply(this, arguments)
