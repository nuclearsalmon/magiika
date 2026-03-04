#!/usr/bin/env -S crystal run
require "./magiika"

module Magiika
  def main
    # get file, if supplied
    file : ::String? = nil
    show_tokenization : ::Bool = false
    show_logs : ::Bool = false
    show_ast : ::Bool = false

    debug_enabled = false
    debug_depth = -1
    debug_groups = [] of ::String
    debug_exclude = [] of ::String
    debug_events = [] of ::String

    # define options parser
    option_parser = OptionParser.new do |parser|
      parser.banner = "✨ Usage: magiika [options] [FILE]"

      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit
      end
      
      parser.on("--show-tokens", "DEVTOOL: Show tokenization.") do
        show_tokenization = true
      end
      parser.on("--show-logs", "DEVTOOL: Show log output.") do
        show_logs = true
      end
      parser.on("--show-ast", "DEVTOOL: Show abstract syntax tree") do
        show_ast = true
      end
      parser.on("--debug", "DEVTOOL: Enable parser debug trace.") do
        debug_enabled = true
      end
      parser.on("--debug-depth=N", "DEVTOOL: Limit debug trace to depth N.") do |n|
        debug_enabled = true
        debug_depth = n.to_i
      end
      parser.on("--debug-groups=GROUPS", "DEVTOOL: Only trace these groups (comma-separated).") do |groups|
        debug_enabled = true
        debug_groups = groups.split(",").map(&.strip)
      end
      parser.on("--debug-exclude=GROUPS", "DEVTOOL: Exclude these groups from trace (comma-separated).") do |groups|
        debug_enabled = true
        debug_exclude = groups.split(",").map(&.strip)
      end
      parser.on("--debug-events=EVENTS", "DEVTOOL: Show only these events: trying,matched,failed,backtracked.") do |events|
        debug_enabled = true
        debug_events = events.split(",").map(&.strip)
      end
      
      parser.missing_option do |option_flag|
        STDERR.puts "💫 Error: #{option_flag} is missing something."
        STDERR.puts parser
        exit(1)
      end
      parser.invalid_option do |option_flag|
        # Only error if it's actually an option
        if option_flag.starts_with?('-')
          STDERR.puts "💫 Error: #{option_flag} is not a valid option."
          STDERR.puts parser
          exit(1)
        end
      end

      # Handle unknown args (potential file)
      parser.unknown_args do |before, _|
        if before.size > 0
          potential_file = before[0]
          if File.file?(potential_file)
            # Found a valid file
            file = potential_file
          elsif potential_file.ends_with?(/\.(?:mg|magi|magiika)/)
            STDERR.puts "💫 Error: file '#{potential_file}' does not exist"
            exit(1)
          end
        end
      end
    end

    # parse options
    option_parser.parse

    # create interpreter
    interpreter = Interpreter.new
    interpreter.show_tokenization = show_tokenization
    interpreter.show_logs = show_logs
    interpreter.show_ast = show_ast

    if debug_enabled
      dbg = interpreter.debugger
      dbg.enabled = true
      dbg.max_depth = debug_depth if debug_depth >= 0
      dbg.only_groups = debug_groups unless debug_groups.empty?
      dbg.exclude_groups = debug_exclude unless debug_exclude.empty?
      unless debug_events.empty?
        dbg.show_trying = debug_events.includes?("trying")
        dbg.show_matched = debug_events.includes?("matched")
        dbg.show_failed = debug_events.includes?("failed")
        dbg.show_backtracked = debug_events.includes?("backtracked")
      end
    end

    # run interpreter
    if file.nil?
      interpreter.run_interactive
    else
      interpreter.run_file(file.not_nil!)
    end
  end
end

# run main
Magiika.main
