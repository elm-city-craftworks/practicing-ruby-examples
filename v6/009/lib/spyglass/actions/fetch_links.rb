require "json"
require "open-uri"

require_relative "../data/link"

module Spyglass
  def self.fetch_links(category)
    document = open("http://api.reddit.com/r/#{category}?limit=100").read

    JSON.parse(document)["data"]["children"].map do |e|
      e = e["data"]

      Data::Link.new(url: e["url"], score: e["score"], title: e["title"])
    end
  end
end
