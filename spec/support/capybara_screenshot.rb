require 'capybara-screenshot/rspec'

Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.prune_strategy = { keep: 20 }

RSpec.configure do |config|
  # Not just for type: :feature
  config.after do |example_from_block_arg|
    # RSpec 3 no longer defines `example`, but passes the example as block argument instead
    example = config.respond_to?(:expose_current_running_example_as) ? example_from_block_arg : self.example

    if example.exception && ENV['CI']
      puts page.html
    end
    Capybara::Screenshot::RSpec.after_failed_example(example)
  end
end
