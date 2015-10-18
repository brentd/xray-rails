class TestMailer < ActionMailer::Base
  def hello
    mail to: 'example@example.com', subject: 'hello'
  end
end

