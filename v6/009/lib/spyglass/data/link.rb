module Spyglass
  module Data
    class Link
      def initialize(url: raise, score: raise, title: raise)
        @url   = url
        @score = score
        @title = title
      end

      attr_reader :url, :score, :title
    end
  end
end
