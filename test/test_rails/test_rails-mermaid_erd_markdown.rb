# frozen_string_literal: true

require "test_helper"
require "rails-mermaid_erd"

class MermaidErdMarkdownTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil MermaidErdMarkdown::VERSION
  end

  def setup
    markdown_file_path = File.expand_path("../../test/util/mock_ERD.md", __dir__)
    mock_erd = File.read(markdown_file_path)
    @mock_erd = mock_erd
  end

  def test_generate_mermaid_erd
    stubbed_model_data = {
      Models: [
        { TableName: "articles", ModelName: "Article", IsModelExist: true,
          Columns: [
            { name: "id", type: :integer, key: "PK", comment: nil },
            { name: "title", type: :string, key: "", comment: nil },
            { name: "content", type: :text, key: "", comment: nil },
            { name: "created_at", type: :datetime, key: "", comment: nil },
            { name: "updated_at", type: :datetime, key: "", comment: nil }
          ] },
        { TableName: "comments", ModelName: "Comment", IsModelExist: true,
          Columns: [
            { name: "id", type: :integer, key: "PK", comment: nil },
            { name: "commenter", type: :string, key: "", comment: nil },
            { name: "body", type: :text, key: "", comment: nil },
            { name: "article_id", type: :integer, key: "FK", comment: nil },
            { name: "created_at", type: :datetime, key: "", comment: nil },
            { name: "updated_at", type: :datetime, key: "", comment: nil }
          ] }
      ], Relations: [
        { LeftModelName: "Comment", LeftValue: "}o", Line: "--", RightModelName: "Article",
          RightValue: "||", Comment: "BT:article" }
      ]
    }
    result = nil

    RailsMermaidErd::Builder.stub :model_data, stubbed_model_data do
      result = MermaidErdMarkdown.generate_mermaid_erd
    end
    assert_equal @mock_erd, result
  end
end
