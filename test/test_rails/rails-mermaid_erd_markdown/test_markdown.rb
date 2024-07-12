# frozen_string_literal: true

require "test_helper"

class MermaidErdMarkdown::MarkdownTest < Minitest::Test
  def test_generate
    markdown = MermaidErdMarkdown::Markdown.generate do
      add(header("Header"))
      add(subheader("Subheader"))
      add(list_item("List item"))
      add(link("Link", "https://example.com"))
      add("")
    end

    assert_equal <<~MARKDOWN, markdown
      # Header

      ## Subheader

      - List item
      [Link](https://example.com)
    MARKDOWN
  end

  def test_erd
    model = {
      TableName: "table",
      ModelName: "Table",
      IsModelExist: true,
      Columns: [{
        name: "name",
        type: "type",
        key: "key",
        comment: "comment"
      }]
    }
    relation = {
      LeftModelName: "left_model",
      LeftValue: "left_value",
      Line: "--",
      RightValue: "right_value",
      RightModelName: "right_model",
      Comment: "comment"
    }

    markdown = MermaidErdMarkdown::Markdown.generate do
      erd do
        add(
          erd_table(model[:TableName], model[:ModelName]) do
            erd_table_column(model[:Columns].first)
          end
        )
        add(
          erd_relation(relation)
        )
      end
      add("")
    end

    assert_equal <<~MARKDOWN, markdown
      ```mermaid
      erDiagram
          %% --------------------------------------------------------
          %% Entity-Relationship Diagram
          %% --------------------------------------------------------

          %% table name: table
          Table{
              type name key
          }

          left_model left_value--right_value right_model : "comment"
      ```
    MARKDOWN
  end
end
