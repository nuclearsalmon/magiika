require "./position.cr"
require "./token.cr"
require "../node/base.cr"
require "../node/type/__init__.cr"
require "../node/stmt/assign.cr"
require "../node/stmt/retrieve.cr"
require "../error.cr"
require "./tokenizer.cr"


module Magiika::Lang
  private alias RuleBlock = \
    Array(MatchedToken), \
    Array(Node::Node) \
    -> Node::Node | Array(Node::Node)

  private record Rule,
    pattern : Array(Symbol),
    block : RuleBlock?

  private alias TryRulesResult \
    = Tuple(Array(MatchedToken), Array(Node::Node))
  
  private class Group
    getter name, ignores, noignores

    @name : Symbol
    @rules = Array(Rule).new
    @lr_rules = Array(Rule).new
    @ignores = Array(Symbol).new
    @noignores : Array(Symbol)? = nil

    def self.new(interpreter : Interpreter,
                 name : Symbol, &block)
      with Group.new(interpreter, name) yield
    end

    def initialize(@interpreter : Interpreter,
                   @name : Symbol)
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

    protected def ignore(pattern : Symbol)
      @ignores << pattern
    end

    protected def noignore()
      noignores = @noignores
      @noignores = Array(Symbol).new if noignores.nil?
    end

    protected def noignore(pattern : Symbol)
      noignores = @noignores
      if noignores.nil?
        noignores = Array(Symbol).new 
        @noignores = noignores
      end
      noignores << pattern
    end

    # TODO: Move all methods that aren't meant to be called
    #  with yield to outside the data class. Move to module.

    def parse : TryRulesResult?
      puts "[Trying] :#{@name} ..."
      result = try_rules(lr=false)
      if result.nil?
        puts "... :#{name} failed."
        return nil
      end

      start_pos = @interpreter.parsing_pos
      loop do
        new_result = try_rules(lr=true, result)

        if new_result.nil?
          puts "... :#{name} succeeded."

#          pos = @interpreter.parsing_pos
#          if @interpreter.cache[start_pos]?.nil?
#            @interpreter.cache[start_pos] = \
#              Hash(Symbol, Tuple(TryRulesResult, Int32)).new
#          end
#          @interpreter.cache[start_pos][@name] = \
#            Tuple(TryRulesResult, Int32).new(result, pos - start_pos)

          return result 
        else
          result = new_result
        end
      end
    end

    private def try_patterns(rule, rule_result, lr) : TryRulesResult?
      start_pos = @interpreter.parsing_pos

      # iterate over rule symbols, eg [:NAME, :EQ, :expr]
      rule.pattern.each do |sym|
        sym_s = sym.to_s
        matched_rule = false

        # sym is token name
        if sym_s == sym_s.upcase  # token
          new_tok = @interpreter.expect(sym, @ignores, @noignores)

          unless new_tok.nil?
            # MATCH
            rule_result[0] << new_tok  # tok
            puts "Token-match :#{sym} in #{rule.pattern}"
            matched_rule = true
          end
        else
          puts !(@interpreter.cache[@interpreter.parsing_pos]?.nil?)
          puts (!((tmp = @interpreter.cache[@interpreter.parsing_pos]?).nil?) \
            && !((_ = tmp[sym]?).nil?))
          puts @interpreter.parsing_pos
          puts sym
          pp @interpreter.cache
          if (\
              !((cache_section = \
                @interpreter.cache[@interpreter.parsing_pos]?).nil?)\
              && !((cache_result = cache_section[sym]?).nil?))

            puts "Recovered :#{sym} from cache."
            cache_node = cache_result[0]
            cache_offset = cache_result[1]

            puts cache_offset

            # FIXME: delete all before and up to offset
            @interpreter.parsing_pos += cache_offset

            rule_result[0].concat(cache_node[0])  # tok
            rule_result[1].concat(cache_node[1])  # node

            puts "Cache-match :#{sym} in #{rule.pattern}"
            matched_rule = true
          # sym is group name
          elsif !((group = @interpreter.groups[sym]).nil?)
            pre_pos = @interpreter.parsing_pos
            new_result = group.parse
            unless new_result.nil?
              # MATCH
              rule_result[0].concat(new_result[0])  # tok
              rule_result[1].concat(new_result[1])  # node

              len = @interpreter.parsing_pos - pre_pos
              puts "Saving :#{sym} to #{pre_pos} with len of #{len}"

              if @interpreter.cache[pre_pos]?.nil?
                @interpreter.cache[pre_pos] = \
                  Hash(Symbol, Tuple(TryRulesResult, Int32)).new
              end
              @interpreter.cache[pre_pos][sym] = \
                Tuple(TryRulesResult, Int32).new(\
                  new_result, 
                  len)

              puts "Group-match :#{sym} in #{rule.pattern}"
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
        lr : Bool = false,
        pre_result : TryRulesResult? = nil) : TryRulesResult?

      start_pos = @interpreter.parsing_pos

      rules = (lr ? @lr_rules : @rules)
      rules.each do |rule|
        rule_result = pre_result.nil? ? \
          TryRulesResult.new([] of MatchedToken, [] of Node::Node) \
          : TryRulesResult.new(*pre_result)
        
        rule_result = try_patterns(
          rule, 
          rule_result, lr)

        if rule_result.nil? \
            || (rule_result[0].size() == 0 && rule_result[1].size() == 0)
          # did not match anything, reset start
          @interpreter.parsing_pos = start_pos
        else
          block = rule.block
          unless block.nil?
            #pp "executing block for rule #{rule} ..."
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
                [] of Node::Node)
          end
        end
      end

      return nil
    end
  end


  class Interpreter
    include Tokenizer

    @root : Group? = nil
    @tokens = Hash(Symbol, Token).new
    @groups = Hash(Symbol, Group).new
    getter tokens, groups

    @parsing_pos = 0
    property parsing_pos

    @parsing_tokens = Array(MatchedToken).new
    getter parsing_tokens

    #@cache = Hash(
    #  Tuple(
    #    Symbol,          # ident
    #    Int32            # start_i
    #  ),                 #
    #  Tuple(             # 
    #    Node::Node,      # content
    #    Int32            # end_i
    #  )).new
    @cache = Hash(
      Int32,               # start_i
      Hash(                #
        Symbol,            # ident
        Tuple(             # 
          TryRulesResult,  # content
          Int32            # end offset
        )
      )).new
    getter cache

    def self.new(&block)
      instance = Interpreter.new
      with instance yield

      # TODO: error check that root is not nil.

      instance
    end

    private def token(name : Symbol, pattern : Regex)
      @tokens[name] = Token.new(name, Regex.new("\\A" + pattern.source))
    end

    private def root(&block)
      raise Error::Internal.new("root already defined") unless @root.nil?
      
      root_inst = Group.new(self, :root)
      with root_inst yield

      @root = root_inst
      #@groups[root_inst.name] = root_inst
    end

    private def group(name : Symbol, &block)
      group_instance = Group.new(self, name)
      with group_instance yield
      @groups[name] = group_instance
    end

    private def ignore(pattern : Symbol)
      @ignore << pattern
    end

    private def ignore(*patterns : Symbol)
      @ignore.concat(patterns)
    end

    def parse(@parsing_tokens : Array(MatchedToken)) \
        : Tuple(Array(MatchedToken), Array(Node::Node))?
      @parsing_pos = 0
      @cache.clear()

      root = @root
      if root.nil?
        raise Error::Internal.new("Undefined root.")
      else
        result = root.parse

        # TODO: verify that every token was consumed
        pos = @parsing_pos
        if @parsing_tokens.size > pos+1
          raise Error::Internal.new( \
            "Unconsumed tokens (#{@parsing_tokens.size-pos}" \
            "/#{@parsing_tokens.size}):\n" +
            @parsing_tokens[pos..].join("\n"))
        end

        @parsing_tokens.clear
        @parsing_pos = 0

        return result
      end
    end

    def should_ignore?(name : Symbol,
                       ignores : Array(Symbol),
                       noignores : Array(Symbol)? = nil) \
                       : Bool
      root = @root
      raise Error::Internal.new("root should not be nil") if root.nil?
      
      final_ignores = Array(Symbol).new
      
      if noignores.nil?
        final_ignores.concat(root.ignores)
      else
        if noignores.size > 0
          root.ignores.each { |ig_sym|
            next if noignores.includes?(ig_sym)
            final_ignores << ig_sym 
          }
        end
      end
      final_ignores.concat(ignores)

      final_ignores.each { |ig_sym|
        return true if name == ig_sym
      }
      return false
    end

    def next_token(ignores : Array(Symbol),
                   noignores : Array(Symbol)? = nil) \
                   : MatchedToken?
      loop do
        pos = @parsing_pos
        @parsing_pos += 1

        @cache.delete(pos-1)

        if @parsing_tokens.size <= pos #< pos+1
          return nil
        else
          tok = @parsing_tokens[pos]
          return tok unless should_ignore?(tok.name, ignores, noignores)
        end
      end
      return nil
    end

    def expect(expected_token_name : Symbol,
               ignores : Array(Symbol) = Array(Symbol).new,
               noignores : Array(Symbol)? = nil) \
               : MatchedToken?
      tok = next_token(ignores, noignores)
      return tok unless tok.nil? || expected_token_name != tok.name
      return nil
    end
  end
end
