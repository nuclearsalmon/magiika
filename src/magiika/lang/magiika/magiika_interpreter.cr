require "../parser/parser.cr"
require "../parser/builder.cr"

require "../position.cr"
require "../parser/misc/token.cr"

require "./syntax_macros.cr"
require "./syntax/*"

require "../../node/base.cr"
require "../../node/constraint.cr"
require "../../node/meta.cr"
require "../../node/type/list.cr"
require "../../node/type/**"
require "../../node/stmt/**"
require "../../scope/scope.cr"
require "../../scope/**"


module Magiika::Lang
  class MagiikaInterpreter
    private class Builder < Parser::Builder
      include Syntax
  
      def initialize
        super
  
        # register builtins
        register_tokens
        register_commons
        register_base
        register_expressions
        register_conditions
        register_variables
        register_functions
      end
    end

    private ANSI_RESET             = "\x1b[m"
    private ANSI_UNDERLINE_ON      = "\x1b[4m"
    private ANSI_UNDERLINE_OFF     = "\x1b[24m"
    private ANSI_BOLD_ACCENT_STYLE = "\x1b[38;2;253;134;42;4m"
    private ANSI_ACCENT_STYLE      = "\x1b[38;2;253;134;42;3m"
    private ANSI_WARNING_STYLE     = "\x1b[38;2;235;59;47m"
    private ANSI_RELAXED_STYLE     = "\x1b[38;2;150;178;195m"

    @parser : Parser
    
    @display_tokenization = false
    @display_parsing = false

    def initialize
      @parser = Builder.new.build
    end


    # decorative
    # ------------------------------------------------------

    private def banner
      print(ANSI_BOLD_ACCENT_STYLE +
        " -    ⊹ M a g i i k a ₊+   - " +
        ANSI_RESET + "\n")
      print(ANSI_ACCENT_STYLE +
        "   a ⊹₊magical₊+ language~   " +
        ANSI_RESET + "\n\n")
      
      notify("(type `##h' for debug commands ₊+)")
    end

    private def prettyprint(msg)
      if msg.is_a?(String)
        print msg + "\n"
      else
        pp msg
      end
    end

    private def resetprint(msg)
      prettyprint msg
      print "#{ANSI_RESET}"
    end

    private def inform(msg)
      print "🌟 #{ANSI_ACCENT_STYLE}"
      resetprint msg
    end

    private def notify(msg)
      print "🌠 #{ANSI_RELAXED_STYLE}"
      resetprint msg
    end

    private def warn(msg)
      print "💫 #{ANSI_WARNING_STYLE}"
      resetprint msg
    end

    private def cond_to_tg(condition)
      return condition ? "enabled" : "disabled"
    end

    private def exit
      print "🌠 #{ANSI_RELAXED_STYLE}leaving interactive mode#{ANSI_RESET}\n"
      exit 0
    end

    private def print_safe_ex(ex : Exception)
      filtered_backtrace = [] of String
      ex.backtrace.each{ | line |
        break if line.ends_with?("in '__crystal_main'")
        filtered_backtrace << line
      }

      join_str = "\n    "
      warn(ex.to_s + "\n   Traceback:" + 
        join_str + filtered_backtrace.join(join_str))
      print("\n")
    end

    private def operator_command(cmd : Char)
      case cmd
      when 't'
        @display_tokenization = !@display_tokenization
        notify("show tokenization result: #{cond_to_tg(@display_tokenization)}.")
      when 'p'
        @display_parsing = !@display_parsing
        notify("show parsing result: #{cond_to_tg(@display_parsing)}.")
      when 'l'
        from_level = Magiika.log_level
        is_debug = from_level == ::Log::Severity::Debug
        to_level = is_debug ? ::Log::Severity::Info : ::Log::Severity::Debug
        Magiika.change_log_level(to_level)
        notify("show debug_logs: #{cond_to_tg(!is_debug)}.")
      when 'h'
        notify(
          ANSI_UNDERLINE_ON +
          "command list ⊹ ₊+          " +
          ANSI_UNDERLINE_OFF + "\n" +
          "   `t' : toggle showing tokenization result\n" +
          "   `p' : toggle showing parsing result\n" +
          "   `l' : toggle showing debug logs\n" +
          "   `h' : this help menu")
      else
        warn("unknown command. try `##h'.")
      end
      print("\n")
    end


    # functionality
    # ------------------------------------------------------

    def parse(parsing_tokens : Array(MatchedToken)) \
        : Tuple(Array(MatchedToken), Array(Node))?
      @parser.parse(parsing_tokens)
    end

    def execute(
        instructions : String,
        scope : Scope,
        filename : String) : Node?
      tokens = @parser.tokenize(instructions, filename)

      if @display_tokenization
        inform(tokens)
      end

      parsed_result = @parser.parse(tokens)

      if @display_parsing
        inform(parsed_result)
      end

      return parsed_result.eval(scope) unless parsed_result.nil? 
      return nil
    end

    def execute(instructions : String) : Node?
      filename = "interpreted"
      pos = Lang::Position.new(filename, 1, 1)
      scope = Scope::Global.new("global", pos)

      return execute(instructions, scope, filename)
    end

    def interactive : Nil
      filename = "interpreted"
      pos = Lang::Position.new(filename, 1, 1)
      scope = Scope::Global.new("global", pos)

      Signal::INT.trap { print "\n"; exit }

      banner
      loop do
        begin
          print "✨ "
          input = gets

          break if input.nil? || input == "exit"

          if input.size == 3 && input[0] == '#' && input[1] == '#'
            operator_command(input[2])
          else
            unless (result = execute(input, scope, filename)).nil?
              print "⭐ #{result.to_s}\n"
            end
            print "\n"
          end
        rescue ex : Error::Safe
          print_safe_ex(ex)
        end
      end
    rescue ex : Exception
      warn(ex.inspect_with_backtrace)
    ensure
      exit
    end
  end
end
