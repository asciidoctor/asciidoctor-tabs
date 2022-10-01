begin
  require_relative 'lib/asciidoctor/tabs/version'
rescue LoadError
  require 'asciidoctor/tabs/version'
end

Gem::Specification.new do |s|
  s.name = 'asciidoctor-tabs'
  s.version = Asciidoctor::Tabs::VERSION
  s.summary = 'An Asciidoctor extension that adds a tabs block to the AsciiDoc syntax.'
  s.description = 'An Asciidoctor extension that adds a tabs block to the AsciiDoc syntax. The tabset is constructed from a dlist enclosed in an example block marked with the tabs style.'
  s.authors = ['Dan Allen']
  s.email = 'dan@opendevise.com'
  s.homepage = 'https://asciidoctor.org'
  s.license = 'MIT'
  # NOTE required ruby version is informational only; it's not enforced since it can't be overridden and can cause builds to break
  #s.required_ruby_version = '>= 2.7.0'
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/asciidoctor/asciidoctor-tabs/issues',
    'changelog_uri' => 'https://github.com/asciidoctor/asciidoctor-tabs/blob/main/CHANGELOG.adoc',
    'mailing_list_uri' => 'https://chat.asciidoctor.org',
    'source_code_uri' => 'https://github.com/asciidoctor/asciidoctor-tabs'
  }

  # NOTE the logic to build the list of files is designed to produce a usable package even when the git command is not available
  begin
    files = (result = `git ls-files -z`.split ?\0).empty? ? Dir['**/*'] : result
  rescue
    files = Dir['**/*']
  end
  s.files = files.grep %r/^(?:(?:data|lib)\/.+|LICENSE|(?:CHANGELOG|README)\.adoc|#{s.name}\.gemspec)$/
  s.executables = (files.grep %r/^bin\//).map {|f| File.basename f }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'asciidoctor', ['>= 2.0.0', '< 3.0.0']

  s.add_development_dependency 'rake', '~> 13.0.0'
  s.add_development_dependency 'rspec', '~> 3.11.0'
end
