# frozen_string_literal: true

module Asciidoctor
  module Tabs
    module Docinfo
      if RUBY_ENGINE == 'opal'
        DATA_DIR = ::File.absolute_path '../dist', %x(__dirname)
      else
        DATA_DIR = ::File.join (::File.absolute_path '../../..', __dir__), 'data'
      end

      module_function

      # Returns the web path directory used for the tabs script. If a scriptsdir
      # is not configured explicitly, derive it from stylesdir by replacing the
      # final path segment with scripts.
      def script_dir doc
        scriptsdir = doc.attr 'scriptsdir'
        return scriptsdir unless scriptsdir.to_s.empty?
        stylesdir = doc.attr 'stylesdir'
        return 'scripts' if stylesdir.to_s.empty?
        %(#{::File.dirname stylesdir}/scripts)
      end

      # Writes the packaged asset to its linked location when linkcss is set.
      # The destination is resolved relative to the document output directory.
      def write_asset doc, web_path, asset_file, label
        return if %r{\A[a-z][a-z0-9+.-]*://}i.match? web_path
        outdir = doc.attr('outdir') || doc.options[:to_dir]
        return unless outdir
        asset = doc.read_asset asset_file
        return unless asset
        dest = doc.normalize_system_path web_path, outdir, nil, target_name: label
        ::Asciidoctor::Helpers.mkdir_p ::File.dirname dest
        ::File.write dest, asset
        nil
      end

      class Style < ::Asciidoctor::Extensions::DocinfoProcessor
        use_dsl
        at_location :head

        DEFAULT_STYLESHEET_FILE = ::File.join DATA_DIR, 'css/tabs.css'

        def process doc
          return unless (path = doc.attr 'tabs-stylesheet')
          if doc.attr? 'linkcss'
            href = doc.normalize_web_path (path.empty? ? 'asciidoctor-tabs.css' : path), (doc.attr 'stylesdir')
            Docinfo.write_asset doc, href, DEFAULT_STYLESHEET_FILE, 'tabs stylesheet'
            %(<link rel="stylesheet" href="#{href}"#{(doc.attr? 'htmlsyntax', 'xml') ? '/' : ''}>) # rubocop:disable Style/TernaryParentheses
          elsif (styles = path.empty? ?
              (doc.read_asset DEFAULT_STYLESHEET_FILE) :
              (doc.read_contents path, start: (doc.attr 'stylesdir'), warn_on_failure: true, label: 'tabs stylesheet'))
            %(<style>\n#{styles.chomp}\n</style>)
          end
        end
      end

      class Behavior < ::Asciidoctor::Extensions::DocinfoProcessor
        use_dsl
        at_location :footer

        JAVASCRIPT_FILE = ::File.join DATA_DIR, 'js/tabs.js'

        def process doc
          if doc.attr? 'tabs-sync-storage-key'
            config_attrs = %( data-sync-storage-key="#{doc.attr 'tabs-sync-storage-key'}")
            if doc.attr? 'tabs-sync-storage-scope'
              config_attrs += %( data-sync-storage-scope="#{doc.attr 'tabs-sync-storage-scope'}")
            end
          else
            config_attrs = ''
          end
          if doc.attr? 'linkcss'
            src = doc.normalize_web_path 'asciidoctor-tabs.js', Docinfo.script_dir(doc)
            Docinfo.write_asset doc, src, JAVASCRIPT_FILE, 'tabs script'
            %(<script src="#{src}"#{config_attrs}></script>)
          elsif (script = doc.read_asset JAVASCRIPT_FILE)
            %(<script#{config_attrs}>\n#{script.chomp}\n</script>)
          end
        end
      end
    end
  end
end
