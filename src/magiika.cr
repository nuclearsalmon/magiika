#!/usr/bin/env -S crystal run
require "log"
require "./magiika/error.cr"
require "./magiika/lang/MODULE.cr"


module Magiika
  VERSION = "0.1.0"
  LOG_LEVEL = ::Log::Severity::Debug

  extend self


  # LOGGING SETUP
  # --------------------------------------------------------

  Log = ::Log.for("root")

  backend = ::Log::IOBackend.new
  backend.dispatcher = ::Log::DirectDispatcher
  backend.formatter = ::Log::Formatter.new do |entry, io|
    io << entry.severity.label << " - " \
      << entry.source << ": " \
      << entry.message
  end
  ::Log.builder.bind("*", LOG_LEVEL, backend)


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
