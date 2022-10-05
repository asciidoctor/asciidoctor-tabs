# frozen_string_literal: true

module Asciidoctor
  module Tabs
    class Block < ::Asciidoctor::Extensions::BlockProcessor
      use_dsl
      on_context :example

      def process parent, reader, attrs
        block = create_block parent, attrs['cloaked-context'], nil, attrs, content_model: :compound
        children = (parse_content block, reader).blocks
        return block unless children.size == 1 && (source_tabs = children[0]).context == :dlist && source_tabs.items?
        unless (doc = parent.document).attr? 'filetype', 'html'
          source_tabs.id ||= attrs['id']
          (reftext = attrs['reftext']) && (source_tabs.set_attr 'reftext', reftext) unless source_tabs.attr? 'reftext'
          return source_tabs
        end
        nodes = []
        tabset_number = doc.counter 'tabset-number'
        id = attrs['id'] || %(#{doc.attributes['idprefix'] || '_'}tabset#{tabset_number})
        nodes << (create_html_fragment parent, %(<div id="#{id}" class="tabset is-loading">))
        (tabs = create_list parent, :ulist).add_role 'tabs'
        panes = {}
        set_id_on_tab = (doc.backend == 'html5') || (list_item_supports_id? doc)
        source_tabs.items.each do |labels, content|
          tab_ids = labels.map do |tab|
            tabs << tab
            tab_id = generate_id tab.text, id, doc
            set_id_on_tab ? (tab.id = tab_id) : (tab.text = %([[#{tab_id}]]#{tab.instance_variable_get :@text}))
            tab_id
          end
          if content
            if content.blocks?
              if (block0 = (blocks = content.blocks)[0]).context == :open && blocks.size == 1 && block0.blocks?
                blocks = block0.blocks
              end
            elsif content.text?
              blocks = [(create_paragraph parent, (content.instance_variable_get :@text), {})]
            end
          end
          (panes[tab_ids] = blocks || []).each {|it| it.parent = parent }
        end
        nodes << tabs
        nodes << (create_html_fragment parent, '<div class="content">')
        panes.each do |tab_ids, blocks|
          nodes << (create_html_fragment parent, %(<div class="tab-pane" aria-labelledby="#{tab_ids.join ' '}">))
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

      def generate_id str, base_id, doc
        restore_idprefix = (attrs = doc.attributes)['idprefix']
        attrs['idprefix'] = %(#{base_id}#{attrs['idseparator'] || '_'})
        ::Asciidoctor::Section.generate_id str, doc
      ensure
        restore_idprefix ? (attrs['idprefix'] = restore_idprefix) : (attrs.delete 'idprefix')
      end

      def list_item_supports_id? doc
        if (converter = doc.converter).instance_variable_defined? :@list_item_supports_id
          converter.instance_variable_get :@list_item_supports_id
        else
          output = (create_list doc, :ulist).tap {|ul| ul << (create_list_item ul).tap {|li| li.id = 'name' } }.convert
          converter.instance_variable_set :@list_item_supports_id, (output.include? ' id="name"')
        end
      end
    end
  end
end
