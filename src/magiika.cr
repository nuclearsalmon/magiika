#!/usr/bin/env -S crystal run
require "log"
require "./magiika/error.cr"
require "./magiika/lang/MODULE.cr"


module Magiika
  VERSION = "0.1.0"

  extend self


  # LOGGING SETUP
  # --------------------------------------------------------

  Log = ::Log.for("root")

  @@log_level = ::Log::Severity::Info

  def log_level
    @@log_level
  end

  def change_log_level(level : ::Log::Severity)
    ::Log.builder.unbind("*", @@log_level, LOG_BACKEND)
    @@log_level = level
    ::Log.builder.bind("*", @@log_level, LOG_BACKEND)
  end

  def toggle_log_level
    debug = ::Log::Severity::Debug
    info = ::Log::Severity::Info
    is_debug = @@log_level == debug
    change_log_level(is_debug ? info : debug)
  end

  LOG_BACKEND = ::Log::IOBackend.new
  LOG_BACKEND.dispatcher = ::Log::DirectDispatcher
  LOG_BACKEND.formatter = ::Log::Formatter.new do |entry, io|
    io << entry.severity.label << " - " \
      << entry.source << ": " \
      << entry.message
  end

  ::Log.builder.bind("*", @@log_level, LOG_BACKEND)
  
  

  # API AND RUNTIME
  # --------------------------------------------------------

  def interpreter
    Lang::MagiikaInterpreter.new
  end

  def run
    interpreter.interactive
  end

  def main
    if ARGV.size == 0
      Magiika.run
    else
      raise NotImplementedError.new("")
    end
  end

  # call main
  main()
end
