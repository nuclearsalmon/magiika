require "../rule.cr"


module Magiika::Lang
  private class Group
    # required for functionality
    getter name, ignores, noignores
    # required for validation
    getter rl_rules, lr_rules

    @name : Symbol
    @rl_rules : Array(Rule)
    @lr_rules : Array(Rule)
    @ignores : Array(Symbol)
    @noignores : Array(Symbol)?

    def initialize(
        @name : Symbol,
        @rl_rules : Array(Rule),
        @lr_rules : Array(Rule),
        @ignores : Array(Symbol),
        @noignores : Array(Symbol)? = nil)
    end

    private def try_rules(parser : Parser, lr : Bool = false) : InterpreterContext?
      rules = (lr ? @lr_rules : @rl_rules)
      rules.each do |rule|
        if parser.parsing_tokens[parser.parsing_pos ..].size < rule.pattern.size
          Log.debug { "Skipping rule #{rule.pattern}, not enough tokens." }
          next
        end

        context : MutableInterpreterContext? = rule.try_patterns(@name, parser, lr, @ignores, @noignores)
        if context.nil?
          next
        else
          block = rule.block
          unless block.nil?
            Log.debug { "Executing block for rule #{rule.pattern} ..." }
            if node_result = block.call(context)
              context.clear
              context.update(:_, node_result)
            end
          end

          return context.immutable
        end
      end
      return nil
    end

    def parse(parser : Parser) : InterpreterContext?
      Log.debug { "[Trying] :#{@name} ..." }

      context = try_rules(parser, lr=false)
      if context.nil?
        Log.debug { "... :#{name} failed" }
        return nil
      end

      # try lr until fail. 
      # this will replace a successful rl with the last successful lr, 
      # otherwise go with rl if there were no successful lr.
      loop do
        new_context = try_rules(parser, lr=true)
        break if new_context.nil?
        context = new_context
      end

      Log.debug { "... :#{name} succeeded" }
      return context
    end
  end
end
