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

    private alias TryRulesResult \
      = Tuple(Array(MatchedToken), Array(Node::Node))

    def parse : TryRulesResult?
      rule_result = try_rules(lr=false)
      puts "[1.A] '#{@name}': '#{rule_result}'"
      return nil if rule_result.nil?

      loop do
        result = try_rules(lr=true, rule_result)
        puts "[1.B] '#{@name}': '#{result}'"

        return rule_result if result.nil?
        rule_result = result
        puts "[1.C] '#{@name}': next ..."
      end
    end

    private def try_rules(
        lr : Bool = false,
        pre_result : TryRulesResult? = nil) : TryRulesResult?
      rule_result = nil

      start_pos = @interpreter.parsing_pos

      rules = (lr ? @lr_rules : @rules)
      rules.each do |rule|
        result = pre_result.nil? ? \
            TryRulesResult.new([] of MatchedToken, [] of Node::Node) \
          : TryRulesResult.new(*pre_result)

        # iterate over rule symbols, eg [:NAME, :EQ, :expr]
        rule.pattern.each_with_index do |sym, idx|
          sym_s = sym.to_s

          # sym is token name
          if sym_s == sym_s.upcase  # token
            new_tok = @interpreter.expect(sym, @ignores, @noignores)
            unless new_tok.nil?
              # MATCH
              result[0] << new_tok
              puts "[2.A] match for rule #{rule}"
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
              puts "[2.B] match for rule #{rule}"
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
            block_result = [block_result] unless block_result.is_a?(Array)
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
    @tokens = Hash(Symbol, Token).new
    @groups = Hash(Symbol, Group).new

    @parsing_pos = 0
    @parsing_tokens = Array(MatchedToken).new

    getter tokens, groups
    property parsing_pos
    getter parsing_tokens, parsing_expected

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
