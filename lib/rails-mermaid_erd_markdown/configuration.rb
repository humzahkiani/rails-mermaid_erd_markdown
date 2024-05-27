require "yaml"

class MermaidErdMarkdown::Configuration
  attr_accessor :result_path

  def initialize
    config = {
      result_path: "app/models/ERD.md"
    }

    @result_path = config[:result_path]
  end
end
