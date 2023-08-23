require "./interpreter.cr"
require "./position.cr"
require "./token.cr"
require "../node/base.cr"
require "../node/type/__init__.cr"
require "../node/stmt/__init__.cr"
require "../scope/__init__.cr"

def Magiika::Lang.define_magiika() : Magiika::Lang::Interpreter
  return Magiika::Lang::Interpreter.new do
    # TOKENS
    # --------------------------------------------------

    # comments
    #token(:COMMENT, /\#.*$/)
    #token(:COMMENT, /\/\*([^*]|\r?\n|(\*+([^*\/]|\r?\n)))*\*+\//)
    #token(:DOC_COMMENT, /\/\*\*(\r?\n|(\*+([^*\/]|\r?\n)))*\*\*+\//)

    # keywords
    #token(:CONST, /const/)

    # operators
    token(:DEFINE, /:/)
    token(:ASSIGN, /=/)
    #token(:INLINE_ASSIGN, /:=/)

    # literals
    token(:BOOL, /true|false/)
    token(:FLT, /\d+\.\d+/)
    token(:INT, /[\+\-]?\d+/)
    #token(:STR, /"([^"\\]*(?:\\.[^"\\]*)*)"/)
    #token(:STR, /'([^'\\]*(?:\\.[^'\\]*)*)'/)

    # names
    token(:NAME, /[A-Za-z_][A-Za-z0-9_]*/)

    # whitespace (run this last to allow for whitespace-sensitive tokens)
    token(:TAB, /\t| {2}+/)
    token(:SPACE, / +/)
    token(:LINE_SEGMENT, /\\[\t ]*\r?\n/)
    token(:NEWLINE, /\r?\n/)
    token(:INLINE_NEWLINE, /;/)


    # SYNTAX
    # --------------------------------------------------

    root do
      ignore(:LINE_SEGMENT)
      ignore(:SPACE)
      rule(:stmts)
    end

    group(:nl) do
      rule(:NEWLINE)
      rule(:INLINE_NEWLINE)
    end

    group(:nls) do
      rule(:nl, :nls)
      rule(:nl)
    end

    group(:spc) do
      rule(:TAB)
      rule(:SPACE)
    end

    group(:spcs) do
      rule(:spc, :spcs)
      rule(:spc)
    end

    group(:stmts) do
      ignore(:NEWLINE)
      rule(:stmt, :stmts) do |_,(stmt,stmts)|
        pp stmts
        raise Error::InternalType.new unless stmts.is_a?(Array)
        raise Error::InternalType.new unless stmt.is_a?(Node::Node)
        
        [stmt, *stmts]
      end
      rule(:stmt)
    end

    group(:stmt) do
      rule(:setvar)
      rule(:getvar)
    end

    group(:setvar) do
      rule(:DEFINE, :NAME, :ASSIGN, :value) do \
        |(df,name,op),(value)|
        Magiika::Node::Assign.new(df.pos, name, value)
      end
    end

    group(:getvar) do
      rule(:NAME) do |(name),_|
        Magiika::Node::Retrieve.new(name.pos, name)
      end
    end

    group(:value) do
      rule(:BOOL) do |(value),_|
        Magiika::Node::Bool.new(value.value == "true", value.pos)
      end

      rule(:INT) do |(value),_|
        Magiika::Node::Int.new(value.value.to_i32, value.pos)
      end

      rule(:FLT) do |(value),_|
        Magiika::Node::Flt.new(value.value.to_f32, value.pos)
      end
    end

    # collect(:decos, :deco)
    #
    # group(:deco) do
    #   rule(:PUBL)
    #   rule(:PRIV)
    #   rule(:CONST)
    # end
  end
end

module Magiika::Lang
  class MagiikaInterpreter
    private ANSI_RESET             = "\x1b[m"
    private ANSI_UNDERLINE_ON      = "\x1b[4m"
    private ANSI_UNDERLINE_OFF     = "\x1b[24m"
    private ANSI_BOLD_ACCENT_STYLE = "\x1b[38;2;253;134;42;4m"
    private ANSI_ACCENT_STYLE      = "\x1b[38;2;253;134;42;3m"
    private ANSI_WARNING_STYLE     = "\x1b[38;2;235;59;47m"
    private ANSI_RELAXED_STYLE     = "\x1b[38;2;150;178;195m"

    @@interpreter : Interpreter = Lang.define_magiika
    @display_tokenization = false
    @display_parsing = false


    private def banner
      print ANSI_BOLD_ACCENT_STYLE + \
        " -    ⊹ M a g i i k a ₊+   - " + \
        ANSI_RESET + "\n"
      print ANSI_ACCENT_STYLE + \
        "   a ⊹₊magical₊+ language~   " + \
        ANSI_RESET + "\n\n"
    end

    protected def resetprint(msg)
      if msg.is_a?(String)
        print msg + "\n"
      else
        pp msg
      end
      print "#{ANSI_RESET}"
    end

    protected def inform(msg)
      print "🌟 #{ANSI_ACCENT_STYLE}"
      resetprint msg
    end

    protected def notify(msg)
      print "🌠 #{ANSI_RELAXED_STYLE}"
      resetprint msg
    end

    protected def warn(msg)
      print "💫 #{ANSI_WARNING_STYLE}"
      resetprint msg
    end

    protected def cond_to_tg(condition)
      return condition ? "enabled" : "disabled"
    end

    protected def exit
      print "🌠 #{ANSI_RELAXED_STYLE}leaving interactive mode#{ANSI_RESET}\n"
      exit 0
    end

    protected def print_ex(ex : Exception)
      filtered_backtrace = [] of String
      ex.backtrace.each{ | line |
        break if line.ends_with?("in '__crystal_main'")
        filtered_backtrace << line
      }

      join_str = "\n    "
      warn(ex.to_s + "\n   Traceback:" \
        + join_str + filtered_backtrace.join(join_str))
      print("\n")
    end

    def execute(
        instructions : String,
        scope : Scope::Scope,
        filename : String) : Node::Node?
      tokens = @@interpreter.tokenize(instructions, filename)

      if @display_tokenization
        inform(tokens)
      end

      parsed_result = @@interpreter.parse(tokens)

      if @display_parsing
        inform(parsed_result)
      end

      interpreted_result = nil
      unless parsed_result.nil?
        if !parsed_result[0].empty?
            raise Error::Internal.new("Final must return no tokens.")
        end

        parsed_result[1].each { |stmt|
          interpreted_result = stmt.eval(scope)
        }
      end

      return interpreted_result
    end

    def execute(instructions : String) : Node::Node?
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
      while true
        begin
          print "✨ "
          input = gets

          break if input.nil? || input == "exit"

          if input.size == 2 && input[0] == '%'
            case input[1]
            when 't'
              @display_tokenization = !@display_tokenization
              notify("show tokenization result: #{cond_to_tg(@display_tokenization)}.")
              print("\n")
              next
            when 'p'
              @display_parsing = !@display_parsing
              notify("show parsing result: #{cond_to_tg(@display_parsing)}.")
              print("\n")
              next
            end
          end

          result = execute(input, scope, filename)
          unless result.nil?
            print "⭐ "
            puts result.to_s
          end
          puts "\n"
        rescue ex : Error::Safe
          print_ex(ex)
        end
      end
    rescue ex : Exception
      warn(ex.inspect_with_backtrace)
    ensure
      exit
    end
  end
end
