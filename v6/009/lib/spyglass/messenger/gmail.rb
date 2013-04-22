require 'mail'

Mail.defaults do
  delivery_method :smtp, { 
    :address => 'smtp.gmail.com',
    :port => '587',
    :user_name => ENV["GMAIL_USER"],
    :password =>  ENV["GMAIL_PASSWORD"],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end

module Spyglass
  module Messenger
    DeliverGmail = ->(message: raise, subject: raise) do
      mail = Mail.new

      mail.from = ENV["GMAIL_USER"]
      mail.to   = ENV["SPYGLASS_RECIPIENT"]

      mail.subject = subject
      mail.body    = message 

      mail.deliver!
    end
  end
end
