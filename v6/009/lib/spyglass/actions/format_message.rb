require "erb"

module Spyglass
  def self.format_message(links: raise, template: raise)
    ERB.new(File.read(template), nil, "-").result(binding)
  end
end
