require "json"
require "open-uri"
require_relative "../data/link"

module Spyglass
  module LinkFetcher
    Reddit = ->(subreddit) do
      uri = "http://api.reddit.com/r/#{subreddit}?limit=100"

      JSON.parse(open(uri).read)["data"]["children"].map do |e|
        e = e["data"]
        Data::Link.new(url: e["url"], score: e["score"], title: e["title"])
      end
    end
  end
end
