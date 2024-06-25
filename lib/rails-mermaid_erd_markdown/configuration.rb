# frozen_string_literal: true

require "yaml"

module MermaidErdMarkdown
  class Configuration
    attr_accessor :output_path, :split_output, :relationship_depth

    def initialize
      config = {
        output_path: "app/models/ERD.md",
        split_output: false,
        relationship_depth: 1
      }
      erd_config_path = "erd.yml"

      begin
        erd_yml = YAML.safe_load File.open(erd_config_path)
        @output_path = erd_yml["erd"]["output_path"] || config[:output_path]
        @split_output = erd_yml["erd"]["split_output"] || config[:split_output]
        @relationship_depth = erd_yml["erd"]["relationship_depth"] || config[:relationship_depth]
      rescue StandardError
        @output_path = config[:output_path]
        @split_output = config[:split_output]
        @relationship_depth = config[:relationship_depth]
      end
    end
  end
end
