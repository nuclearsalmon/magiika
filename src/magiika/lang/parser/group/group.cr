require "../misc/rule.cr"


module Magiika::Lang
  private class Group
    # required for functionality
    getter name, ignores, noignores
    # required for validation
    getter rules, lr_rules

    @name : Symbol
    @rules : Array(Rule)
    @lr_rules : Array(Rule)
    @ignores : Array(Symbol)
    @noignores : Array(Symbol)?

    def initialize(
        @name : Symbol,
        @rules : Array(Rule),
        @lr_rules : Array(Rule),
        @ignores : Array(Symbol),
        @noignores : Array(Symbol)? = nil)
    end

    private def try_rules(parser : Parser, context_for_lr : Context?) : Context?
      rules = (context_for_lr.nil? ? @rules : @lr_rules)
      rules.each do |rule|
        if parser.parsing_tokens[parser.parsing_pos ..].size < rule.pattern.size
          Log.debug { "Skipping rule #{rule.pattern}, not enough tokens." }
          next
        end

        context = rule.try_patterns(@name, parser, @ignores, @noignores)
        if context.nil?
          next
        else
          block = rule.block
          unless block.nil?
            Log.debug { "Executing block for rule #{rule.pattern}@#{@name} ..." }

            context.merge(context_for_lr) unless context_for_lr.nil?
            block.call(context)
          end

          return context
        end
      end
      return nil
    end

    def parse(parser : Parser) : Context?
      Log.debug { "[Trying] :#{@name} ..." }

      context = try_rules(parser, context_for_lr=nil)
      if context.nil?
        Log.debug { "... :#{name} failed" }
        return nil
      end

      # try lr until fail.
      # this will replace a successful rl with the last successful lr,
      # otherwise go with regular if there were no successful lr.
      lr_context : Context? = nil
      loop do
        new_lr_context = try_rules(parser, context_for_lr=context)
        break if new_lr_context.nil?
        lr_context = new_lr_context
      end

      Log.debug { "... :#{name} succeeded" }
      return lr_context.nil? ? context : lr_context
    end
  end
end
