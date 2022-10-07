# frozen_string_literal: true

module Asciidoctor
  module Tabs
    module Docinfo
      if RUBY_ENGINE == 'opal'
        DATA_DIR = ::File.absolute_path '../data', %x(__dirname)
      else
        DATA_DIR = ::File.join (::File.absolute_path '../../..', __dir__), 'data'
      end

      class Styles < ::Asciidoctor::Extensions::DocinfoProcessor
        use_dsl
        at_location :head

        DEFAULT_STYLESHEET_FILE = ::File.join DATA_DIR, 'css/tabs.css'

        def process doc
          return unless (path = doc.attr 'tabs-stylesheet')
          return unless (styles = path.empty? ?
            (doc.read_asset DEFAULT_STYLESHEET_FILE) :
            (doc.read_contents path, start: (doc.attr 'stylesdir'), warn_on_failure: true, label: 'tabs stylesheet'))
          %(<style>\n#{styles.chomp}\n</style>)
        end
      end

      class Behavior < ::Asciidoctor::Extensions::DocinfoProcessor
        use_dsl
        at_location :footer

        JAVASCRIPT_FILE = ::File.join DATA_DIR, 'js/tabs.js'

        def process doc
          return unless (script = doc.read_asset JAVASCRIPT_FILE)
          %(<script>\n#{script.chomp}\n</script>)
        end
      end
    end
  end
end
