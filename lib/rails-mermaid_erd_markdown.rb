# frozen_string_literal: true

require_relative "rails-mermaid_erd_markdown/configuration"
require "rails-mermaid_erd"
require "digest/md5"
require "rake"
require "rake/dsl_definition"
require "pathname"
require "logger"

module MermaidErdMarkdown
  extend Rake::DSL

  class << self
    attr_writer :logger

    def perform
      return unless find_or_create_output
      return unless erd_changed?

      update_erd

      update_split_erds if configuration.split_output
    end

    def index_markdown(files)
      lines = ["# Entity Relationship Diagrams"]
      lines << ""
      lines << "Each model has its own ERD diagram. The diagram shows the "\
        "selected model, plus #{configuration.relationship_depth} "\
        "associated model(s) deep. Click on the model name to view "\
        "the diagram."
      lines << ""
      lines << "## Models"
      lines << ""
      files.each do |model, path|
        lines << "- [#{model}](#{path})"
      end
      lines << ""
      lines.join("\n")
    end

    def model_markdown(output)
      model_name = output[:Models].first[:ModelName]
      lines = ["# #{model_name} Entity-Relationship Diagram"]
      lines << ""
      lines << "## Associated Models"
      lines << ""
      output[:Models].each do |model|
        next if model[:ModelName] == model_name

        model_path = output_path(model[:ModelName])
        lines << "- [#{model[:ModelName]}](#{model_path})"
      end
      lines << ""
      lines << "## Entity-Relationship Diagram"
      lines << ""
      "#{lines.join("\n")}\n#{mermaid_markdown(output)}"
    end

    def mermaid_markdown(source)
      is_show_key = true
      is_show_relation_comment = true

      lines = ["```mermaid"]
      lines << "erDiagram"
      lines << "    %% --------------------------------------------------------"
      lines << "    %% Entity-Relationship Diagram"
      lines << "    %% --------------------------------------------------------"
      lines << ""

      source[:Models].each do |model|
        lines << "    %% table name: #{model[:TableName]}"
        lines << "    #{model[:ModelName].tr(":", "-")}{"

        model[:Columns].each do |column|
          key = is_show_key ? column[:key] : ""
          column_line = "        #{column[:type]} #{column[:name]}"
          column_line << " #{key}" unless key.empty?
          lines << column_line
        end

        lines << "    }"
        lines << ""
      end

      source[:Relations].each do |relation|
        left_model_name = relation[:LeftModelName].tr(":", "-")
        right_model_name = relation[:RightModelName].tr(":", "-")
        comment = is_show_relation_comment ? ": \"#{relation[:Comment]}\"" : ": \"\""

        lines << "    #{left_model_name} #{relation[:LeftValue]}#{relation[:Line]}#{relation[:RightValue]} #{right_model_name} #{comment}"
      end

      lines << "```"
      lines.join("\n")
    end

    def split_output(source, depth = 1)
      source_models = source[:Models]
      source_relations = source[:Relations]
      output = []

      source_models.each do |model|
        model_names = [model[:ModelName]]
        search_models = model_names
        relations = []

        depth.times do
          found_relations = []
          next_search_models = []
          search_models.each do |search_model|
            found_relations += related_models(search_model, source_relations)
            next_search_models += related_model_names(search_model, found_relations)
          end
          search_models = next_search_models
          model_names += search_models
          relations += found_relations
        end

        output << {
          Models: models(model_names.uniq, source_models),
          Relations: relations.uniq
        }
      end

      output
    end

    private

    def comprehensive_erd
      @comprehensive_erd ||= mermaid_markdown(data)
    end

    def configuration
      @configuration ||= MermaidErdMarkdown::Configuration.new
    end

    def data
      @data ||= RailsMermaidErd::Builder.model_data
    end

    def erd_changed?
      # check if two diagrams are the same by comparing their MD5 hashes
      existing_erd_hash = Digest::MD5.hexdigest(File.read(output_path))
      new_erd_hash = Digest::MD5.hexdigest(comprehensive_erd)

      return true if existing_erd_hash != new_erd_hash

      logger.info("ERD already exists and is up to date. Skipping...")

      false
    end

    def find_or_create_output
      return true if output_path.exist?

      logger.info("ERD does not currently exist at result path. Creating...")
      begin
        write_file("", output_path)
        logger.info("ERD successfully created at #{output_path}")
      rescue StandardError
        logger.info("Could not create ERD. Output path is invalid.")

        false
      end

      true
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end

    def models(model_names, source_models)
      model_names.map do |model_name|
        source_models.find { |m| m[:ModelName] == model_name }
      end
    end

    def output_path(extension = nil)
      return Pathname.new(configuration.output_path) unless extension

      Pathname.new(configuration.output_path).sub_ext("_#{extension}.md")
    end

    def related_model_names(model_name, relations)
      relations.map do |r|
        r[:LeftModelName] == model_name ? r[:RightModelName] : r[:LeftModelName]
      end
    end

    def related_models(model_name, relations)
      relations.select do |relation|
        relation[:LeftModelName] == model_name ||
          relation[:RightModelName] == model_name
      end
    end

    def update_erd
      logger.info("ERD writting to #{output_path}...")
      write_file(comprehensive_erd, output_path)
      logger.info("ERD successfully written")
    end

    def update_split_erds
      # first remove all existing model ERD files
      Dir.glob(output_path.sub_ext("_*.md")).each do |file|
        File.delete(file)
      end

      files = {}

      split_output(data, configuration.relationship_depth).each do |output|
        model_name = output[:Models].first[:ModelName]
        model_path = output_path(model_name)
        write_file(model_markdown(output), model_path)
        logger.info("ERD successfully written to #{model_path}")
        files[model_name] = model_path
      end

      index_path = output_path("index")
      write_file(index_markdown(files), index_path)
    end

    def write_file(new_erd, path)
      File.write(path, new_erd)
    end
  end

  desc "Generate/update mermaid ERD diagram for database Models."
  task generate_erd: :environment do
    perform
  end
end
