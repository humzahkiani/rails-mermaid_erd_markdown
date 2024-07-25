# frozen_string_literal: true

require_relative "../../mock_data/models"
require "test_helper"

class MermaidErdMarkdown::DocumentTest < Minitest::Test
  include MockData::Models

  def test_index_markdown
    markdown_file_path = File.expand_path(
      "../../example_output/mock_ERD_index.md", __dir__
    )
    mock_markdown = File.read(markdown_file_path)

    files = {
      "User" => "User.md",
      "Profile" => "Profile.md",
      "Article" => "Article.md",
      "Comment" => "Comment.md"
    }

    result = MermaidErdMarkdown::Document.new.index_markdown(files)

    assert_equal mock_markdown, result
  end

  def test_model_markdown
    markdown_file_path = File.expand_path(
      "../../example_output/mock_ERD_model.md", __dir__
    )
    mock_markdown = File.read(markdown_file_path)

    source = {
      Models: [user_model, article_model, profile_model],
      Relations: [article_relation, profile_relation]
    }

    result = MermaidErdMarkdown::Document.new.model_markdown(source)

    assert_equal mock_markdown, result
  end

  def test_mermaid_markdown
    markdown_file_path =
      File.expand_path("../../example_output/mock_ERD.md", __dir__)
    mock_markdown = File.read(markdown_file_path)

    result = MermaidErdMarkdown::Document.new.mermaid_markdown(
      stubbed_model_data
    )

    assert_equal mock_markdown, result
  end
end
