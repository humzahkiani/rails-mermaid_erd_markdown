# frozen_string_literal: true

require_relative "../../mock_data/models"
require "test_helper"

class MermaidErdMarkdown::SourceDataTest < Minitest::Test
  include MockData::Models

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

    RailsMermaidErd::Builder.stub :model_data, stubbed_model_data do
      result = MermaidErdMarkdown::SourceData.new.split_output

      assert_equal expected, result
    end
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

    RailsMermaidErd::Builder.stub :model_data, stubbed_model_data do
      result = MermaidErdMarkdown::SourceData.new.split_output(2)

      assert_equal expected, result
    end
  end
end
