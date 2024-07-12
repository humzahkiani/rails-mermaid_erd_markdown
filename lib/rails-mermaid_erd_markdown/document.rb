# frozen_string_literal: true

require_relative "configuration"
require_relative "markdown"
require "digest/md5"
require "logger"
require "pathname"
require "rails-mermaid_erd"

module MermaidErdMarkdown
  class Document
    attr_writer :logger

    def self.generate
      new.generate
    end

    def generate
      return unless find_or_create_output
      return unless erd_changed?

      update_erd

      update_split_erds if configuration.split_output
    end

    def index_markdown(files)
      MermaidErdMarkdown::Markdown.generate do |doc|
        doc.add(doc.header("Entity Relationship Diagrams"))
        doc.add(
          "Each model has its own ERD diagram. The diagram shows the "\
          "selected model, plus #{configuration.relationship_depth} "\
          "associated model(s) deep. Click on the model name to view "\
          "the diagram.\n"
        )
        doc.add(doc.subheader("Models"))
        files.each do |model, path|
          doc.add(doc.list_item(doc.link(model, "../#{path}")))
        end
        doc.add("")
      end
    end

    def model_markdown(output)
      MermaidErdMarkdown::Markdown.generate do |doc|
        model_name = output[:Models].first[:ModelName]
        doc.add(doc.header("#{model_name} Entity-Relationship Diagram"))
        doc.add(doc.subheader("Associated Models"))
        output[:Models].each do |model|
          next if model[:ModelName] == model_name

          model_path = "../#{output_path(model[:ModelName])}"

          doc.add(doc.list_item(doc.link(model[:ModelName], model_path)))
        end
        doc.add("")
        doc.add(doc.subheader("Entity-Relationship Diagram"))
        doc.add(mermaid_markdown(output))
      end
    end

    def mermaid_markdown(source)
      MermaidErdMarkdown::Markdown.generate do |doc|
        doc.erd do |erd|
          erd.add(
            source[:Models].map do |model|
              erd.erd_table(model[:TableName], model[:ModelName]) do
                model[:Columns].map do |column|
                  erd.erd_table_column(column)
                end
              end
            end
          )
          erd.add(
            source[:Relations].map do |relation|
              erd.erd_relation(relation)
            end
          )
        end
      end
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
        log.progname = self.class.name.split("::").first
      end
    end

    def models(model_names, source_models)
      model_names.map do |model_name|
        source_models.find { |m| m[:ModelName] == model_name }
      end.compact
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
      logger.info("ERD writing to #{output_path}...")
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
end
