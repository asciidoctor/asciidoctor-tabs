# frozen_string_literal: true

module Asciidoctor
  module Tabs
    class Block < ::Asciidoctor::Extensions::BlockProcessor
      use_dsl
      on_context :example

      ID_SEPARATOR_CHAR = '-'
      INVALID_ID_CHARS_RX = /[^a-zA-Z0-9_]/

      def process parent, reader, attrs
        block = create_block parent, :example, nil, attrs, content_model: :compound
        children = (parse_content block, reader).blocks
        return block unless children.size == 1 && (source_tabs = children[0]).context == :dlist && source_tabs.items?
        nodes = []
        tabset_number = parent.document.counter 'tabset-number'
        id = attrs['id'] || %(tabset#{tabset_number})
        nodes << (create_html_fragment parent, %(<div id="#{id}" class="tabset is-loading">))
        tabs = create_list parent, :ulist
        tabs.add_role 'tabs'
        panes = {}
        source_tabs.items.each do |(title), details|
          tab = create_list_item tabs
          tabs << tab
          tab_id = generate_id title.text, id
          tab.text = %([[#{tab_id}]]#{title.instance_variable_get :@text})
          if details.blocks?
            blocks = details.blocks
          elsif details.text?
            blocks = [(create_paragraph parent, (details.instance_variable_get :@text), {})]
          else
            next
          end
          if (block0 = blocks[0]).context == :open && blocks.size == 1 && block0.blocks?
            blocks = block0.blocks
          end
          (panes[tab_id] = blocks).each {|it| it.parent = parent }
        end
        nodes << tabs
        nodes << (create_html_fragment parent, '<div class="content">')
        panes.each do |tab_id, blocks|
          nodes << (create_html_fragment parent, %(<div class="tab-pane" aria-labelledby="#{tab_id}">))
          nodes.push(*blocks)
          nodes << (create_html_fragment parent, '</div>')
        end
        nodes << (create_html_fragment parent, '</div>')
        nodes << (create_html_fragment parent, '</div>')
        nodes.each {|it| parent.blocks << it }
        nil
      end

      private

      def create_html_fragment parent, html
        create_block parent, 'pass', html, nil
      end

      def generate_id str, base_id
        %(#{base_id}_#{str.downcase.gsub INVALID_ID_CHARS_RX, ID_SEPARATOR_CHAR})
      end
    end
  end
end
