module Magiika::Lang
  private alias RuleBlock = \
    Array(MatchedToken), \
    Array(Node) \
    -> Node | Array(Node) | \
       MatchedToken | Array(MatchedToken) | \
       Tuple(Array(Node), Array(MatchedToken))

  private record Rule,
    pattern : Array(Symbol),
    block : RuleBlock?

  private alias TryRulesResult \
    = Tuple(Array(MatchedToken), Array(Node))
  
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
        rule_result : TryRulesResult, 
        lr : Bool) : TryRulesResult?
      # store starting position
      start_pos = parser.parsing_pos

      # iterate over rule symbols, eg [:NAME, :EQ, :expr]
      rule.pattern.each do |sym|
        sym_s = sym.to_s
        matched_rule = false

        # sym is token name
        if sym_s == sym_s.upcase  # token
          new_tok = parser.expect(sym, @ignores, @noignores)

          unless new_tok.nil?
            # MATCH
            rule_result[0] << new_tok  # tok
            Log.debug { "Token-match :#{sym} in #{rule.pattern}" }
            matched_rule = true
          end
        else
          Log.debug { "  - symbol: #{sym}"}
          Log.debug { "  - parsing_pos: #{parser.parsing_pos}"}
          Log.debug { "  - cache:\n" + parser.cache.pretty_inspect }
          if (\
              !((cache_section = \
                parser.cache[parser.parsing_pos]?).nil?)\
              && !((cache_result = cache_section[sym]?).nil?))

            cache_node = cache_result[0]
            cache_offset = cache_result[1]

            parser.parsing_pos += cache_offset

            rule_result[0].concat(cache_node[0])  # tok
            rule_result[1].concat(cache_node[1])  # node

            Log.debug { "Cache-match :#{sym} in #{rule.pattern}" }
            matched_rule = true
          # sym is group name
          elsif !((group = parser.groups[sym]?).nil?)
            pre_pos = parser.parsing_pos
            new_result = group.parse(parser)
            unless new_result.nil?
              # MATCH
              rule_result[0].concat(new_result[0])  # tok
              rule_result[1].concat(new_result[1])  # node

              len = parser.parsing_pos - pre_pos
              Log.debug { "Saving :#{sym} to #{pre_pos} with len of #{len}" }

              if parser.cache[pre_pos]?.nil?
                parser.cache[pre_pos] = \
                  Hash(Symbol, Tuple(TryRulesResult, Int32)).new
              end
              parser.cache[pre_pos][sym] = \
                Tuple(TryRulesResult, Int32).new(\
                  new_result, 
                  len)

              Log.debug { "Group-match :#{sym} in #{rule.pattern}" }
              matched_rule = true
            end
          end
        # was group name, but did not find matching group
        end

        unless matched_rule
          # NO MATCH
          rule_result = nil
          break
        end
      end

      return rule_result
    end

    private def try_rules(
        parser : Parser,
        lr : Bool = false,
        pre_result : TryRulesResult? = nil) : TryRulesResult?

      start_pos = parser.parsing_pos

      rules = (lr ? @lr_rules : @rules)
      rules.each do |rule|
        if parser.parsing_tokens[start_pos..].size < rule.pattern.size
          Log.debug { "Skipping rule #{rule.pattern}, not enough tokens." }
          next
        end

        rule_result = pre_result.nil? ? \
          TryRulesResult.new([] of MatchedToken, [] of Node) \
          : TryRulesResult.new(*pre_result)

        rule_result = try_patterns(
          parser,
          rule, 
          rule_result, lr)

        if rule_result.nil? \
            || (rule_result[0].size() == 0 && rule_result[1].size() == 0)
          # did not match anything, reset start
          parser.parsing_pos = start_pos
        else
          block = rule.block
          unless block.nil?
            Log.debug { "Executing block for rule #{rule.pattern} ..." }
            block_result = block.call(*rule_result)
            block_result = [block_result] unless block_result.is_a?(Array)
            return TryRulesResult.new(
              [] of MatchedToken,
              block_result)
          else
            return TryRulesResult.new(
              rule_result[0].size() != 0 ? \
                [rule_result[0][0]] : \
                [] of MatchedToken,
              rule_result[1].size() != 0 ? \
                [rule_result[1][0]] : \
                [] of Node)
          end
        end
      end

      return nil
    end

    def parse(parser : Parser) : TryRulesResult?
      Log.debug { "[Trying] :#{@name} ..." }
      result = try_rules(parser, lr=false)
      if result.nil?
        Log.debug { "... :#{name} failed" }
        return nil
      end

      start_pos = parser.parsing_pos
      loop do
        new_result = try_rules(parser, lr=true, result)

        if new_result.nil?
          Log.debug { "... :#{name} succeeded" }
          return result 
        else
          result = new_result
        end
      end
    end
  end

  class Group::Builder
    @name : Symbol
    @rules = Array(Rule).new
    @lr_rules = Array(Rule).new
    @ignores = Array(Symbol).new
    @noignores : Array(Symbol)? = nil

    def self.new(name : Symbol, &)
      with Group.new(name) yield
    end

    def initialize(@name : Symbol)
    end

    def build : Group
      Group.new(
        @name, @rules, @lr_rules, @ignores, @noignores)
    end

    private def rule(pattern : Symbol)
      rule(Rule.new([pattern], nil))
    end

    private def rule(*pattern : Symbol)
      rule(Rule.new(pattern.to_a, nil))
    end

    private def rule(pattern : Symbol, &block : RuleBlock)
      rule(Rule.new([pattern], block))
    end

    private def rule(*pattern : Symbol, &block : RuleBlock)
      rule(Rule.new(pattern.to_a, block))
    end

    private def rule(pattern : Array(Symbol))
      rule(Rule.new(pattern.to_a, nil))
    end

    private def rule(pattern : Array(Symbol), &block : RuleBlock)
      rule(Rule.new(pattern.to_a, block))
    end

    private def rule(rule : Rule)
      if rule.pattern[0] == @name
        rule.pattern.shift
        @lr_rules << rule
      else
        @rules << rule
      end
    end

    private def ignore(pattern : Symbol)
      @ignores << pattern
    end

    private def noignore()
      noignores = @noignores
      @noignores = Array(Symbol).new if noignores.nil?
    end

    private def noignore(pattern : Symbol)
      noignores = @noignores
      if noignores.nil?
        noignores = Array(Symbol).new 
        @noignores = noignores
      end
      noignores << pattern
    end
  end
end
