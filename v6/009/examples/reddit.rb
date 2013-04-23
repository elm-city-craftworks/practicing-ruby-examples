require_relative "../lib/spyglass/data/history"
require_relative "../lib/spyglass/actions/fetch_links"
require_relative "../lib/spyglass/actions/format_message"
require_relative "../lib/spyglass/actions/deliver_message"

basedir = File.dirname(__FILE__)

history   = Spyglass::Data::History.new("#{basedir}/history.store")
min_score = 20

selected_links = Spyglass.fetch_links("ruby").select do |link| 
  link.score >= min_score && history.new?(link.url) 
end

history.update(selected_links)

message = Spyglass.format_message(links: selected_links, 
                                  template: "#{basedir}/message.erb")

Spyglass.deliver_message(subject: "Links for you!!!!!!", message: message)
