#!/usr/bin/env -S crystal run
require "./magiika/error.cr"
require "./magiika/lang/__init__.cr"
require "./magiika/node/__init__.cr"
require "./magiika/scope/__init__.cr"


module Magiika
  VERSION = "0.1.0"

  extend self

  def execute(instructions : String, scope : Scope::Scope, filename : String)
    Lang::MagiikaInterpreter.new.execute(instructions, scope, filename)
  end

  def execute(instructions : String)
    Lang::MagiikaInterpreter.new.execute(instructions)
  end

  def interactive
    Lang::MagiikaInterpreter.new.interactive
  end

  def main
    if ARGV.size == 0
      Magiika.interactive
    else
      raise NotImplementedError.new("")
    end
  end

  # call main
  main()
end
