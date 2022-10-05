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

        DEFAULT_STYLESHEET_FILE = ::File.join DATA_DIR, 'css/tabs.css'

        def process doc
          return unless (path = doc.attr 'tabs-stylesheet')
          styles = path.empty? ?
            (::File.read DEFAULT_STYLESHEET_FILE, mode: FILE_READ_MODE) :
            (doc.read_contents path, start: (doc.attr 'stylesdir'), warn_on_failure: true, label: 'tabs stylesheet')
          return unless styles
          %(<style>\n#{styles.chomp}\n</style>)
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
