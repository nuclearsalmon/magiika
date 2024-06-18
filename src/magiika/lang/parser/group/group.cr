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
    @trailing_ignores : Array(Symbol)?

    def initialize(
        @name : Symbol,
        @rules : Array(Rule),
        @lr_rules : Array(Rule),
        @ignores : Array(Symbol)? = nil,
        @noignores : Array(Symbol)? = nil,
        @trailing_ignores : Array(Symbol)? = nil)
    end

    private def try_rules(
        parser : Parser,
        context_for_lr : Context?,
        computed_ignores : Array(Symbol)) : Context?
      rules = (context_for_lr.nil? ? @rules : @lr_rules)
      rules.each do |rule|
        context = rule.try_patterns(@name, parser, computed_ignores)
        unless context.nil?
          block = rule.block
          unless block.nil?
            #context.merge(context_for_lr) unless context_for_lr.nil?
            unless context_for_lr.nil?
              context_for_lr.merge(context)
              context = context_for_lr
            end

            Log.debug { "Executing block for rule #{rule.pattern}@#{@name} ..." }
            block.call(context)
          end

          # matched, so consume trailing ignores
          trailing_ignores = @trailing_ignores
          unless trailing_ignores.nil?
            loop do
              token = parser.next_token(trailing_ignores)
              break if token.nil?
            end
          end

          return context
        end
      end
      return nil
    end

    def parse(parser : Parser) : Context?
      #Log.debug { "... trying rules for :#{@name} ..." }

      # compute ignores
      computed_ignores = parser.compute_ignores(@ignores, @noignores)

      context = try_rules(
        parser,
        context_for_lr=nil,
        computed_ignores)
      if context.nil?
        Log.debug { "... :#{name} failed" }
        return nil
      end

      # try lr until fail
      loop do
        new_context = try_rules(
          parser,
          context_for_lr=context,
          computed_ignores)
        break if new_context.nil?
        context = new_context
      end

      Log.debug { "... :#{name} succeeded" }
      return context
    end
  end
end
