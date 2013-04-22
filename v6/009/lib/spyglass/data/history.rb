require "pstore"

module Spyglass
  module Data
    class History
      def initialize(filename)
        @store = PStore.new(filename)
      end

      def new?(url)
        @store.transaction { @store[url].nil? }
      end

      def update(links)
        @store.transaction do
          links.each { |link| @store[link.url] = true }
        end
      end
    end
  end
end
