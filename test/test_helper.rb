# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rails-mermaid_erd_markdown"
require "rails-mermaid_erd_markdown/configuration"
require "rails-mermaid_erd_markdown/generator"
require "rails-mermaid_erd_markdown/markdown_document"
require "rails-mermaid_erd_markdown/source_data"

require "minitest/autorun"