#!/usr/bin/env -S crystal run
require "log"
require "dotenv"
require "option_parser"
require "./magiika/magiika"
require "./magiika/lang/lang"


module Magiika
  VERSION = "0.1.0"

  extend self


  # ⭐ Environment variables
  # --------------------------------------------------------

  Dotenv.load

  # Number of entries in an inheritance chain to traverse
  # before raising an error. This prevents an infinite loop.
  INHERITANCE_LIMIT = ENV.fetch("INHERITANCE_LIMIT", "128").to_i
  # Initial log level to apply
  INITIAL_LOG_LEVEL = ENV.fetch("INITIAL_LOG_LEVEL", "INFO")


  # 💫 Logging setup
  # --------------------------------------------------------

  private def s_to_log_level(level : String) : ::Log::Severity
    case level.upcase
    when "TRACE"
      ::Log::Severity::Trace
    when "DEBUG"
      ::Log::Severity::Debug
    when "INFO"
      ::Log::Severity::Info
    when "NOTICE"
      ::Log::Severity::Notice
    when "WARN"
      ::Log::Severity::Warn
    when "ERROR"
      ::Log::Severity::Error
    when "FATAL"
      ::Log::Severity::Fatal
    when "NONE"
      ::Log::Severity::None
    else
      raise Error::Internal.new("Unknown log level \"#{level}\".")
    end
  end

  #Log = ::Log.for("root")
  class_getter :log_level
  @@log_level : ::Log::Severity = s_to_log_level(INITIAL_LOG_LEVEL)

  LOG_BACKEND = ::Log::IOBackend.new
  LOG_BACKEND.dispatcher = ::Log::DirectDispatcher
  LOG_BACKEND.formatter = ::Log::Formatter.new do |entry, io|
    io << entry.severity.label << " - " \
      << entry.source << ": " \
      << entry.message
  end

  ::Log.builder.bind("*", @@log_level, LOG_BACKEND)

  def change_log_level(level : ::Log::Severity)
    ::Log.builder.unbind("*", @@log_level, LOG_BACKEND)
    @@log_level = level
    ::Log.builder.bind("*", @@log_level, LOG_BACKEND)
  end


  # ⚡ API
  # --------------------------------------------------------

  def main
    file : String? = ARGV[0]?
    if !file.nil? && !file.starts_with?('-')
      ARGV.delete_at(0)
    end

    parser = OptionParser.new do |parser|
      parser.banner = "✨ Usage: magiika [FILE] [options]"
      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit
      end
      parser.missing_option do |option_flag|
        STDERR.puts "💫 Error: #{option_flag} is missing something."
        STDERR.puts parser
        exit(1)
      end
      parser.invalid_option do |option_flag|
        STDERR.puts "💫 Error: #{option_flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end
    parser.parse

    interpreter = Lang::MagiikaInterpreter.new
    if file.nil?
      interpreter.run_interactive
    else
      interpreter.run_file(file)
    end
  end
end
