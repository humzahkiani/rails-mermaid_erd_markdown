# frozen_string_literal: true

module MermaidErdMarkdown
  class MarkdownDocument
    attr_accessor :is_show_key, :is_show_comment

    def self.create(&block)
      new.generate(&block)
    end


    def initialize
      @is_show_key = true
      @is_show_comment = true
    end

    def add(element)
      document << element
    end

    def document
      @document ||= []
    end

    def erd(&block)
      add(erd_header)
      block.arity == 1 ? block[self] : instance_eval(&block)
      add(erd_footer)
    end

    def erd_footer
      "```"
    end

    def erd_header
      [
        "```mermaid",
        "erDiagram",
        "    %% --------------------------------------------------------",
        "    %% Entity-Relationship Diagram",
        "    %% --------------------------------------------------------",
        ""
      ].join("\n")
    end

    def erd_relation(relation)
      left_model_name = relation[:LeftModelName].tr(":", "-")
      right_model_name = relation[:RightModelName].tr(":", "-")
      comment = is_show_comment ? ": \"#{relation[:Comment]}\"" : ": \"\""

      "    #{left_model_name} #{relation[:LeftValue]}"\
      "#{relation[:Line]}#{relation[:RightValue]}"\
      " #{right_model_name} #{comment}"
    end

    def erd_table(table_name, model_name)
      lines = [erd_table_header(table_name, model_name)]
      lines << yield
      lines << erd_table_footer
      lines.join("\n")
    end

    def erd_table_column(column)
      key = is_show_key ? column[:key] : ""
      line = "        #{column[:type]} #{column[:name]}"
      line << " #{key}" unless key.empty?
      line
    end

    def erd_table_header(table_name, model_name)
      [
        "    %% table name: #{table_name}",
        "    #{model_name.tr(":", "-")}{"
      ].join("\n")
    end

    def erd_table_footer
      [
        "    }",
        ""
      ].join("\n")
    end

    def header(text)
      "# #{text}\n"
    end

    def generate(&block)
      block.arity == 1 ? block[self] : instance_eval(&block)
      document.join("\n")
    end

    def link(text, url)
      "[#{text}](#{url})"
    end
    
    def list_item(text)
      "- #{text}"
    end

    def subheader(text)
      "## #{text}\n"
    end
  end
end
