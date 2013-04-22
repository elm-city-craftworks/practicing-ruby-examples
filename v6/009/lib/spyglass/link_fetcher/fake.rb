require "faker"
require_relative "../data/link"

module Spyglass
  module LinkFetcher
    Fake = ->(subreddit) do
      100.times.map do
        Data::Link.new(url: "http://#{Faker::Internet.domain_name}",
                       score: rand(15..25),
                       title: Faker::Company.catch_phrase)
      end
    end
  end
end
