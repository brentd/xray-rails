require 'spec_helper'

describe "Xray.augment_js" do
  it "finds and augments constructors created with extend()" do
    source = <<-END
      MyView = Backbone.View.extend({
        initialize: function() {
        }
      });
    END
    augmented = Xray.augment_js(source, "/path/to/file.js")
    expect(augmented).to eql <<-END
      MyView = (window.XrayPaths||(window.XrayPaths={}))['{"name":"MyView","path":"/path/to/file.js"}'] = Backbone.View.extend({
        initialize: function() {
        }
      });
    END
  end

  it "finds and augments constructors created by coffeescript" do
    source = <<-END
      MyView = (function(_super) {
        __extends(MyView, _super);

        function MyView() {
          _ref = MyView.__super__.constructor.apply(this, arguments);
          return _ref;
        }

        return MyView;

      })(Backbone.View);
    END
    augmented = Xray.augment_js(source, "/path/to/file.js")
    expect(augmented).to eql <<-END
      MyView = (window.XrayPaths||(window.XrayPaths={}))['{"name":"MyView","path":"/path/to/file.js"}'] = (function(_super) {
        __extends(MyView, _super);

        function MyView() {
          _ref = MyView.__super__.constructor.apply(this, arguments);
          return _ref;
        }

        return MyView;

      })(Backbone.View);
    END
  end
end

describe "Xray.augment_template" do
  it "wraps HTML source with comments containing the path" do
    source = <<-END.unindent
      <div class="container">
      </div>
    END
    augmented = Xray.augment_template(source, "/path/to/file.html.erb")
    expect(augmented).to eql <<-END.unindent
      <!--XRAY START 1 /path/to/file.html.erb-->
      <div class="container">
      </div>
      <!--XRAY END 1-->
    END
  end
end