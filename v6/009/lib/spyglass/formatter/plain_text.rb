require "erb"

module Spyglass
  module Formatter
    PlainText = ->(links: links, template: template) do
      ERB.new(File.read(template), nil, "-").result(binding)
    end
  end
end
