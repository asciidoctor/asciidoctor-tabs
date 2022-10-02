# frozen_string_literal: true

require_relative 'block'
require_relative 'docinfo'

module Asciidoctor
  module Tabs
    module Extensions
      module_function

      def group
        proc do
          block Block, :tabs
          next if @document.embedded?
          docinfo_processor Docinfo::Styles
          docinfo_processor Docinfo::Behavior
          nil
        end
      end

      def key
        :tabs
      end

      def register
        ::Asciidoctor::Extensions.register key, &group
      end

      def unregister
        ::Asciidoctor::Extensions.groups.delete key
        nil
      end
    end
  end
end
