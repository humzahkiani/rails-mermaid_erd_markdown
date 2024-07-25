# frozen_string_literal: true

require "rails-mermaid_erd"

module MermaidErdMarkdown
  class SourceData
    def data
      @data ||= RailsMermaidErd::Builder.model_data
    end

    def split_output(depth = 1)
      source_models = data[:Models]
      source_relations = data[:Relations]
      output = []

      source_models.each do |model|
        model_names = [model[:ModelName]]
        search_models = model_names
        relations = []

        depth.times do
          found_relations = []
          next_search_models = []
          search_models.each do |search_model|
            found_relations += related_models(search_model, source_relations)
            next_search_models += related_model_names(search_model, found_relations)
          end
          search_models = next_search_models
          model_names += search_models
          relations += found_relations
        end

        output << {
          Models: models(model_names.uniq, source_models),
          Relations: relations.uniq
        }
      end

      output
    end

    private

    def models(model_names, source_models)
      model_names.map do |model_name|
        source_models.find { |m| m[:ModelName] == model_name }
      end.compact
    end

    def related_model_names(model_name, relations)
      relations.map do |r|
        r[:LeftModelName] == model_name ? r[:RightModelName] : r[:LeftModelName]
      end
    end

    def related_models(model_name, relations)
      relations.select do |relation|
        relation[:LeftModelName] == model_name ||
          relation[:RightModelName] == model_name
      end
    end
  end
end