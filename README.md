# rails-mermaid_erd_markdown

A Ruby on Rails gem that extends rails-mermaid_erd to generate mermaid Entity-Relationship Diagrams (ERD) for ActiveRecord Models. When combined with Continuous Integration (CI) pipelines, it enables one to generate living, self-updating documentation of their data. 

## Example Entity-Relationship Diagram

```mermaid
erDiagram
    %% --------------------------------------------------------
    %% Entity-Relationship Diagram
    %% --------------------------------------------------------

    %% table name: articles
    Article{
        integer id PK 
        string title  
        text content  
        datetime created_at  
        datetime updated_at  
    }

    %% table name: comments
    Comment{
        integer id PK 
        string commenter  
        text body  
        integer article_id FK 
        datetime created_at  
        datetime updated_at  
    }

    Comment }o--|| Article : "BT:article"
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-mermaid_erd_markdown'
```

Or install it yourself as:

    $ gem install rails-mermaid_erd_markdown

## Usage

### Generating ERDs
To generate the comprehensive mermaid ERD in markdown, run one of the following:
   ```
   rails generate_erd
   ``` 
   OR
   ```
   rake generate_erd
   ``` 
**If all of your models do not appear, be sure to eager load them first.** 

### Configuration 
You can configure the ERD generation by creating a `erd.yml` file in your root, and modifying the following fields. 

``` 
# erd.yml
erd:
    output_path: 'app/ERD.md' # Set output path of ERDs, default: 'app/ERD.md'
    split_output: false, # Generates individual ERDs for each model with a specified depth, default: false
    relationship_depth: 1 # Configured depth of individual ERD model generation, default: 1
    ignored_models: # Models to be filtered out of all ERDs (case-sensitive)
        - Article 
        - Comment

```

If your entity diagram is too large to be displayed you can set a `split_output` configuration to `true` to generate multiple ERD files based on each model in your project. 

Or you can specify the models to be filtered out of the ERDs using `ignored_models`

You can also set a `relationship_depth` configuration to include more than 1 level (the default) of associations in each document.


### Viewing Diagrams

You can view the ERD by navigating to the file in Github, which supports rendering mermaid diagrams from code. If you are a Visual Studio Code user, you can use any markdown preview extension such as [Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced) view the ERD directly in your IDE.


### Integration with CI Pipeline
The most value of this gem comes with the integration of it's diagram generation into your CI. The amount of effort required to update documentation has always been the greatest deterrant to creating new documentation. By integrating this rake task into your CI, you can have the CI update the model for you anytime that it changes. 

The following is a Github Actions job example for how one might do this for a Rails app that uses PostgreSQL: 

```yml
permissions:
  contents: write
  packages: read

jobs:
  update-erd:
      runs-on: ubuntu-latest
      services:
          postgres:
              image: postgres
              env:
                  POSTGRES_USER: postgres
                  POSTGRES_PASSWORD: postgres
              ports:
              - 5432:5432
              options:
              - --health-cmd="pg_is_ready" --health-interval=10s --health-timeout=5s --health-retries=3
      steps:
      - name: Install packages
        run:
          sudo apt-get update && sudo apt-get install --no-install-recommends -y google-chrome-stable curl libvips postgresql-client libpq-dev
      - name: Checkout code
        uses: actions/checkout@v4
        with: 
          ref: ${{ github.event.pull_request.head.ref }}
      - name: Setup database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432
        run: bin/rails db:setup
      - name: Setup database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432
        run: bin/rails generate_erd
      - name: Commit and Push Updated ERD
        run: |
          git config --global user.name 'Github Actions Bot'
          git config --global user.email 'actions/@users.noreply.github.com'
          git add app/models/ERD.md 
          git commit -m "Update ERD" || echo "No changes to commit"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rails-mermaid_erd_markdown. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rails-mermaid_erd_markdown/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the rails-mermaid_erd_markdown project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rails-mermaid_erd_markdown/blob/master/CODE_OF_CONDUCT.md).
