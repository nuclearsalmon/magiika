require "./context.cr"


module Magiika::Lang
  private alias RuleReturn = Nil
  private alias RuleBlock = Context -> RuleReturn

  private record Rule, \
    pattern : Array(Symbol), \
    block : RuleBlock? do

    def try_patterns(
        self_name : Symbol,
        parser : Parser,
        ignores : Array(Symbol),
        noignores : Array(Symbol)?) : Context?
      # setup
      # store starting position
      start_pos = parser.parsing_pos
      # create data storage
      context = Context.new(self_name)

      # iterate over rule symbols, eg [:NAME, :EQ, :expr]
      @pattern.each do |sym|
        sym_s = sym.to_s
        matched_pattern_part = false

        # sym is token name
        if sym_s == sym_s.upcase  # token
          new_tok = parser.expect(sym, ignores, noignores)

          unless new_tok.nil?
            if @pattern.size > 1
              context.add(sym, new_tok)
            else
              context.add(new_tok)
            end

            Log.debug { "Token-match :#{sym} in #{@pattern}@#{self_name}" }
            matched_pattern_part = true
          end
        # sym is group name
        else
          Log.debug { "  - symbol: #{sym}@#{@pattern}" }
          Log.debug { "  - parsing_pos: #{parser.parsing_pos}" }
          #Log.debug { "  - cache:\n" + parser.cache.pretty_inspect }

          # attempt cache-match before group-match
          cache_data = parser.cache[parser.parsing_pos]?.try(&.[sym]?)
          unless cache_data.nil?
            # cache-match
            cached_context, cached_token_length = cache_data
            Log.debug { "Cache-match :#{sym} in #{@pattern}@#{self_name}: #{cached_context.pretty_inspect}" }

            # update context
            if @pattern.size > 1
              context.add!(sym, cached_context.clone)
            else
              context.merge(cached_context)
            end

            parser.parsing_pos += cached_token_length
            matched_pattern_part = true
          else
            # group-match
            group = parser.groups[sym]?
            raise Error::Internal.new("Unknown group name `{sym}`.") if group.nil?

            # store pre-parsing position, then parse
            pre_parsing_position = parser.parsing_pos
            new_context = group.parse(parser)

            # if parsing yielded result
            unless new_context.nil?
              Log.debug { "Group-match :#{sym} in #{@pattern}@#{self_name}" }

              # update cache
              number_of_tokens = parser.parsing_pos - pre_parsing_position
              cache_entry = {new_context, number_of_tokens}
              Log.debug { "Saving :#{sym} to #{pre_parsing_position}, " +
                          "comprising of #{number_of_tokens} tokens" }
              (parser.cache[pre_parsing_position] \
                ||= Hash(Symbol, Tuple(Context, Int32)).new)[sym] = cache_entry

              # update context
              if @pattern.size > 1
                context.add!(sym, new_context)
              else
                context.merge(new_context)
              end

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