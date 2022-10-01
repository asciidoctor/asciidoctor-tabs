# frozen_string_literal: true

module Asciidoctor
  module Tabs
    module Docinfo
      if RUBY_ENGINE == 'opal'
        DATA_DIR = ::File.absolute_path '../data', %x(__dirname)
        FILE_READ_MODE = 'r'
      else
        DATA_DIR = ::File.join (::File.absolute_path '../../..', __dir__), 'data'
        FILE_READ_MODE = 'rb:utf-8:utf-8'
      end

      class Styles < ::Asciidoctor::Extensions::DocinfoProcessor
        use_dsl
        at_location :head

        STYLESHEET_FILE = ::File.join DATA_DIR, 'css/tabs.css'

        def process _doc
          %(<style>\n#{(::File.read STYLESHEET_FILE, mode: FILE_READ_MODE).chomp}\n</style>)
        end
      end

      class Behavior < ::Asciidoctor::Extensions::DocinfoProcessor
        use_dsl
        at_location :footer

        JAVASCRIPT_FILE = ::File.join DATA_DIR, 'js/tabs.js'

        def process _doc
          %(<script>\n#{(::File.read JAVASCRIPT_FILE, mode: FILE_READ_MODE).chomp}\n</script>)
        end
      end
    end
  end
end
