module MockData
  module Models
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
end