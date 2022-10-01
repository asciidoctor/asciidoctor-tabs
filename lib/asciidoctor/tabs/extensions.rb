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
          docinfo_processor Docinfo::Styles
          docinfo_processor Docinfo::Behavior
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
      end
    end
  end
end
