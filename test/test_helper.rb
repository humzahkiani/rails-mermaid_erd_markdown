# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rails-mermaid_erd_markdown"
require "rails-mermaid_erd_markdown/configuration"

require "minitest/autorun"
require File.expand_path("./dummy-rails/config/environment", __dir__)
