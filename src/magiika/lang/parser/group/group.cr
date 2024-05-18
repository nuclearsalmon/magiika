module Magiika::Lang
  private class Group
    # required for functionality
    getter name, ignores, noignores
    # required for validation
    getter rules, lr_rules

    @name : Symbol
    @rules : Array(Rule)
    @lr_rules : Array(Rule)
    @ignores : Array(Symbol)?
    @noignores : Array(Symbol)?

    def initialize(
        @name : Symbol,
        @rules : Array(Rule),
        @lr_rules : Array(Rule),
        @ignores : Array(Symbol)? = nil,
        @noignores : Array(Symbol)? = nil)
    end

    private def try_rules(parser : Parser, context_for_lr : Context?) : Context?
      rules = (context_for_lr.nil? ? @rules : @lr_rules)
      rules.each do |rule|
        context = rule.try_patterns(@name, parser, @ignores, @noignores)
        if context.nil?
          next
        else
          block = rule.block
          unless block.nil?
            context.merge(context_for_lr) unless context_for_lr.nil?

            Log.debug { "Executing block for rule #{rule.pattern}@#{@name} ..." }
            block.call(context)
          end

          return context
        end
      end
      return nil
    end

    def parse(parser : Parser) : Context?
      Log.debug { "... trying rules for :#{@name} ..." }

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
