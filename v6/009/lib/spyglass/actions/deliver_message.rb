require "mail"

Mail.defaults do
  delivery_method :smtp, {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :user_name            => ENV["GMAIL_USER"],
    :password             => ENV["GMAIL_PASSWORD"],
    :authentication       => :plain,
    :enable_starttls_auto => true
  }
end

module Spyglass  
  def self.deliver_message(message: raise, subject: raise)
    mail = Mail.new

    mail.from = ENV["GMAIL_USER"]
    mail.to   = ENV["SPYGLASS_RECIPIENT"]

    mail.subject = subject
    mail.body    = message 

    mail.deliver!
  end
end
