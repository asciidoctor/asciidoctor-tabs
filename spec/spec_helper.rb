# frozen_string_literal: true

case ENV['COVERAGE']
when 'deep'
  ENV['DEEP_COVER'] = 'true'
  require 'deep_cover'
when 'true'
  require 'deep_cover/builtin_takeover'
  require 'simplecov'
end

require 'asciidoctor'
require 'asciidoctor/tabs/extensions'

RSpec.configure do
  def fixtures_dir
    File.join __dir__, 'fixtures'
  end

  def fixture_file path
    File.join fixtures_dir, path
  end

  def with_memory_logger level = nil
    old_logger, logger = Asciidoctor::LoggerManager.logger, Asciidoctor::MemoryLogger.new
    logger.level = level if level
    Asciidoctor::LoggerManager.logger = logger
    yield logger
  ensure
    Asciidoctor::LoggerManager.logger = old_logger
  end
end
