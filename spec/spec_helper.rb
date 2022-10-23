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
require 'shellwords'

RSpec.configure do
  def create_class super_class = Object, &block
    klass = Class.new super_class, &block
    Object.const_set %(AnonymousClass#{klass.object_id}).to_sym, klass
    klass
  end

  def fixtures_dir
    File.join __dir__, 'fixtures'
  end

  def fixture_file path
    File.join fixtures_dir, path
  end

  def ruby
    cmd = Shellwords.escape File.join RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name']
    (defined? DeepCover) && !(DeepCover.const_defined? :TAKEOVER_IS_ON) ? %(#{cmd} -rdeep_cover) : cmd
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
