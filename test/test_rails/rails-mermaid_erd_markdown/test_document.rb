# frozen_string_literal: true

require "test_helper"

class MermaidErdMarkdown::DocumentTest < Minitest::Test
  def test_index_markdown
    markdown_file_path = File.expand_path(
      "../../../test/util/mock_ERD_index.md", __dir__
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
      "../../../test/util/mock_ERD_model.md", __dir__
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
      File.expand_path("../../../test/util/mock_ERD.md", __dir__)
    mock_markdown = File.read(markdown_file_path)

    result = MermaidErdMarkdown::Document.new.mermaid_markdown(stubbed_model_data)

    assert_equal mock_markdown, result
  end

  def test_split_output
    expected_user = {
      Models: [user_model, article_model, profile_model],
      Relations: [article_relation, profile_relation]
    }
    expected_profile = {
      Models: [profile_model, user_model],
      Relations: [profile_relation]
    }
    expected_article = {
      Models: [article_model, user_model, comment_model],
      Relations: [article_relation, comment_relation]
    }
    expected_comment = {
      Models: [comment_model, article_model],
      Relations: [comment_relation]
    }
    expected = [
      expected_user,
      expected_profile,
      expected_article,
      expected_comment
    ]

    result = MermaidErdMarkdown::Document.new.split_output(stubbed_model_data)

    assert_equal expected, result
  end

  def test_split_output_with_depth
    expected_user = {
      Models: [user_model, article_model, profile_model, comment_model],
      Relations: [article_relation, profile_relation, comment_relation]
    }
    expected_profile = {
      Models: [profile_model, user_model, article_model],
      Relations: [profile_relation, article_relation]
    }
    expected_article = {
      Models: [article_model, user_model, comment_model, profile_model],
      Relations: [article_relation, comment_relation, profile_relation]
    }
    expected_comment = {
      Models: [comment_model, article_model, user_model],
      Relations: [comment_relation, article_relation]
    }
    expected = [
      expected_user,
      expected_profile,
      expected_article,
      expected_comment
    ]

    result = MermaidErdMarkdown::Document.new.split_output(stubbed_model_data, 2)

    assert_equal expected, result
  end

  def user_model
    {
      TableName: "users", ModelName: "User", IsModelExist: true,
      Columns: [
        { name: "id", type: :integer, key: "PK", comment: nil },
        { name: "name", type: :string, key: "", comment: nil },
        { name: "email", type: :string, key: "", comment: nil },
        { name: "created_at", type: :datetime, key: "", comment: nil },
        { name: "updated_at", type: :datetime, key: "", comment: nil }
      ]
    }
  end

  def profile_model
    {
      TableName: "profiles", ModelName: "Profile", IsModelExist: true,
      Columns: [
        { name: "id", type: :integer, key: "PK", comment: nil },
        { name: "bio", type: :text, key: "", comment: nil },
        { name: "user_id", type: :integer, key: "FK", comment: nil },
        { name: "created_at", type: :datetime, key: "", comment: nil },
        { name: "updated_at", type: :datetime, key: "", comment: nil }
      ]
    }
  end

  def article_model
    {
      TableName: "articles", ModelName: "Article", IsModelExist: true,
      Columns: [
        { name: "id", type: :integer, key: "PK", comment: nil },
        { name: "title", type: :string, key: "", comment: nil },
        { name: "content", type: :text, key: "", comment: nil },
        { name: "user_id", type: :integer, key: "FK", comment: nil },
        { name: "created_at", type: :datetime, key: "", comment: nil },
        { name: "updated_at", type: :datetime, key: "", comment: nil }
      ]
    }
  end

  def comment_model
    {
      TableName: "comments", ModelName: "Comment", IsModelExist: true,
      Columns: [
        { name: "id", type: :integer, key: "PK", comment: nil },
        { name: "commenter", type: :string, key: "", comment: nil },
        { name: "body", type: :text, key: "", comment: nil },
        { name: "article_id", type: :integer, key: "FK", comment: nil },
        { name: "created_at", type: :datetime, key: "", comment: nil },
        { name: "updated_at", type: :datetime, key: "", comment: nil }
      ]
    }
  end

  def article_relation
    {
      LeftModelName: "Article",
      LeftValue: "}o",
      Line: "--",
      RightModelName: "User",
      RightValue: "||",
      Comment: "BT:user"
    }
  end

  def profile_relation
    {
      LeftModelName: "Profile",
      LeftValue: "}o",
      Line: "--",
      RightModelName: "User",
      RightValue: "||",
      Comment: "BT:user"
    }
  end

  def comment_relation
    {
      LeftModelName: "Comment",
      LeftValue: "}o",
      Line: "--",
      RightModelName: "Article",
      RightValue: "||",
      Comment: "BT:article"
    }
  end

  def stubbed_model_data
    {
      Models: [
        user_model,
        profile_model,
        article_model,
        comment_model
      ], Relations: [
        article_relation,
        profile_relation,
        comment_relation
      ]
    }
  end
end
