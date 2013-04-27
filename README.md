# Xray

### Reveal the structure of your UI.

The dev tools available to web developers in modern browsers are great. Many of us can't remember what life was like before "Inspect Element". But what we see in the compiled output sent to our browser is often the wrong level of detail - what about being able to visualize the higher level components of your UI? Controllers, templates, partials, Backbone views, etc. On top of that, why in 2013 can I not click something in the browser and have the code revealed in my editor of choice?

Xray is the missing link between the browser and your app code.

**Disclaimer:** Xray is in early stages and currently supports only Rails 3.1+ with use of the asset pipeline as a requirement.

### Installation

Add to your Gemfile, preferably under your development group:

```ruby
group :development do
  ...
  gem 'xray-rails', github: 'brentd/xray-rails'
end
```

Then bundle and delete your cached assets:

```
$ bundle && rm -rf tmp/cache/assets
```

Restart your app, open your browser, and press `cmd+ctrl+x` to see the overlay.


### Configuration

By default, Xray will open files with Sublime Text, looking for `/usr/local/bin/subl`.

You can configure this to be your editor of choice in Xray's UI, or create `~/.xrayconfig`, which is a YAML file.

Example `.xrayconfig`:

```yaml
:editor: '/usr/local/bin/mate'
```

Or for something more complex, use the `$file` placeholder.

```yaml
:editor: "/usr/local/bin/tmux split-window -v '/usr/local/bin/vim $file'"
```

### How this works

* During asset compilation, JS files and templates are augmented to contain file path information.
* On each request, a bit of information is gathered and put into `Xray.request_info` to be used by the dev bar.
* A middleware inserts `xray.js`, `xray.css`, and the Xray bar to all successful HTML response bodies.
* When the overlay is shown, `xray.js` examines the augmented file path information inserted during asset compilation.
* Another middleware piggybacks the Rails server to respond to requests to open file paths with the user's desired editor.

### TODO:

  * Finish settings panel where editor can be changed; currently hardcoded to `/usr/local/bin/subl`
  * Better handle overlapping views in overlay
  * Allow Xray bar to be hidden when overlay is not shown
  * ~~Add buttons to Xray bar to trigger the overlay for templates and Backbone views~~
  * Visualize major CSS components
  * Jump to correct line number in editor

