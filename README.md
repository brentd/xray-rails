Xray
====

### Reveal your UI's bones

The dev tools available to web developers in modern browsers are great. Many of us can't remember what life was like before "Inspect Element". But what we see in the compiled output sent to our browser is often the wrong level of detail - what about being able to visualize the higher level components of your UI? Controllers, templates, partials, Backbone views, etc.

Xray is the missing link between the browser and your app code. Press **cmd+shift+x** (Mac) or **ctrl+shift+x** to reveal an overlay of what files are powering your UI - click anything to open the associated file in your editor. [Here's a GIF](http://f.cl.ly/items/1A0o3y1y3Q13103V3F1l/xray-rails-large.gif) of Xray in action.

![Screenshot](https://dl.dropboxusercontent.com/u/156655/xray-screenshot.png)

## Current Support

Xray is intended to be run on Rails 3.1+ and Ruby 1.9.

So far, Xray can reveal:

  * Rails views and partials
  * Backbone View instances if using the asset pipeline

## Installation

Xray depends on **jQuery**, so it will need to be included in your layout. Backbone is optional.

This gem should only be present during development. Add it to your Gemfile like so:

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

**Note:** for Xray to insert itself into your views automatically, `config.assets.debug = true` (the default) must be set in development.rb. If you disabled this because of slow assets in Rails 3.2.13, [try this monkey patch instead](http://stackoverflow.com/a/15520932/24848) in an initializer.

Otherwise, you can insert Xray's scripts yourself, for example like so in application.js:

```js
//= require jquery
//= require xray
...
//= require backbone
//= require xray-backbone
```

## Configuration

By default, Xray will open files with Sublime Text, looking for `/usr/local/bin/subl`.

You can configure this to be your editor of choice in Xray's UI, or create `~/.xrayconfig`, a YAML file.

Example `.xrayconfig`:

```yaml
:editor: '/usr/local/bin/mate'
```

Or for something more complex, use the `$file` placeholder.

```yaml
:editor: "/usr/local/bin/tmux split-window -v '/usr/local/bin/vim $file'"
```

## How this works

* During asset compilation, JS files and templates are modified to contain file path information.
* A middleware inserts `xray.js`, `xray.css`, and the Xray bar into all successful HTML response bodies.
* When the overlay is shown, `xray.js` examines the file path information inserted during asset compilation.
* Another middleware piggybacks the Rails server to respond to requests to open file paths with the user's desired editor.

## Contributing

If you have an idea, open an issue and let's talk about it, or fork away and send a pull request.

A laundry list of things to take on:

  * Reveal views from Ember, Knockout, Angular, etc.
  * Overlapping boxes are a problem - parent views in real applications will often be obscured by their children.
  * The current scheme for associating a JS constructor with a filepath is messy and can make stack traces ugly.

Worth noting is that I have plans to solidify xray.js into an API and specification that could be used to aid development in any framework - not just Rails and the asset pipeline.
