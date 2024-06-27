#!/usr/bin/env -S crystal run

require "log"
require "dotenv"
require "option_parser"
require "merlin"

require "./version"

require "./util/macros"
require "./util/object_extensions"
require "./util/algo"
require "./util/ansi"

require "./misc/error"
require "./misc/visibility"
require "./misc/match_result"
require "./misc/typing"

require "./node/node"

require "./type_node/iface"
require "./type_node/psuedo"
require "./type_node/defaults"
require "./type_node/type_node"

require "./node_implements/members/member_objects_helper"
require "./node_implements/members/shared"

require "./node_implements/fn/supplementary"
require "./node_implements/fn/templates/**"
require "./node_implements/fn/fn"
require "./node_implements/fn/**"

require "./node_implements/psuedo/**"

require "./node_implements/primitives/**"

require "./node_implements/meta/desc/desc"
require "./node_implements/meta/meta"

require "./node_implements/cls/cls"
require "./node_implements/cls/cls_inst"

require "./node_implements/stmt/**"

require "./scope/scope"
require "./scope/**"

require "./lang/syntax_macros"
require "./lang/syntax/**"
require "./lang/interpreter"

module Magiika
  extend self

  alias Position = Merlin::Position

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
end
