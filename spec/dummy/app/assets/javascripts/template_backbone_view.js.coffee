class App.TemplateBackboneView extends Backbone.View
  initialize: ->
    @$el.html JST['eco_template']
