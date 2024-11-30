class Magiika::Interpreter
  @parser : Merlin::Parser(Symbol, Node) = build_parser

  property show_tokenization : ::Bool = false
  property show_ast : ::Bool = false
  property show_logs : ::Bool = false

  private def self.build_parser
    builder = Merlin::ParserBuilder(Symbol, Node).new(
      :"<EOL>"
    ) { |builder|
      Syntax.apply_syntax(builder)
    }
    builder.build
  end

  def tokenize(
      instructions : String,
      filename : String? = nil) : Array(Merlin::MatchedToken(Symbol))
    tokens = @parser.tokenize(instructions, filename)
    if @show_tokenization
      token_msg = "Tokens:\n   "
      token_msg += tokens.map(&.to_s).join("\n   ")
      print_inform(token_msg)
    end
    tokens
  end

  def parse(
      tokens : Array(Merlin::MatchedToken(Symbol))) : Node
    parsed_result = @parser.parse(tokens)
    if @show_ast
      token_msg = "Abstract syntax tree:\n   "
      token_msg += tokens.map(&.to_s).join("\n   ")
      print_inform(parsed_result.pretty_inspect)
    end
    parsed_result
  end

  def execute(
      instructions : String,
      scope : Scope,
      filename : String? = nil) : Node
    # tokenize
    filename = filename.nil? ? scope.position.filename : filename
    tokens = tokenize(instructions, filename)

    # parse into AST
    parser_result = parse(tokens)

    # evaluate AST
    parser_result.eval(scope)
  end

  private def create_signal_trap
    # begin/rescue used here, as signal trapping is not
    # implemented on Windows
    begin
      Signal::INT.trap {
        print "\n"
        exit 0
      }
    rescue ex : NotImplementedError
    end
  end

  private def print_inform(msg)
    print "🌟 #{ ANSI::MAGIIKA_ACCENT }#{ msg }#{ ANSI::RESET }\n"
  end

  private def print_warning(msg : String) : ::Nil
    print "💫 #{ ANSI::MAGIIKA_WARNING }#{ msg }#{ ANSI::RESET }\n"
  end

  private def print_error(ex : Exception)
    # filter out junk
    filtered_backtrace = [] of String
    ex.backtrace.each{ | line |
      break if line.ends_with?("in '__crystal_main'")
      filtered_backtrace << line
    }

    print_warning(
      "#{ ex.message }\n\n" +
      "Crystal traceback:\n   #{ filtered_backtrace.join("\n   ") }")
  end

  def run_file(file_path : String) : ::Nil
    if @show_logs
      Magiika.change_log_level(::Log::Severity::Debug)
    else
      Magiika.change_log_level(::Log::Severity::Warn)
    end

    # Create "^C" signal trap
    create_signal_trap

    # create scope
    scope = Scope::Global.new(Position.new(file_path))

    # read file contents
    file_contents = File.read(file_path)

    # execute and present result
    begin
      result = execute(file_contents, scope, file_path)
      unless result.is_a?(Node::Nil)
        print "⭐ #{ result.to_s_internal }\n"
      end
    rescue ex : Error::Safe
      print_warning(ex.to_s)
    end
  rescue ex
    print_error(ex)
    exit(1)
  end

  def run_interactive : ::Nil
    if @show_logs
      Magiika.change_log_level(::Log::Severity::Debug)
    else
      Magiika.change_log_level(::Log::Severity::Warn)
    end

    # Create "^C" signal trap
    create_signal_trap

    # create scope
    scope = Scope::Global.new(Position.new)

    # print banner
    print \
      ANSI::MAGIIKA_STRONG_ACCENT +
      " -    ⊹ M a g i i k a ₊+   - " +
      ANSI::RESET +
      "\n" +
      ANSI::MAGIIKA_ACCENT +
      "   a ⊹₊magical₊+ language~   " +
      ANSI::RESET +
      "\n"

    loop do
      # get input
      print "\n✨ "
      input = gets
      break if input.nil? || input == "exit"
      next if input == ""

      # execute and present result
      begin
        result = execute(input, scope)
        unless result.is_a?(Node::Nil)
          print "⭐ #{ result.to_s_internal }\n"
        end
      rescue ex : Error::Safe
        print_warning(ex.to_s)
      end
    end
  rescue ex
    print_error(ex)
    exit 1
  end
end