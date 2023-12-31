require "../rule.cr"


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
  
    private def try_patterns(
        parser : Parser, 
        rule : Rule, 
        context : RuleContext, 
        lr : Bool) : Bool
      # store starting position
      start_pos = parser.parsing_pos

      # iterate over rule symbols, eg [:NAME, :EQ, :expr]
      rule.pattern.each do |sym|
        sym_s = sym.to_s
        matched_pattern_part = false

        # sym is token name
        if sym_s == sym_s.upcase  # token
          new_tok = parser.expect(sym, @ignores, @noignores)

          unless new_tok.nil?
            # MATCH
            context.update(sym, new_tok)
            Log.debug { "Token-match :#{sym} in #{rule.pattern}" }
            matched_pattern_part = true
          end
        # sym is group name
        else
          Log.debug { "  - symbol: #{sym}" }
          Log.debug { "  - parsing_pos: #{parser.parsing_pos}" }
          Log.debug { "  - cache:\n" + parser.cache.pretty_inspect }

          # attempt token-match before group-match
          pre_pos = parser.parsing_pos
          
          if (!(cache_slice = parser.cache[pre_pos]?).nil? \
              && !(cache_data = cache_slice[sym]?).nil?)
            # cache-match
            Log.debug { "Cache-match :#{sym} in #{rule.pattern}" }

            cached_context, len = cache_data
            # FIXME
            Log.debug { "Cache response: #{cached_context.pretty_inspect}"}
            context.update(sym, cached_context)
            parser.parsing_pos += len

            matched_pattern_part = true
          else
            # group-match
            group = parser.groups[sym]?
            raise Error::Internal.new("Unknown group name `{sym}`.") if group.nil?

            # store pre-parsing position, then parse
            pre_pos = parser.parsing_pos
            new_context = group.parse(parser, context)

            # if parsing yielded result
            unless new_context.nil?
              Log.debug { "Group-match :#{sym} in #{rule.pattern}" }

              # update cache
              len = parser.parsing_pos - pre_pos
              Log.debug { "Saving :#{sym} to #{pre_pos} with len of #{len}" }
              (parser.cache[pre_pos] ||= Hash(Symbol, Tuple(RuleContext, Int32)).new)[sym] = \
                {new_context, len}

              # update context
              #if context.node_results.size > 1 #|| context.token_results.size > 2
              #  raise Error::Internal.new("#{context.pretty_inspect}")
              #end
              context.update(sym, new_context)

              matched_pattern_part = true
            end
          end
        end

        unless matched_pattern_part
          # no match
          parser.parsing_pos = start_pos
          return false
        end
      end

      return true
    end

    private def try_rules(
        parser : Parser,
        lr : Bool = false,
        context : RuleContext? = nil) : RuleContext?

      rules = (lr ? @lr_rules : @rules)
      rules.each do |rule|
        if parser.parsing_tokens[parser.parsing_pos ..].size < rule.pattern.size
          Log.debug { "Skipping rule #{rule.pattern}, not enough tokens." }
          next
        end

        new_context = RuleContext.new(@name).tap { |nc| nc.update(context) unless context.nil? }

        success = try_patterns(parser, rule, new_context.as(RuleContext), lr)
        next unless success
        context = new_context
        
        
        block = rule.block
        unless block.nil?
          Log.debug { "Executing block for rule #{rule.pattern} ..." }

          # evaluate block
          block_result = block.call(context.as(RuleContext))
 
          # rename hash key
          block_result[@name] = block_result[:_] if block_result.has_key?(:_)
          block_result.delete(:_)

          # Return as context
          context = RuleContext.new(@name)
          context.update(block_result)
          return context
        else
          new_context = RuleContext.new(@name)
          new_context.update(context)
          return new_context
        end
      end
      return nil
    end

    def parse(parser : Parser, context : RuleContext) : RuleContext?
      Log.debug { "[Trying] :#{@name} ..." }
      
      context = try_rules(parser, lr=false, context)
      if context.nil?
        Log.debug { "... :#{name} failed" }
        return nil
      end

      loop do
        new_context = try_rules(parser, lr=true, context)

        if new_context.nil?
          Log.debug { "... :#{name} succeeded" }
          return context 
        else
          context = new_context
        end
      end
    end
  end
end
