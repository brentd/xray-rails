# xray-rails Change Log

All notable changes to this project will be documented in this file.

xray-rails is in a pre-1.0 state. This means that its APIs and behavior are
subject to breaking changes without deprecation notices. Until 1.0, version
numbers will follow a [Semver][]-ish `0.y.z` format, where `y` is incremented
when new features or breaking changes are introduced, and `z` is incremented for
lesser changes or bug fixes.

## [Unreleased][]

* Your contribution here!
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
[Unreleased]: https://github.com/brentd/xray-rails/compare/v0.1.18...HEAD
[0.1.18]: https://github.com/brentd/xray-rails/compare/v0.1.17...v0.1.18
[0.1.17]: https://github.com/brentd/xray-rails/compare/v0.1.16...v0.1.17
[0.1.16]: https://github.com/brentd/xray-rails/compare/v0.1.15...v0.1.16
