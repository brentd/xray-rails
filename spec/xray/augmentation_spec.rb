require 'spec_helper'

describe "Xray.augment_template" do
  it "wraps HTML source with comments containing the path" do
    allow(Xray).to receive(:next_id).and_return(1)
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

  it "does not wrap templates beginning with a doctype" do
    source = <<-END.unindent
      <!DOCTYPE html>
      <html>foo</html>
    END
    augmented = Xray.augment_template(source, "/path/to/file.html.erb")
    expect(augmented).to eql <<-END.unindent
      <!DOCTYPE html>
      <html>foo</html>
    END
  end
end
