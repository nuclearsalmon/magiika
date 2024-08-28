#!/usr/bin/env -S crystal run
require "./magiika"

module Magiika
  def main
    # get file, if supplied
    file : String? = ARGV[0]?
    if file.nil? || file.starts_with?('-')
      file = nil
    else
      ARGV.delete_at(0)
    end

    show_tokenization : ::Bool = false
    show_logs : ::Bool = false
    show_ast : ::Bool = false

    # define options parser
    option_parser = OptionParser.new do |parser|
      parser.banner = "✨ Usage: magiika [FILE] [options]"
      parser.on("--show-tokens", "DEVTOOL: Show tokenization.") do
        show_tokenization = true
      end
      parser.on("--show-logs", "DEVTOOL: Show log output.") do
        show_logs = true
      end
      parser.on("--show-ast", "DEVTOOL: Show abstract syntax tree") do
        show_ast = true
      end
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

    # parse options
    option_parser.parse

    # create interpreter
    interpreter = Interpreter.new
    interpreter.show_tokenization = show_tokenization
    interpreter.show_logs = show_logs
    interpreter.show_ast = show_ast

    # run interpreter
    if file.nil?
      interpreter.run_interactive
    else
      interpreter.run_file(file)
    end
  end
end

# run main
Magiika.main
