require "./tokenizer.cr"
require "./validator.cr"
require "../group/group.cr"


module Magiika::Lang
  class Parser
    include Tokenizer
    include ParserValidator

    @root : Group
    @groups : Hash(Symbol, Group)
    @tokens : Hash(Symbol, Token)
    getter groups, tokens

    @parsing_pos = 0
    property parsing_pos

    @parsing_tokens = Array(MatchedToken).new
    getter parsing_tokens

    @cache = Hash(
      Int32,               # start index
      Hash(                #
        Symbol,            # ident
        Tuple(             # 
          RuleContext,     # content
          Int32            # end offset
        )
      )).new
    getter cache

    def initialize(@root : Group,
                   @groups : Hash(Symbol, Group),
                   @tokens : Hash(Symbol, Token))
      validate_group_rules
    end

    def parse(@parsing_tokens : Array(MatchedToken)) : Node
      # setup
      @parsing_pos = 0
      @cache.clear()
      initial_context = RuleContext.new(:root)

      # parse
      result_context = @root.parse(self, initial_context)

      if result_context.nil?
        raise Error::Internal.new(
          "Parsing failed to match anything.")
      end

      result = result_context.result

      # verify that every token was consumed
      pos = @parsing_pos
      if @parsing_tokens.size > pos+1
        raise Error::Internal.new( \
          "Unconsumed tokens (#{@parsing_tokens.size-pos}" \
          "/#{@parsing_tokens.size}):\n" +
          @parsing_tokens[pos..].join("\n"))
      end
      
      # reset
      @parsing_tokens.clear
      @parsing_pos = 0

      return result
    end

    def should_ignore?(_type : Symbol,
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
        return true if _type == ig_sym
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
          return tok unless should_ignore?(tok._type, ignores, noignores)
        end
      end
      return nil
    end

    def expect(expected_token_type : Symbol,
               ignores : Array(Symbol) = Array(Symbol).new,
               noignores : Array(Symbol)? = nil) \
               : MatchedToken?
      tok = next_token(ignores, noignores)
      return tok unless tok.nil? || expected_token_type != tok._type
      return nil
    end
  end
end
