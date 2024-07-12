# frozen_string_literal: true

require_relative "rails-mermaid_erd_markdown/document"
require "rake"
require "rake/dsl_definition"

module MermaidErdMarkdown
  extend Rake::DSL

  class << self
    def perform
      MermaidErdMarkdown::Document.generate
    end
  end

  desc "Generate/update mermaid ERD diagram(s) for database Models."
  task generate_erd: :environment do
    perform
  end
end
