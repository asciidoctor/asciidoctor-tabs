# frozen_string_literal: true

require 'asciidoctor'
require 'asciidoctor/tabs/extensions'

RSpec.configure do
  def fixtures_dir
    File.join __dir__, 'fixtures'
  end

  def fixture_file path
    File.join fixtures_dir, path
  end
end
