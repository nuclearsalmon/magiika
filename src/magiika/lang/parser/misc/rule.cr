require "./context.cr"


module Magiika::Lang
  private alias RuleReturn = Node?
  private alias RuleBlock = MutableInterpreterContext -> RuleReturn

  private record Rule, \
    pattern : Array(Symbol), \
    block : RuleBlock? do
    
    def try_patterns(
        self_name : Symbol,
        parser : Parser,
        lr : Bool,
        ignores : Array(Symbol),
        noignores : Array(Symbol)?) : MutableInterpreterContext?
      # setup
      # store starting position
      start_pos = parser.parsing_pos
      # create data storage
      context = MutableInterpreterContext.new(self_name)

      # iterate over rule symbols, eg [:NAME, :EQ, :expr]
      @pattern.each do |sym|
        sym_s = sym.to_s
        matched_pattern_part = false

        # sym is token name
        if sym_s == sym_s.upcase  # token
          new_tok = parser.expect(sym, ignores, noignores)

          unless new_tok.nil?
            # MATCH
            context.update(sym, new_tok)
            Log.debug { "Token-match :#{sym} in #{@pattern}@#{self_name}" }
            matched_pattern_part = true
          end
        # sym is group name
        else
          Log.debug { "  - symbol: #{sym}" }
          Log.debug { "  - parsing_pos: #{parser.parsing_pos}" }
          Log.debug { "  - cache:\n" + parser.cache.pretty_inspect }

          # attempt cache-match before group-match
          if (!(cache_slice = parser.cache[parser.parsing_pos]?).nil? \
              && !(cache_data = cache_slice[sym]?).nil?)
            # cache-match
            cached_context, len = cache_data
            Log.debug { "Cache-match :#{sym} in #{@pattern}@#{self_name}: #{cached_context.pretty_inspect}" }
            
            # update context
            # flatten tokens and nodes from cached_context into context if there are no subcontexts in cached_context, else update context by cached_context
            context.careful_merge(sym, cached_context, @pattern.size > 1)
            parser.parsing_pos += len
            matched_pattern_part = true
          else
            # group-match
            group = parser.groups[sym]?
            raise Error::Internal.new("Unknown group name `{sym}`.") if group.nil?

            # store pre-parsing position, then parse
            pre_pos = parser.parsing_pos
            new_context = group.parse(parser)

            # if parsing yielded result
            unless new_context.nil?
              Log.debug { "Group-match :#{sym} in #{@pattern}@#{self_name}" }

              # update cache
              len = parser.parsing_pos - pre_pos
              Log.debug { "Saving :#{sym} to #{pre_pos} with len of #{len}" }
              (parser.cache[pre_pos] ||= Hash(Symbol, Tuple(InterpreterContext, Int32)).new)[sym] = \
                {new_context, len}

              # update context
              # flatten tokens and nodes from new_context into context if there are no subcontexts in new_context, else update context by new_context
              #pp new_context  # expr     :_  ok
              #pp context      # set_var  :_  not ok
              context.careful_merge(sym, new_context, @pattern.size > 1)
              #pp context
              matched_pattern_part = true
            end
          end
        end

        unless matched_pattern_part
          # no match
          parser.parsing_pos = start_pos
          return nil
        end
      end

      return context
    end
  end
end