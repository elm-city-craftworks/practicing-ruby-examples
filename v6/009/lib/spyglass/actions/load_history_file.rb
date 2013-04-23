require_relative "../data/history"

module Spyglass
  def self.load_history_file(filename)
    Data::History.new(filename)
  end
end
