require "./position.cr"
require "./token.cr"
require "../node/base.cr"
require "../node/type/__init__.cr"
require "../node/stmt/assign.cr"
require "../node/stmt/retrieve.cr"
require "../error.cr"
require "./tokenizer.cr"


module Magiika::Lang
  # TODO: add Rule class with type method to typecheck.

  private class Group
    private alias RuleBlock = \
        Array(MatchedToken), \
        Array(Node::Node) \
      -> Node::Node | Array(Node::Node)

    private record Rule,
      pattern : Array(Symbol),
      block : RuleBlock?

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

    protected def rule(pattern : Symbol)
      rule(Rule.new([pattern], nil))
    end

    protected def rule(*pattern : Symbol)
      rule(Rule.new(pattern.to_a, nil))
    end

    protected def rule(pattern : Symbol, &block : RuleBlock)
      rule(Rule.new([pattern], block))
    end

    protected def rule(*pattern : Symbol, &block : RuleBlock)
      rule(Rule.new(pattern.to_a, block))
    end

    protected def rule(pattern : Array(Symbol))
      rule(Rule.new(pattern.to_a, nil))
    end

    protected def rule(pattern : Array(Symbol), &block : RuleBlock)
      rule(Rule.new(pattern.to_a, block))
    end

    protected def rule(rule : Rule)
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
      @noignores = Array(Symbol).new if noignores.nil?
      @noignores << pattern
    end

    # TODO: Move all methods that aren't meant to be called
    #  with yield to outside the data class. Move to module.

    private alias TryRulesResult \
      = Tuple(Array(MatchedToken), Array(Node::Node))

    def parse : TryRulesResult?
      rule_result = try_rules(lr=false)
      puts "[A] '#{@name}': '#{rule_result}'"
      return nil if rule_result.nil?

      loop do
        result = try_rules(lr=true, rule_result)
        puts "[B] '#{@name}': '#{result}'"

        return rule_result if result.nil?
        rule_result = result
        puts "[C] '#{@name}': next ..."
      end
    end

    private def try_rules(
        lr : Bool = false,
        pre_result : TryRulesResult? = nil) : TryRulesResult?
      rule_result = nil

      start_pos = @interpreter.parsing_pos

      matches = (lr ? @lr_rules : @rules)
      matches.each do |rule|
        result = pre_result.nil? ? \
            TryRulesResult.new([] of MatchedToken, [] of Node::Node) \
          : TryRulesResult.new(*pre_result)

        #pp "trying rule #{rule} ..."

        # iterate over rule symbols, eg [:NAME, :EQ, :expr]
        rule.pattern.each_with_index do |sym, idx|
          sym_s = sym.to_s

          # sym is token name
          if sym_s == sym_s.upcase  # token
            new_tok = @interpreter.expect(sym, @ignores, @noignores)
            unless new_tok.nil?
              # MATCH
              result[0] << new_tok
              #pp "[A] match for rule #{rule}"
            else
              # NO MATCH
              result = nil
              break
            end
          # sym is group name
          elsif @interpreter.groups[sym]
            new_result = @interpreter.groups[sym].parse
            unless new_result.nil?
              # MATCH
              result[0].concat(new_result[0])
              result[1].concat(new_result[1])
              #pp "[B] match for rule #{rule}"
            else
              # NO MATCH
              result = nil
              break
            end
          # was group name, but did not find matching group
          else
            # NO MATCH
            result = nil
            break
          end
        end

        unless result.nil? \
            || (result[0].size() == 0 && result[1].size() == 0)
          block = rule.block
          unless block.nil?
            #pp "executing block for rule #{rule} ..."
            block_result = block.call(*result)
            block_result = [block_result] if block_result.is_a?(Node::Node)

            rule_result = \
              TryRulesResult.new(
                [] of MatchedToken,
                block_result)
          else
            rule_result = TryRulesResult.new(
              result[0].size() != 0 ? [result[0][0]] : [] of MatchedToken,
              result[1].size() != 0 ? [result[1][0]] : [] of Node::Node)
          end
          break
        else
          # did not match anything, reset start
          @interpreter.parsing_pos = start_pos
        end
      end

      return rule_result
    end
  end


  class Interpreter
    include Tokenizer

    @root : Group? = nil
    @root_sym : Symbol? = nil
    @tokens = Hash(Symbol, Token).new
    @groups = Hash(Symbol, Group).new

    @parsing_pos = 0
    @parsing_tokens = Array(MatchedToken).new

    @noignores: Bool = false

    getter tokens, groups
    property parsing_pos
    getter parsing_tokens

    def self.new(&block)
      instance = Interpreter.new
      with instance yield

      # TODO: error check that root_sym is nil
      #  and root is not. error differently depending
      #  on whichever is the case.

      instance
    end

    private def token(name : Symbol, pattern : Regex)
      if name.to_s != name.to_s.upcase
        raise Error::Internal.new("Bad syntax rule: Token '#{name}', " +
          "token symbols must be in uppercase.")
      end

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
      group_inst = Group.new(self, name)
      with group_inst yield
      @groups[name] = group_inst
    end

    def parse(@parsing_tokens : Array(MatchedToken)) \
        : Tuple(Array(MatchedToken), Array(Node::Node))?
      @parsing_pos = 0

      root = @root
      if root.nil?
        raise Error::Internal.new("Undefined root.")
      else
        result = root.parse

        print("parsed result: #{result}")

        # TODO: verify that every token was consumed
        pos = @parsing_pos
        if @parsing_tokens.size > pos+1
          raise Error::Internal.new(
            "Unconsumed tokens (#{@parsing_tokens.size-pos}" +
            "/#{@parsing_tokens.size}):\n" + 
            @parsing_tokens[pos..].join("\n"))
        end

        @parsing_tokens.clear
        @parsing_pos = 0

        return result
      end
    end

    private def should_ignore?(token : MatchedToken,
                               ignores : Array(Symbol),
                               noignores : Array(Symbol)?) \
                               : Bool
      root = @root
      raise Error::Internal.new("root should not be nil") if root.nil?

      final_ignores = Array(Symbol).new

      if !@noignores
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
      end

      puts "ignores: #{ignores}"
      puts "noignores: #{noignores}"
      puts "final ignores: #{final_ignores}"

      final_ignores.each { |ig_sym|
        return true if token.name == ig_sym
      }
      return false
    end

    private def next_token(ignores : Array(Symbol)? = nil,
                           noignores : Array(Symbol)? = nil) \
                           : MatchedToken?
      loop do
        @parsing_pos += 1

        if @parsing_pos >= @parsing_tokens.size #< pos+1
          return nil
        else
          token = @parsing_tokens[@parsing_pos]
          sh = should_ignore?(token, ignores, noignores)
          puts "should ignore '#{token}': '#{sh}'"
          return token unless sh
        end
      end
      return nil
    end

    def expect(expected_token_name : Symbol, 
               ignores : Array(Symbol)? = nil,
               noignores : Array(Symbol)? = nil) \
               : MatchedToken?
      while true
        tok = next_token(ignores, noignores)
        return nil if tok.nil?
        return tok if expected_token_name == tok.name
        return nil
      end
    end
  end
end
