Xray-rails
==========

### Reveal your UI's bones

The dev tools available to web developers in modern browsers are great. Many of us can't remember what life was like before "Inspect Element". But what we see in the compiled output sent to our browser is often the wrong level of detail - what about visualizing the higher level components of your UI? Controllers, templates, partials, Backbone views, etc.

Xray is the missing link between the browser and your app code. Press **cmd+shift+x** (Mac) or **ctrl+shift+x** to reveal an overlay of the files that rendered your UI, and click anything to open the file in your editor. [See Xray in action](http://f.cl.ly/items/1A0o3y1y3Q13103V3F1l/xray-rails-large.gif).

![Screenshot](https://dl.dropboxusercontent.com/u/156655/xray-screenshot.png)

## Current Support

Xray is intended for Rails 3.1+ and Ruby 1.9+.

So far, Xray can reveal:

  * Rails views and partials
  * Backbone View instances if using the asset pipeline
  * Javascript templates if using the asset pipeline with the .jst extension

## Installation

Xray depends on **jQuery**. Backbone is optional.

This gem should only be present during development. Add it to your Gemfile:

```ruby
group :development do
  gem 'xray-rails'
end
```

Then bundle and delete your cached assets:

```
$ bundle && rm -rf tmp/cache/assets
```

Restart your app, visit it in your browser, and press **cmd+shift+x** (Mac) or **ctrl+shift+x** to reveal the overlay.

#### Note about `config.assets.debug`

For Xray to insert itself into your views automatically, `config.assets.debug = true` (Rails' default) must be set in development.rb. If you disabled this because of slow assets in Rails 3.2.13, [try this monkey patch instead](http://stackoverflow.com/a/15520932/24848) in an initializer.

Otherwise, you can insert Xray's scripts yourself, for example like so in application.js:

```js
//= require jquery
//= require xray
...
//= require backbone
//= require xray-backbone
```

Backbone support via `xray-backbone` is optional.

## Configuration

By default, Xray will open files with Sublime Text, looking for `/usr/local/bin/subl`.

You can configure this to be your editor of choice in Xray's UI, or create `~/.xrayconfig`, a YAML file.

Example `.xrayconfig`:

```yaml
:editor: '/usr/local/bin/mate'
```

Or for something more complex, use the `$file` placeholder.

```yaml
:editor: "/usr/local/bin/tmux new-window 'vim $file'"
```

## How this works

* At run time, HTML responses from Rails are wrapped with HTML comments containing filepath info.
* Additionally, JS templates and Backbone view constructors are modified during asset compilation.
* A middleware inserts `xray.js`, `xray.css`, and the Xray bar into all successful HTML response bodies.
* When the overlay is shown, `xray.js` examines the inserted filepath info to build the overlay.

## Disabling Xray in particular templates

Xray augments HTML templates by wrapping their contents with HTML comments. For some environments such as [Angular.js](http://angularjs.org/), this can cause Angular templates to stop working because Angular expects only one root node in the template HTML. You can pass in the option `xray: false` to any render statements to ensure Xray does not augment that template. Example:

```ruby
render 'show', xray: false
```

## Contributing

If you have an idea, open an issue and let's talk about it, or fork away and send a pull request.

A laundry list of things to take on:

  * Reveal views from Ember, Knockout, Angular, etc.
  * Overlapping boxes are a problem - parent views in real applications will often be obscured by their children.
  * The current scheme for associating a JS constructor with a filepath is messy and can make stack traces ugly.

Worth noting is that I have plans to solidify xray.js into an API and specification that could be used to aid development in any framework - not just Rails and the asset pipeline.
