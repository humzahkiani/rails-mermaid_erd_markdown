require "yaml"

module MermaidErdMarkdown
  class Configuration
    attr_accessor :output_path

    def initialize
      config = {
        output_path: "app/models/ERD.md"
      }
      erd_config_path = "erd.yml"

      begin
        erd_yml = YAML.safe_load File.open(erd_config_path)
        @output_path = erd_yml["erd"]["output_path"]
      rescue StandardError
        @output_path = config[:output_path]
      end
    end
  end
end
