# frozen_string_literal: true

require_relative "rails-mermaid_erd_markdown/configuration"
require "digest/md5"
require "rake"
require "rake/dsl_definition"
require "pathname"
require "logger"

module MermaidErdMarkdown
  extend Rake::DSL

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end

    def configuration
      @configuration ||= MermaidErdMarkdown::Configuration.new
    end

    def perform
      new_erd = generate_mermaid_erd
      current_erd_path = Pathname.new(configuration.result_path)

      unless current_erd_path.exist?
        logger.info("ERD does not currently exist. Creating...")
        create_erd_file(new_erd)
        logger.info("ERD successfully created")
        return
      end

      current_erd = File.read(current_erd_path)

      update_erd_file(current_erd, new_erd)
    end

    private

    def update_erd_file(current_erd, new_erd)
      # check if two diagrams are the same by comparing their MD5 hashes
      if Digest::MD5.hexdigest(current_erd) == Digest::MD5.hexdigest(new_erd)
        logger.info("ERD already exists and is up to date. Skipping...")
        return
      end

      logger.info("ERD already exists but is out of date. Overwriting...")
      File.write(configuration.result_path, new_erd)
      logger.info("ERD successfully updated")

      nil
    end

    def create_erd_file(erd)
      File.write(configuration.result_path, erd)

      nil
    end

    def generate_mermaid_erd
      data = RailsMermaidErd::Builder.model_data

      is_show_key = true
      is_show_relation_comment = true

      lines = ["```mermaid"]
      lines << "erDiagram"
      lines << "    %% --------------------------------------------------------"
      lines << "    %% Entity-Relationship Diagram"
      lines << "    %% --------------------------------------------------------"
      lines << ""

      data[:Models].each do |model|
        lines << "    %% table name: #{model[:TableName]}"
        lines << "    #{model[:ModelName].tr(":", "-")}{"

        model[:Columns].each do |column|
          key = is_show_key ? column[:key] : ""
          lines << "        #{column[:type]} #{column[:name]} #{key} "
        end

        lines << "    }"
        lines << ""
      end

      data[:Relations].each do |relation|
        left_model_name = relation[:LeftModelName].tr(":", "-")
        right_model_name = relation[:RightModelName].tr(":", "-")
        comment = is_show_relation_comment ? ": \"#{relation[:Comment]}\"" : ": \"\""

        lines << "    #{left_model_name} #{relation[:LeftValue]}#{relation[:Line]}#{relation[:RightValue]} #{right_model_name} #{comment}"
      end

      lines << "```"
      lines.join("\n")
    end
  end

  desc "Generate mermaid ERD diagram for database Models. "
  task update_erd: :environment do
    perform
  end
end
