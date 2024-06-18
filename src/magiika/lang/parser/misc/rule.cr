module Magiika::Lang
  private alias RuleBlock = Proc(Context, Nil)

  private class Rule
    getter pattern, block

    def initialize(
        @pattern : Array(Symbol),
        @block : RuleBlock? = nil)
      if @pattern.size < 1
        raise Error::Internal.new("A Rule cannot have an empty pattern.")
      end
    end

    def try_patterns(
        self_name : Symbol,
        parser : Parser,
        computed_ignores : Array(Symbol)) : Context?
      if parser.not_enough_tokens?(@pattern.size)
        Log.debug { "Skipping rule #{@pattern}, not enough tokens." }
        return nil
      end

      # store initial parsing position
      initial_parsing_position = parser.parsing_position

      # create data storage
      context = Context.new(self_name)

      # iterate over rule symbols, eg [:NAME, :EQ, :expr]
      @pattern.each do |sym|
        # sym is token name
        if Util.upcase?(sym)  # token
          #Log.debug { "Trying token  :#{sym} in #{@pattern} from #{parser.parsing_position}" }

          token = parser.expect_token(sym, computed_ignores)

          if token.nil?
            target_token = parser.tokens[sym]
            if target_token.greedy
              token = parser.next_token(computed_ignores)
              if !token.nil? && target_token.pattern.match(token.value)
                token = MatchedToken.new(
                  sym,
                  token.value,
                  token.position)
              else
                parser.parsing_position = initial_parsing_position
                return nil
              end
            else
              parser.parsing_position = initial_parsing_position
              return nil
            end
          end

          Log.debug { "Matched token :#{sym} in #{@pattern}@:#{self_name}" }
          if @pattern.size > 1
            context.add(sym, token)
          else
            context.add(token)
          end
        # sym is group name
        else
          #Log.debug { "Trying group  :#{sym} in #{@pattern} from #{parser.parsing_position}" }

          group_context = parser.expect_group(sym, computed_ignores)

          if group_context.nil?
            parser.parsing_position = initial_parsing_position
            return nil
          end

          Log.debug { "Matched group :#{sym} in #{@pattern}@:#{self_name}" }

          # update context
          if @pattern.size > 1
            context.unsafe_add(sym, group_context)
          else
            context.unsafe_merge(group_context)
          end
        end
      end

      return context
    end
  end
end