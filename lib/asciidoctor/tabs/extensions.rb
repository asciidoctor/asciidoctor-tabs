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
          next if @document.embedded? || !(@document.attr? 'filetype', 'html')
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
