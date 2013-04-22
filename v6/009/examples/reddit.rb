require_relative "../lib/spyglass/link_fetcher/reddit"
require_relative "../lib/spyglass/data/history"
require_relative "../lib/spyglass/formatter/plain_text"
require_relative "../lib/spyglass/messenger/gmail"

basedir = File.dirname(__FILE__)

history   = Spyglass::Data::History.new("#{basedir}/history.store")
min_score = 20

selected_links = Spyglass::LinkFetcher::Reddit.("ruby").select do |r| 
  r.score >= min_score && history.new?(r.url) 
end

history.update(selected_links)

message = Spyglass::Formatter::PlainText.
            (links: selected_links, template: "#{basedir}/message.erb")

Spyglass::Messenger::DeliverGmail.
  (subject: "Links for you!!!!!!", message: message)
