# frozen_string_literal: true

describe Asciidoctor::Tabs do
  let :hello_tabs do
    <<~'END'
    [tabs]
    ====
    Hello, World!::
    +
    You're reading text inside a tab.
    ====
    END
  end

  let :single_tab do
    <<~'END'
    [tabs]
    ====
    Tab A::
    +
    Contents of tab A.
    ====
    END
  end

  let :two_tabs do
    <<~'END'
    [tabs]
    ====
    Tab A::
    +
    Contents of tab A.

    Tab B::
    +
    Contents of tab B.
    ====
    END
  end

  let :install_tabs do
    <<~'END'
    [tabs#install_commands]
    ====
    npm::
    +
     $ npm i name

    yarn::
    +
     $ yarn add name
    ====
    END
  end

  before { described_class::Extensions.register }

  after { described_class::Extensions.unregister }

  context 'require' do
    it 'should be able to require asciidoctor/tabs from Ruby process' do
      script_file = fixture_file 'require.rb'
      File.write script_file, <<~'END'
      require 'asciidoctor'
      require 'asciidoctor/tabs'
      puts Asciidoctor::Extensions.groups.keys[0].to_s
      END
      output = %x(#{ruby} #{Shellwords.escape script_file}).lines.map(&:chomp)
      (expect output).to eql ['tabs']
    ensure
      File.unlink script_file
    end

    it 'should be able to require asciidoctor-tabs from Ruby process' do
      script_file = fixture_file 'require.rb'
      File.write script_file, <<~'END'
      require 'asciidoctor'
      require 'asciidoctor-tabs'
      puts Asciidoctor::Extensions.groups.keys[0].to_s
      END
      output = %x(#{ruby} #{Shellwords.escape script_file}).lines.map(&:chomp)
      (expect output).to eql ['tabs']
    ensure
      File.unlink script_file
    end
  end

  context 'VERSION' do
    it 'should define VERSION constant that adheres to SemVer (with a RubyGems twist)' do
      (expect described_class::VERSION).to match %r/^\d+\.\d+\.\d+(\.[a-z]\S*)?$/
    end

    it 'should be able to require library from Ruby process to access version' do
      # NOTE asciidoctor/tabs/version will already be required by Bundler when test suite launches
      script_file = fixture_file 'print_version.rb'
      File.write script_file, <<~'END'
      require 'asciidoctor/tabs/version'
      puts Asciidoctor::Tabs::VERSION
      END
      output = %x(#{ruby} #{Shellwords.escape script_file}).lines.map(&:chomp)
      (expect output).to eql [described_class::VERSION]
    ensure
      File.unlink script_file
    end
  end

  context 'block' do
    it 'should leave example block unprocessed if empty' do
      input = <<~'END'
      [tabs]
      ====
      ====
      END

      expected = <<~'END'.chomp
      <div class="exampleblock">
      <div class="content">
      </div>
      </div>
      END

      actual = (Asciidoctor.convert input).tr_s ?\n, ?\n
      (expect actual).to eql expected
    end

    it 'should preserve ID on unprocessed example block' do
      input = <<~'END'
      [tabs#idname]
      ====
      ====
      END

      expected = <<~'END'.chomp
      <div id="idname" class="exampleblock">
      <div class="content">
      </div>
      </div>
      END

      actual = (Asciidoctor.convert input).tr_s ?\n, ?\n
      (expect actual).to eql expected
    end

    it 'should preserve role on unprocessed example block' do
      input = <<~'END'
      [tabs.rolename]
      ====
      ====
      END

      expected = <<~'END'.chomp
      <div class="exampleblock rolename">
      <div class="content">
      </div>
      </div>
      END

      actual = (Asciidoctor.convert input).tr_s ?\n, ?\n
      (expect actual).to eql expected
    end

    it 'should leave example block unprocessed if only child is not a dlist' do
      input = <<~'END'
      [tabs]
      ====
      Not a dlist.
      ====
      END

      expected = <<~'END'.chomp
      <div class="exampleblock">
      <div class="content">
      <div class="paragraph">
      <p>Not a dlist.</p>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it 'should leave example block unprocessed if contains more than one child' do
      input = <<~'END'
      [tabs]
      ====
      Tab A::
      +
      Contents of tab A.

      Not a dlist.
      ====
      END

      actual = Asciidoctor.convert input
      (expect actual).not_to include ' class="tabs"'
    end

    it 'should convert custom tabs block containing valid content' do
      input = two_tabs
      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      <li id="_tabs_1_tab_b" class="tab">
      <p>Tab B</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a">
      <div class="paragraph">
      <p>Contents of tab A.</p>
      </div>
      </div>
      <div id="_tabs_1_tab_b--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_b">
      <div class="paragraph">
      <p>Contents of tab B.</p>
      </div>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it 'should not register docinfo processors for embedded document' do
      input = hello_tabs
      (expect (Asciidoctor.load input).extensions.docinfo_processors?).to be false
    end

    it 'should not register docinfo processors for non-HTML output' do
      input = hello_tabs
      (expect (Asciidoctor.load input, backend: 'docbook', standalone: true).extensions.docinfo_processors?).to be false
    end

    it 'should preserve roles on tabs block' do
      input = <<~END
      [.role1.role2]
      #{single_tab}
      END

      actual = Asciidoctor.convert input
      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs role1 role2 is-loading">
      <div class="content">
      <div class="ulist tablist">
      END
      (expect actual).to include expected
    end

    it 'should honor title on tabs block' do
      input = <<~END
      .These are *tabs*!
      #{single_tab}
      END

      actual = Asciidoctor.convert input
      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="title">These are <strong>tabs</strong>!</div>
      <div class="content">
      <div class="ulist tablist">
      END
      (expect actual).to include expected
    end

    it 'should honor ID specified on block and use value as prefix for tabs' do
      input = install_tabs
      actual = Asciidoctor.convert input
      (expect actual).to include 'id="install_commands"'
      (expect actual).to include 'id="install_commands_npm"'
      (expect actual).to include 'aria-labelledby="install_commands_npm"'
      (expect actual).to include 'id="install_commands_yarn"'
      (expect actual).to include 'aria-labelledby="install_commands_yarn"'
    end

    it 'should continue tabs number sequence when generating ID for tabs following tabs with custom ID' do
      input = <<~END
      [tabs]
      ====
      Tab A:: A
      Tab B:: B
      Tab C:: C
      ====

      #{install_tabs}

      [tabs]
      ====
      Tab X:: X
      Tab Y:: Y
      Tab Z:: Z
      ====
      END

      actual = Asciidoctor.convert input
      (expect actual).to include 'id="_tabs_1"'
      (expect actual).to include 'id="install_commands"'
      (expect actual).to include 'id="_tabs_3"'
    end

    it 'should use tabs number sequence when generating ID when tabs-number attribute is locked' do
      input = <<~END
      [tabs]
      ====
      Tab A:: A
      Tab B:: B
      Tab C:: C
      ====

      [tabs]
      ====
      Tab X:: X
      Tab Y:: Y
      Tab Z:: Z
      ====
      END

      actual = Asciidoctor.convert input, attributes: { 'tabs-number' => 0 }
      (expect actual).to include 'id="_tabs_1"'
      (expect actual).to include 'id="_tabs_2"'
    end

    it 'should be able to switch tabs number sequence for generated IDs to letters using tabs-number attribute' do
      input = <<~END
      :tabs-number: @

      [tabs]
      ====
      Tab A:: A
      Tab B:: B
      Tab C:: C
      ====

      [tabs]
      ====
      Tab X:: X
      Tab Y:: Y
      Tab Z:: Z
      ====
      END

      actual = Asciidoctor.convert input
      (expect actual).to include 'id="_tabs_a"'
      (expect actual).to include 'id="_tabs_b"'
    end

    it 'should register reference for tabs if it defines an ID' do
      input = <<~'END'
      [tabs#parts]
      ====
      CPU:: The brains of your computer.
      Hard drive:: Where all your files are stored (that aren't in the cloud).
      ====

      See <<parts>>.
      END

      with_memory_logger :info do |logger|
        doc = Asciidoctor.load input
        actual = doc.convert
        (expect actual).to include 'id="parts"'
        (expect logger).to be_empty
        (expect doc.catalog[:refs]).to have_key 'parts'
      end
    end

    it 'should register reference for each tab' do
      input = <<~'END'
      [tabs]
      ====
      CPU:: The brains of your computer.
      Hard drive:: Where all your files are stored (that aren't in the cloud).
      ====

      See <<_tabs_1_hard_drive>>.
      END

      with_memory_logger :info do |logger|
        doc = Asciidoctor.load input
        actual = doc.convert
        (expect actual).to include 'id="_tabs_1_hard_drive"'
        (expect logger).to be_empty
        (expect doc.catalog[:refs]).to have_key '_tabs_1_hard_drive'
        (expect doc.catalog[:refs]['_tabs_1_hard_drive'].xreftext).to eql 'Hard drive'
      end
    end

    it 'should clean invalid ID chars and condense repeating separator chars' do
      input = <<~'END'
      [tabs]
      ====
      cURL command & `output` (/v2)::
      +
      curl command shown here.
      ====
      END

      actual = Asciidoctor.convert input
      (expect actual).to include 'id="_tabs_1_curl_command_output_v2"'
      (expect actual).to include 'aria-labelledby="_tabs_1_curl_command_output_v2"'
    end

    it 'should generate IDs using idprefix and idseparator' do
      input = <<~END
      :idprefix:
      :idseparator: -

      #{single_tab}
      END

      actual = Asciidoctor.convert input
      (expect actual).to include 'id="tabs-1"'
      (expect actual).to include 'id="tabs-1-tab-a"'
    end

    it 'should increment generated ID for each tabs block' do
      input = <<~END
      #{single_tab}

      and

      #{two_tabs}
      END

      actual = Asciidoctor.convert input
      (expect actual).to include 'id="_tabs_1"'
      (expect actual).to include 'id="_tabs_1_tab_a"'
      (expect actual).to include 'id="_tabs_2"'
      (expect actual).to include 'id="_tabs_2_tab_a"'
      (expect actual).to include 'id="_tabs_2_tab_b"'
    end

    it 'should use anchor for tab ID if converter does not support id property on list item' do
      backend = nil
      create_class (Asciidoctor::Converter.for 'html5') do
        register_for (backend = %(#{object_id}html5).to_sym)
        def convert_ulist node
          super.gsub %r/<li id="[^"]+"/, '<li'
        end
      end
      input = <<~END
      #{two_tabs}

      #{single_tab}
      END
      expected = <<~'END'
      <div class="ulist tablist">
      <ul>
      <li class="tab">
      <p><a id="_tabs_1_tab_a"></a>Tab A</p>
      </li>
      <li class="tab">
      <p><a id="_tabs_1_tab_b"></a>Tab B</p>
      </li>
      </ul>
      </div>
      END
      actual = Asciidoctor.convert input, backend: backend
      (expect actual).to include expected
    end

    it 'should use text of tab item if it has no blocks' do
      input = <<~'END'
      [tabs]
      ====
      Tab A:: Contents of tab A.
      Tab B:: Contents of tab B.
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      <li id="_tabs_1_tab_b" class="tab">
      <p>Tab B</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a">
      <div class="paragraph">
      <p>Contents of tab A.</p>
      </div>
      </div>
      <div id="_tabs_1_tab_b--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_b">
      <div class="paragraph">
      <p>Contents of tab B.</p>
      </div>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it 'should preserve text if tab item has both text and blocks' do
      input = <<~'END'
      [tabs]
      ====
      Tab A:: Text
      +
      First block.
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a">
      <div class="paragraph">
      <p>Text</p>
      </div>
      <div class="paragraph">
      <p>First block.</p>
      </div>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it 'should apply normal substitutions to principal text of tab item' do
      input = <<~'END'
      :url-download: https://example.org
      :hide-uri-scheme:

      [tabs]
      ====
      Download:: Download the *installer* from {url-download}.

      Install::
      Run the *installer* you downloaded from {url-download}.
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_download" class="tab">
      <p>Download</p>
      </li>
      <li id="_tabs_1_install" class="tab">
      <p>Install</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_download--panel" class="tabpanel" aria-labelledby="_tabs_1_download">
      <div class="paragraph">
      <p>Download the <strong>installer</strong> from <a href="https://example.org" class="bare">example.org</a>.</p>
      </div>
      </div>
      <div id="_tabs_1_install--panel" class="tabpanel" aria-labelledby="_tabs_1_install">
      <div class="paragraph">
      <p>Run the <strong>installer</strong> you downloaded from <a href="https://example.org" class="bare">example.org</a>.</p>
      </div>
      </div>
      </div>
      </div>
      END

      doc = Asciidoctor.load input
      (doc.find_by context: :paragraph).each do |para|
        (expect para.subs).to eql (para.resolve_subs 'normal')
      end
      actual = doc.convert
      (expect actual).to eql expected
    end

    it 'should support multiple tabs for same content pane' do
      input = <<~'END'
      [tabs]
      ====
      Tab A::
      Tab B::
      Shared contents for tab A and B.

      Tab C:: Contents only for tab C.
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      <li id="_tabs_1_tab_b" class="tab">
      <p>Tab B</p>
      </li>
      <li id="_tabs_1_tab_c" class="tab">
      <p>Tab C</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a _tabs_1_tab_b">
      <div class="paragraph">
      <p>Shared contents for tab A and B.</p>
      </div>
      </div>
      <div id="_tabs_1_tab_c--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_c">
      <div class="paragraph">
      <p>Contents only for tab C.</p>
      </div>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it 'should create empty pane if tab has no description' do
      input = <<~'END'
      [tabs]
      ====
      Tab A:: Contents of tab A.
      Tab B::
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      <li id="_tabs_1_tab_b" class="tab">
      <p>Tab B</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a">
      <div class="paragraph">
      <p>Contents of tab A.</p>
      </div>
      </div>
      <div id="_tabs_1_tab_b--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_b">
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it 'should unwrap open block if only child of tab item' do
      input = <<~'END'
      [tabs]
      ====
      Tab A::
      +
      --
      Contents of tab A.

      Contains more than one block.
      --
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a">
      <div class="paragraph">
      <p>Contents of tab A.</p>
      </div>
      <div class="paragraph">
      <p>Contains more than one block.</p>
      </div>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it 'should not unwrap open block if it has a role' do
      input = <<~'END'
      [tabs]
      ====
      Tab A::
      +
      [.keep-me]
      --
      Contents of tab A.

      Contains more than one block.
      --
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a">
      <div class="openblock keep-me">
      <div class="content">
      <div class="paragraph">
      <p>Contents of tab A.</p>
      </div>
      <div class="paragraph">
      <p>Contains more than one block.</p>
      </div>
      </div>
      </div>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it '.only should not unwrap open block if it has an ID' do
      input = <<~'END'
      [tabs]
      ====
      Tab A::
      +
      [#contents-of-tab-a]
      --
      Contents of tab A.

      Contains more than one block.
      --
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a">
      <div id="contents-of-tab-a" class="openblock">
      <div class="content">
      <div class="paragraph">
      <p>Contents of tab A.</p>
      </div>
      <div class="paragraph">
      <p>Contains more than one block.</p>
      </div>
      </div>
      </div>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it 'should process nested tabs block' do
      input = <<~'END'
      [tabs]
      ====
      Tab A::
      +
      [tabs]
      ======
      Nested Tab A::
      Contents of nested tab A.
      ======
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a">
      <div id="_tabs_2" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_2_nested_tab_a" class="tab">
      <p>Nested Tab A</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_2_nested_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_2_nested_tab_a">
      <div class="paragraph">
      <p>Contents of nested tab A.</p>
      </div>
      </div>
      </div>
      </div>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input
      (expect actual).to eql expected
    end

    it 'should support using an include to populate the tab content' do
      input = <<~'END'
      [tabs]
      ====
      Tab A::
      +
      --
      include::include.adoc[]
      --
      ====
      END

      expected = <<~'END'.chomp
      <div id="_tabs_1" class="openblock tabs is-loading">
      <div class="content">
      <div class="ulist tablist">
      <ul>
      <li id="_tabs_1_tab_a" class="tab">
      <p>Tab A</p>
      </li>
      </ul>
      </div>
      <div id="_tabs_1_tab_a--panel" class="tabpanel" aria-labelledby="_tabs_1_tab_a">
      <div class="literalblock">
      <div class="content">
      <pre>$ command</pre>
      </div>
      </div>
      <div class="ulist">
      <ul>
      <li>
      <p>list</p>
      </li>
      </ul>
      </div>
      <div class="paragraph">
      <p>paragraph</p>
      </div>
      </div>
      </div>
      </div>
      END

      actual = Asciidoctor.convert input, safe: :safe, base_dir: fixtures_dir
      (expect actual).to eql expected
    end

    it 'should output original dlist in open block if filetype is not html' do
      input = <<~END
      [#not-tabs,reftext=Not Tabs]
      #{single_tab}
      END
      expected = <<~'END'.chomp
      <para xml:id="not-tabs" xreflabel="Not Tabs">
      <variablelist>
      <varlistentry>
      <term>Tab A</term>
      <listitem>
      <simpara>Contents of tab A.</simpara>
      </listitem>
      </varlistentry>
      </variablelist>
      </para>
      END

      actual = Asciidoctor.convert input, backend: 'docbook'
      (expect actual).to eql expected
    end

    it 'should preserve ID and reftext on dlist when filetype is not html' do
      input = <<~'END'
      [tabs#not-tabs,reftext=Not Tabs]
      ====
      [[varlist-1,A Variable List]]
      Tab A:: Contents of tab A.
      ====
      END
      expected = <<~'END'.chomp
      <para xml:id="not-tabs" xreflabel="Not Tabs">
      <variablelist xml:id="varlist-1" xreflabel="A Variable List">
      <varlistentry>
      <term>Tab A</term>
      <listitem>
      <simpara>Contents of tab A.</simpara>
      </listitem>
      </varlistentry>
      </variablelist>
      </para>
      END

      actual = Asciidoctor.convert input, backend: 'docbook'
      (expect actual).to eql expected
    end

    it 'should discard tabs enclosure if backend is docbook and tabs block has no attributes' do
      input = <<~'END'
      [tabs]
      ====
      Tab A:: Contents of tab A.
      ====
      END
      expected = <<~'END'.chomp
      <variablelist>
      <varlistentry>
      <term>Tab A</term>
      <listitem>
      <simpara>Contents of tab A.</simpara>
      </listitem>
      </varlistentry>
      </variablelist>
      END

      actual = Asciidoctor.convert input, backend: 'docbook'
      (expect actual).to eql expected
    end

    it 'should preserve attribute entries in body when filetype is not html' do
      input = <<~'END'
      before

      :foo: bar

      [tabs]
      ====
      foo:: {foo}
      ====
      END
      expected = <<~'END'.chomp
      <simpara>before</simpara>
      <variablelist>
      <varlistentry>
      <term>foo</term>
      <listitem>
      <simpara>bar</simpara>
      </listitem>
      </varlistentry>
      </variablelist>
      END

      with_memory_logger :info do |logger|
        doc = Asciidoctor.load input, backend: 'docbook'
        actual = doc.convert
        (expect actual).to eql expected
        (expect logger).to be_empty
      end
    end

    it 'should add is-sync class to tabs block if tabs-sync-option is set on document' do
      input = <<~END
      :tabs-sync-option:

      #{two_tabs}
      END

      actual = Asciidoctor.convert input
      (expect actual).to include ' class="openblock tabs is-sync is-loading"'
    end

    it 'should add is-sync class to tabs block if sync option is set on block' do
      input = <<~END
      [%sync]
      #{two_tabs}
      END

      actual = Asciidoctor.convert input
      (expect actual).to include ' class="openblock tabs is-sync is-loading"'
    end

    it 'should not add is-sync class to tabs block if nosync option is set on block' do
      input = <<~END
      :tabs-sync-option:

      [%nosync]
      #{two_tabs}
      END

      actual = Asciidoctor.convert input
      (expect actual).not_to include ' class="openblock tabs is-sync is-loading"'
      (expect actual).to include ' class="openblock tabs is-loading"'
    end

    it 'should add data-sync-group-id class to tabs block with sync option if sync-group-id attribute is set' do
      input = <<~END
      :tabs-sync-option:

      [sync-group-id="Tab A|Tab B"]
      #{two_tabs}
      END

      actual = Asciidoctor.convert input
      (expect actual).to include %( class="openblock tabs is-sync data-sync-group-id=Tab\u00a0A|Tab\u00a0B is-loading")
    end

    it 'should not add data-sync-group-id class to tabs block without sync option if sync-group-id attribute is set' do
      input = <<~END
      [sync-group-id=dual]
      #{two_tabs}
      END

      actual = Asciidoctor.convert input
      (expect actual).to include ' class="openblock tabs is-loading"'
    end
  end

  context 'docinfo style' do
    it 'should embed styles in head tag of standalone document if tabs-stylesheet attribute is empty' do
      input = hello_tabs
      [{}, { 'tabs-stylesheet' => '' }, nil].each do |attributes|
        if attributes.nil?
          doc = Asciidoctor::Document.new input, safe: :safe, standalone: true
        else
          doc = Asciidoctor.load input, attributes: attributes, safe: :safe, standalone: true
        end
        (expect doc.attr? 'tabs-stylesheet').to be true
        (expect doc.extensions.docinfo_processors?).to be true
        actual = doc.convert
        styles_idx = actual.index %r/<style>[^<]*\.tabs\.is-loading [^<]*<\/style>/
        end_head_idx = actual.index '</head>'
        (expect styles_idx).not_to be_nil
        (expect styles_idx).to be < end_head_idx
      end
    end

    it 'should link to stylesheet in standalone document if linkcss attribute is set' do
      input = hello_tabs
      [{ safe: :secure }, { attributes: 'linkcss', safe: :safe }].each do |opts|
        doc = Asciidoctor.load input, (opts.merge standalone: true)
        (expect doc.attr? 'tabs-stylesheet').to be true
        (expect doc.extensions.docinfo_processors?).to be true
        actual = doc.convert
        styles_idx = actual.index %r/<style>[^<]*\.tabs\.is-loading [^<]*<\/style>/
        link_idx = actual.index '<link rel="stylesheet" href="./asciidoctor-tabs.css">'
        end_head_idx = actual.index '</head>'
        (expect styles_idx).to be_nil
        (expect link_idx).not_to be_nil
        (expect link_idx).to be < end_head_idx
      end
    end

    it 'should honor htmlsyntax when creating link for stylesheet' do
      input = hello_tabs
      actual = Asciidoctor.convert input, backend: :xhtml5, safe: :secure, standalone: true
      (expect actual).to include '<link rel="stylesheet" href="./asciidoctor-tabs.css"/>'
    end

    it 'should prepend value of stylesdir attribute to stylesheet href' do
      input = hello_tabs
      ['', '.', 'css', './css', 'https://cdn.example.org'].each do |stylesdir|
        actual = Asciidoctor.convert input, safe: :secure, attributes: { 'stylesdir' => stylesdir }, standalone: true
        if stylesdir.empty?
          (expect actual).to include '<link rel="stylesheet" href="asciidoctor-tabs.css">'
        else
          (expect actual).to include %(<link rel="stylesheet" href="#{stylesdir}/asciidoctor-tabs.css">)
        end
      end
    end

    it 'should not prepend value of stylesdir attribute to stylesheet href if stylesdir is unset' do
      input = <<~END
      :!stylesdir:

      #{hello_tabs}
      END

      actual = Asciidoctor.convert input, safe: :secure, standalone: true
      (expect actual).to include '<link rel="stylesheet" href="asciidoctor-tabs.css">'
    end

    it 'should not embed styles in head tag of standalone document if tabs-stylesheet is unset' do
      input = hello_tabs
      doc = Asciidoctor.load input, attributes: { 'tabs-stylesheet' => nil }, safe: :safe, standalone: true
      (expect doc.attr? 'tabs-stylesheet').to be false
      actual = doc.convert
      styles_idx = actual.index %r/<style>[^<]*\.tabs\.is-loading [^<]*<\/style>/
      (expect styles_idx).to be_nil
    end

    it 'should not embed or link styles in standalone document if tabs-stylesheet is unset and safe mode is secure' do
      input = hello_tabs
      actual = Asciidoctor.convert input, attributes: { 'tabs-stylesheet' => nil }, safe: :secure, standalone: true
      styles_idx = actual.index %r/<style>[^<]*\.tabs\.is-loading [^<]*<\/style>/
      link_idx = actual.index %r/<link rel="stylesheet" href="[^"]+tabs\.css">/
      (expect styles_idx).to be_nil
      (expect link_idx).to be_nil
    end

    it 'should embed custom styles if tabs-stylesheet is set to absolute path' do
      input = hello_tabs
      expected = <<~'END'.chomp
      .tabs > ul li.is-active {
        border-color: orange;
      }
      END

      attributes = { 'tabs-stylesheet' => (fixture_file 'custom-tabs.css') }
      actual = Asciidoctor.convert input, attributes: attributes, safe: :safe, standalone: true
      (expect actual).to include expected
    end

    it 'should not embed custom styles if tabs-stylesheet is set to absolute path that does not exist' do
      input = hello_tabs
      attributes = { 'tabs-stylesheet' => (fixture_file 'no-such-file.css') }
      with_memory_logger do |logger|
        actual = Asciidoctor.convert input, attributes: attributes, safe: :safe, standalone: true
        (expect (actual.scan '<style>')).to eql ['<style>']
        (expect logger.messages.size).to eql 1
        message = logger.messages[0]
        (expect message[:severity]).to eql :WARN
        (expect message[:message]).to include 'tabs stylesheet does not exist or cannot be read'
      end
    end

    it 'should embed custom styles if tabs-stylesheet is set to path relative to stylesdir' do
      input = hello_tabs
      expected = <<~'END'.chomp
      .tabs > ul li.is-active {
        border-color: orange;
      }
      END

      attributes = {
        'stylesdir' => fixtures_dir,
        'tabs-stylesheet' => 'custom-tabs.css',
      }
      actual = Asciidoctor.convert input, attributes: attributes, safe: :safe, standalone: true
      (expect actual).to include expected
    end

    it 'should link to stylesheet path specified by tabs-stylesheet in standalone document when linkcss is set' do
      input = <<~END
      :tabs-stylesheet: tabs.css

      #{hello_tabs}
      END

      doc = Asciidoctor.load input, safe: :secure, standalone: true
      (expect doc.attr 'tabs-stylesheet').to eql 'tabs.css'
      (expect doc.extensions.docinfo_processors?).to be true
      actual = doc.convert
      (expect actual).to include '<link rel="stylesheet" href="./tabs.css">'
    end

    it 'should link to stylesheet URL specified by tabs-stylesheet in standalone document when linkcss is set' do
      input = <<~END
      :tabs-stylesheet: https://cdn.example.org/asciidoctor-tabs.css

      #{hello_tabs}
      END

      actual = Asciidoctor.convert input, safe: :secure, standalone: true
      (expect actual).to include '<link rel="stylesheet" href="https://cdn.example.org/asciidoctor-tabs.css">'
    end
  end

  context 'docinfo behavior' do
    it 'should embed script below footer of standalone document' do
      input = hello_tabs
      doc = Asciidoctor.load input, safe: :safe, standalone: true
      (expect doc.extensions.docinfo_processors?).to be true
      actual = doc.convert
      script_idx = actual.index %r/<script>[^<]*\.tabs[^<]*<\/script>/
      footer_idx = actual.index '<div id="footer">'
      (expect script_idx).not_to be_nil
      (expect script_idx).to be > footer_idx
    end

    it 'should allow sync-storage-key config option to be set using tabs-sync-storage-key document attribute' do
      input = hello_tabs
      attributes = { 'tabs-sync-storage-key' => 'preferred-tab' }
      doc = Asciidoctor.load input, safe: :safe, standalone: true, attributes: attributes
      actual = doc.convert
      (expect actual).to include '<script data-sync-storage-key="preferred-tab">'
    end

    it 'should allow sync-storage-scope config option to be set using tabs-sync-storage-key document attribute' do
      input = hello_tabs
      attributes = { 'tabs-sync-storage-key' => 'preferred-tab', 'tabs-sync-storage-scope' => 'session' }
      doc = Asciidoctor.load input, safe: :safe, standalone: true, attributes: attributes
      actual = doc.convert
      (expect actual).to include '<script data-sync-storage-key="preferred-tab" data-sync-storage-scope="session">'
    end

    it 'should link to script in standalone document if linkcss attribute is set' do
      input = hello_tabs
      [{ safe: :secure }, { attributes: 'linkcss', safe: :safe }].each do |opts|
        doc = Asciidoctor.load input, (opts.merge standalone: true)
        (expect doc.extensions.docinfo_processors?).to be true
        actual = doc.convert
        script_idx = actual.index '<script src="asciidoctor-tabs.js"></script>'
        footer_idx = actual.index '<div id="footer">'
        (expect script_idx).not_to be_nil
        (expect script_idx).to be > footer_idx
      end
    end

    it 'should prepend value of scriptsdir attribute to script src' do
      input = hello_tabs
      ['', '.', 'js', './js', 'https://cdn.example.org'].each do |scriptsdir|
        actual = Asciidoctor.convert input, safe: :secure, attributes: { 'scriptsdir' => scriptsdir }, standalone: true
        if scriptsdir.empty?
          (expect actual).to include '<script src="asciidoctor-tabs.js"></script>'
        else
          (expect actual).to include %(<script src="#{scriptsdir}/asciidoctor-tabs.js"></script>)
        end
      end
    end
  end

  context 'extensions' do
    it 'should register extensions on specified global registry' do
      described_class::Extensions.unregister
      described_class::Extensions.register Asciidoctor::Extensions
      input = hello_tabs
      actual = Asciidoctor.convert input
      (expect actual).to include ' class="openblock tabs is-loading"'
    end

    it 'should register extensions on specified local registry' do
      described_class::Extensions.unregister
      described_class::Extensions.register (registry = Asciidoctor::Extensions.create)
      input = hello_tabs
      actual = Asciidoctor.convert input, extension_registry: registry
      (expect actual).to include ' class="openblock tabs is-loading"'
    end

    it 'should unregister extensions on specified registry' do
      described_class::Extensions.register (registry = Asciidoctor::Extensions.create)
      (expect registry.groups.keys.map(&:to_s)).to eql ['tabs']
      described_class::Extensions.unregister registry
      (expect registry.groups.keys).to be_empty
    end
  end
end
