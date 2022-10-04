# frozen_string_literal: true

describe Asciidoctor::Tabs do
  before { described_class::Extensions.register }

  after { described_class::Extensions.unregister }

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
    (expect actual).not_to include 'tabset'
  end

  it 'should replace custom tabs block with tabset' do
    input = <<~'END'
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

    expected = <<~'END'.chomp
    <div id="_tabset1" class="tabset is-loading">
    <div class="ulist tabs">
    <ul>
    <li>
    <p><a id="_tabset1_tab_a"></a>Tab A</p>
    </li>
    <li>
    <p><a id="_tabset1_tab_b"></a>Tab B</p>
    </li>
    </ul>
    </div>
    <div class="content">
    <div class="tab-pane" aria-labelledby="_tabset1_tab_a">
    <div class="paragraph">
    <p>Contents of tab A.</p>
    </div>
    </div>
    <div class="tab-pane" aria-labelledby="_tabset1_tab_b">
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
    input = <<~'END'
    [tabs]
    ====
    Tab A::
    +
    Contents of tab A.
    ====
    END

    (expect (Asciidoctor.load input).extensions.docinfo_processors?).to be false
  end

  it 'should not register docinfo processors for non-HTML output' do
    input = <<~'END'
    [tabs]
    ====
    Tab A::
    +
    Contents of tab A.
    ====
    END

    (expect (Asciidoctor.load input, backend: 'docbook', standalone: true).extensions.docinfo_processors?).to be false
  end

  it 'should honor ID specified on block and use value as prefix for tabs' do
    input = <<~'END'
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

    actual = Asciidoctor.convert input
    (expect actual).to include 'id="install_commands'
    (expect actual).to include 'id="install_commands_npm"'
    (expect actual).to include 'aria-labelledby="install_commands_npm"'
    (expect actual).to include 'id="install_commands_yarn"'
    (expect actual).to include 'aria-labelledby="install_commands_yarn"'
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
    (expect actual).to include 'id="_tabset1_curl_command_output_v2"'
    (expect actual).to include 'aria-labelledby="_tabset1_curl_command_output_v2"'
  end

  it 'should generate IDs using idprefix and idseparator' do
    input = <<~'END'
    :idprefix:
    :idseparator: -

    [tabs]
    ====
    First Tab::
    +
    Contents of first tab.
    ====
    END

    actual = Asciidoctor.convert input
    (expect actual).to include 'id="tabset1'
    (expect actual).to include 'id="tabset1-first-tab"'
  end

  it 'should increment generate ID for each tabs block' do
    input = <<~'END'
    [tabs]
    ====
    Tab A::
    +
    Contents.
    ====

    and

    [tabs]
    ====
    Tab 1::
    +
    Contents.
    ====
    END

    actual = Asciidoctor.convert input
    (expect actual).to include 'id="_tabset1'
    (expect actual).to include 'id="_tabset1_tab_a"'
    (expect actual).to include 'id="_tabset2'
    (expect actual).to include 'id="_tabset2_tab_1"'
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
    <div id="_tabset1" class="tabset is-loading">
    <div class="ulist tabs">
    <ul>
    <li>
    <p><a id="_tabset1_tab_a"></a>Tab A</p>
    </li>
    <li>
    <p><a id="_tabset1_tab_b"></a>Tab B</p>
    </li>
    </ul>
    </div>
    <div class="content">
    <div class="tab-pane" aria-labelledby="_tabset1_tab_a">
    <div class="paragraph">
    <p>Contents of tab A.</p>
    </div>
    </div>
    <div class="tab-pane" aria-labelledby="_tabset1_tab_b">
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
    <div id="_tabset1" class="tabset is-loading">
    <div class="ulist tabs">
    <ul>
    <li>
    <p><a id="_tabset1_tab_a"></a>Tab A</p>
    </li>
    <li>
    <p><a id="_tabset1_tab_b"></a>Tab B</p>
    </li>
    <li>
    <p><a id="_tabset1_tab_c"></a>Tab C</p>
    </li>
    </ul>
    </div>
    <div class="content">
    <div class="tab-pane" aria-labelledby="_tabset1_tab_a _tabset1_tab_b">
    <div class="paragraph">
    <p>Shared contents for tab A and B.</p>
    </div>
    </div>
    <div class="tab-pane" aria-labelledby="_tabset1_tab_c">
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
    <div id="_tabset1" class="tabset is-loading">
    <div class="ulist tabs">
    <ul>
    <li>
    <p><a id="_tabset1_tab_a"></a>Tab A</p>
    </li>
    <li>
    <p><a id="_tabset1_tab_b"></a>Tab B</p>
    </li>
    </ul>
    </div>
    <div class="content">
    <div class="tab-pane" aria-labelledby="_tabset1_tab_a">
    <div class="paragraph">
    <p>Contents of tab A.</p>
    </div>
    </div>
    <div class="tab-pane" aria-labelledby="_tabset1_tab_b">
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
    <div id="_tabset1" class="tabset is-loading">
    <div class="ulist tabs">
    <ul>
    <li>
    <p><a id="_tabset1_tab_a"></a>Tab A</p>
    </li>
    </ul>
    </div>
    <div class="content">
    <div class="tab-pane" aria-labelledby="_tabset1_tab_a">
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

  it 'should include styles in head tag of standalone document' do
    input = <<~'END'
    [tabs]
    ====
    Tab A::
    +
    Contents of tab A.
    ====
    END

    doc = Asciidoctor.load input, standalone: true
    (expect doc.extensions.docinfo_processors?).to be true
    actual = doc.convert
    styles_idx = actual.index %r/<style>[^<]*\.tabset\.is-loading [^<]*<\/style>/
    end_head_idx = actual.index '</head>'
    (expect styles_idx).not_to be_nil
    (expect styles_idx).to be < end_head_idx
  end

  it 'should include behavior below footer of standalone document' do
    input = <<~'END'
    [tabs]
    ====
    Tab A::
    +
    Contents of tab A.
    ====
    END

    doc = Asciidoctor.load input, standalone: true
    (expect doc.extensions.docinfo_processors?).to be true
    actual = doc.convert
    behavior_idx = actual.index %r/<script>[^<]*\.tabset[^<]*<\/script>/
    footer_idx = actual.index '<div id="footer">'
    (expect behavior_idx).not_to be_nil
    (expect behavior_idx).to be > footer_idx
  end

  it 'should register extensions on specified global registry' do
    described_class::Extensions.unregister
    described_class::Extensions.register Asciidoctor::Extensions

    input = <<~'END'
    [tabs]
    ====
    Tab A::
    +
    Contents of tab A.
    ====
    END

    actual = Asciidoctor.convert input
    (expect actual).to include 'class="tabset'
  end

  it 'should register extensions on specified local registry' do
    described_class::Extensions.unregister
    described_class::Extensions.register (registry = Asciidoctor::Extensions.create)

    input = <<~'END'
    [tabs]
    ====
    Tab A::
    +
    Contents of tab A.
    ====
    END

    actual = Asciidoctor.convert input, extension_registry: registry
    (expect actual).to include 'class="tabset'
  end

  it 'should output original dlist if filetype is not html' do
    input = <<~'END'
    [tabs#not-tabs,reftext=Not Tabs]
    ====
    Tab A::
    +
    Contents of tab A.
    ====
    END

    expected = <<~'END'.chomp
    <variablelist xml:id="not-tabs" xreflabel="Not Tabs">
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
end
