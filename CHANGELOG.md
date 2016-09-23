# xray-rails Change Log

All notable changes to this project will be documented in this file.

xray-rails is in a pre-1.0 state. This means that its APIs and behavior are
subject to breaking changes without deprecation notices. Until 1.0, version
numbers will follow a [Semver][]-ish `0.y.z` format, where `y` is incremented
when new features or breaking changes are introduced, and `z` is incremented for
lesser changes or bug fixes.

## [Unreleased][]

* Your contribution here!

## [0.2.0][2016-09-22]

* Removed support for Backbone-rendered templates. This feature was particularly
  complex and prone to failure. It will more than likely return in some form in
  the future - for now, if your workflow depends on it, don't upgrade to 0.2.0.
* Removed the dependency on coffee-rails.
* Fixed deprecation warnings from Sprockets 4.

## [0.1.23][] (2016-09-22)

* Add a post-install message regarding future removal of Backbone support.

## [0.1.22][] (2016-09-08)

* If you have not explicitly set an editor, xray-rails now chooses a default
  editor by using the following environment variables: `GEM_EDITOR`, `VISUAL`,
  and `EDITOR`. To explicitly set the editor, use `~/.xrayconfig` as explained
  in the [configuration section](https://github.com/brentd/xray-rails#configuration)
  of the README.

## [0.1.21][] (2016-05-21)

* Fix a regression in 0.1.20 that broke Rails 3.2 apps
  [#72](https://github.com/brentd/xray-rails/pull/72)

## [0.1.20][] (2016-05-18)

* Added support for Rails 5.0.0.rc1.
  [#70](https://github.com/brentd/xray-rails/pull/70)

## [0.1.19][] (2016-05-06)

* Previous releases of xray-rails had a file permissions issue that caused a
  "can't load lib/xray/middleware" error on some systems. This should now be
  fixed. [#59](https://github.com/brentd/xray-rails/pull/59)
* The xray-rails JavaScript is now properly injected after `jquery2`. This means
  that projects using jQuery2 should now work with xray-rails out of the box.
  [#64](https://github.com/brentd/xray-rails/pull/64) @nextekcarl

## [0.1.18][] (2016-01-11)

* xray-rails is now compatible with sprockets-rails 3.0
  [#62](https://github.com/brentd/xray-rails/pull/62) @mattbrictson

## [0.1.17][] (2015-10-18)

* Will no longer attempt to augment mailer templates
* Added hamlc as a supported template (hopefully; needs testing)
* Made the middleware smarter about when to inject xray.js and the bar partial

## [0.1.16][] (2015-05-09)

* Add support for sprockets 3.0
  [#56](https://github.com/brentd/xray-rails/pull/56) @mattbrictson


[Semver]: http://semver.org
[Unreleased]: https://github.com/brentd/xray-rails/compare/v0.1.22...HEAD
[0.1.22]: https://github.com/brentd/xray-rails/compare/v0.1.21...v0.1.22
[0.1.21]: https://github.com/brentd/xray-rails/compare/v0.1.20...v0.1.21
[0.1.20]: https://github.com/brentd/xray-rails/compare/v0.1.19...v0.1.20
[0.1.19]: https://github.com/brentd/xray-rails/compare/v0.1.18...v0.1.19
[0.1.18]: https://github.com/brentd/xray-rails/compare/v0.1.17...v0.1.18
[0.1.17]: https://github.com/brentd/xray-rails/compare/v0.1.16...v0.1.17
[0.1.16]: https://github.com/brentd/xray-rails/compare/v0.1.15...v0.1.16
