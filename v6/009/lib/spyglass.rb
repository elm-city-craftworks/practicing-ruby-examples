  def self.deliver_message(message: raise, subject: raise)
    mail = Mail.new

    mail.from = ENV["GMAIL_USER"]
    mail.to   = ENV["SPYGLASS_RECIPIENT"]

    mail.subject = subject
    mail.body    = message 

    mail.deliver!
  end
end
