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
        if parser.parsing_tokens[parser.parsing_position ..].size < rule.pattern.size
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

            #p "context:"
            #pp context
            #p "---"

            unless context_for_lr.nil?
              #p "merging contexts"
              #p "context_for_lr:"
              #pp context_for_lr
              #p "---"

              context.merge(context_for_lr)# unless context_for_lr.nil?

              #p "context after merge"
              #pp context
              #p "---"
            end

            block.call(context)

            #p "context after call:"
            #pp context
            #p "---"
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

      # try lr until fail
      loop do
        new_context = try_rules(parser, context_for_lr=context)
        break if new_context.nil?
        context = new_context
      end

      Log.debug { "... :#{name} succeeded" }
      return context
    end
  end
end
