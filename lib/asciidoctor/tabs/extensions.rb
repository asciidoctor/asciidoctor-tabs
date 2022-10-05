# frozen_string_literal: true

unless RUBY_ENGINE == 'opal'
  require_relative 'block'
  require_relative 'docinfo'
end

module Asciidoctor
  module Tabs
    module Extensions
      module_function

      def group
        proc do
          block Block, :tabs
          next if (doc = @document).embedded? || !(doc.attr? 'filetype', 'html')
          unless (doc.attribute_locked? 'tabs-stylesheet') ||
              ((doc.options[:attributes] || {}).transform_keys {|it| it.delete '@!' }.key? 'tabs-stylesheet')
            doc.set_attr 'tabs-stylesheet'
          end
          docinfo_processor Docinfo::Styles
          docinfo_processor Docinfo::Behavior
          nil
        end
      end

      def key
        :tabs
      end

      def register registry = nil
        (registry || ::Asciidoctor::Extensions).groups[key] ||= group
      end

      def unregister registry = nil
        (registry || ::Asciidoctor::Extensions).groups.delete key
        nil
      end
    end
  end
end
