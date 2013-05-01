# Xray

### Reveal the structure of your UI.

The dev tools available to web developers in modern browsers are great. Many of us can't remember what life was like before "Inspect Element". But what we see in the compiled output sent to our browser is often the wrong level of detail - what about being able to visualize the higher level components of your UI? Controllers, templates, partials, Backbone views, etc.

Xray is the missing link between the browser and your app code. Press **cmd+ctrl+x** to reveal an overlay of what files are powering your UI - click anything to open the associated file in your editor.

![Screenshot](http://dl.dropbox.com/u/156655/Screenshots/xgf7ukh3fya-.png)

### Current Support

Xray is in early stages and currently supports only Rails 3.1+ with use of the asset pipeline as a requirement.

So far, Xray can reveal:

  * Rails views and partials
  * Backbone View instances

### Installation

Add to your Gemfile, preferably under your development group:

```ruby
group :development do
  ...
  gem 'xray-rails'
end
```

Then bundle and delete your cached assets:

```
$ bundle && rm -rf tmp/cache/assets
```

Restart your app, open your browser, and press `cmd+ctrl+x` to see the overlay.

### Configuration

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

### How this works

* During asset compilation, JS files and templates are modified to contain file path information.
* A middleware inserts `xray.js`, `xray.css`, and the Xray bar into all successful HTML response bodies.
* When the overlay is shown, `xray.js` examines the file path information inserted during asset compilation.
* Another middleware piggybacks the Rails server to respond to requests to open file paths with the user's desired editor.

### Contributing

If you have an idea, open an issue and let's talk about it, or fork away and send a pull request.

A laundry list of things to take on:

  * Reveal views from Ember, Knockout, Angular, etc.
  * Overlapping boxes are a problem - parent views in real applications will often be obscured by their children.
  * The current scheme for associating a JS constructor with a filepath is messy and can make stack traces ugly.

Worth noting is that I have plans to solidify xray.js into an API and specification that could be used to aid development in any framework - not just Rails and the asset pipeline.
