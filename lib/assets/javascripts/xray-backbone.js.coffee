return unless window.Backbone && window.Xray

# Wrap Backbone.View::_ensureElement to add the view to Xray once
# its element has been setup.
_ensureElement = Backbone.View::_ensureElement
Backbone.View::_ensureElement = ->
  _ensureElement.apply(this, arguments)
  Xray.ViewSpecimen.add this.el, this.constructor

# Cleanup when view is removed.
_remove = Backbone.View::remove
Backbone.View::remove = ->
  Xray.ViewSpecimen.remove this.el
  _remove.apply(this, arguments)
