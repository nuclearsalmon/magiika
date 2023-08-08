require "./position.cr"
require "./token.cr"
require "../node/base.cr"
require "../node/type/__init__.cr"
require "../node/stmt/assign.cr"
require "../node/stmt/retrieve.cr"
require "../error.cr"
require "./tokenizer.cr"


module Magiika::Lang
  private class Group
    private alias RuleBlock = \
        Array(MatchedToken), \
        Array(Node::Node) \
      -> Node::Node

    private record Rule,
      pattern : Array(Symbol),
      block : RuleBlock?

    getter name

    @name : Symbol
    @rules = Array(Rule).new
    @lr_rules = Array(Rule).new

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

    # TODO: Move all methods that aren't meant to be called
    #  with yield to outside the data class. Move to module.

    private alias TryRulesResult \
      = Tuple(Array(MatchedToken), Array(Node::Node))

    def parse : TryRulesResult?
      rule_result = try_rules(lr=false)
      return nil if rule_result.nil?

      loop do
        result = try_rules(lr=true, rule_result)

        return rule_result if result.nil?
        rule_result = result
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
            new_tok = @interpreter.expect(sym)
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
            rule_result = \
              TryRulesResult.new(
                [] of MatchedToken,
                [block.call(*result)])
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
    @ignore = Array(Symbol).new

    @parsing_pos = 0
    @parsing_tokens = Array(MatchedToken).new
    #@parsing_expected = Array(Token).new

    getter tokens, groups
    property parsing_pos
    getter parsing_tokens, parsing_expected

    def self.new(&block)
      instance = Interpreter.new
      with instance yield

      # TODO: error check that root_sym is nil
      #  and root is not. error differently depending
      #  on whichever is the case.

      instance
    end

    private def token(name : Symbol, pattern : Regex)
      @tokens[name] = Token.new(name, Regex.new("\\A" + pattern.source))
    end

    private def root(name : Symbol)
      @root_sym = name
    end

    private def group(name : Symbol, &block)
      group_instance = Group.new(self, name)
      with group_instance yield
      @groups[name] = group_instance

      root_sym = @root_sym
      if !root_sym.nil? && group_instance.name == root_sym
        @root = group_instance
        @root_sym = nil
      end
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

      root = @root
      if root.nil?
        raise Error::Internal.new("Undefined root.")
      else
        result = root.parse

        # TODO: verify that every token was consumed
        pos = @parsing_pos
        if @parsing_tokens.size > pos+1
          raise Error::Internal.new("Unconsumed tokens:\n" + @parsing_tokens.join("\n"))
        end

        @parsing_tokens.clear
        @parsing_pos = 0

        return result
      end
    end

    def next_token : MatchedToken?
      loop do
        pos = @parsing_pos
        @parsing_pos += 1

        if @parsing_tokens.size <= pos #< pos+1
          return nil
        else
          tok = @parsing_tokens[pos]
          return tok unless @ignore.includes?(tok.name)
        end
      end
      return nil
    end

    def expect(expected_token_name : Symbol) : MatchedToken?
      tok = next_token
      return tok unless tok.nil? || expected_token_name != tok.name
      return nil
    end
  end
end
