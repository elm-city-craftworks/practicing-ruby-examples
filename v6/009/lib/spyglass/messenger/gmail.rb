require 'mail'

# Set up delivery defaults to use Gmail
Mail.defaults do
  delivery_method :smtp, { 
    :address => 'smtp.gmail.com',
    :port => '587',
    :user_name => ENV['GMAIL_USER'],
    :password => ENV['GMAIL_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end

module Spyglass
  module Messenger
    Gmail = ->(message: raise, recipient: raise, subject: raise) do
      mail = Mail.new

      mail.from = Mail.delivery_method.settings[:user_name]
      mail.to   = recipient

      mail.subject = subject
      mail.body    = message 

      mail.deliver!
    end
  end
end
