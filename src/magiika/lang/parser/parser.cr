require "./tokenizer.cr"
require "./validator.cr"
require "./group/group.cr"
require "./misc/context.cr"


module Magiika::Lang
  class Parser
    include Tokenizer
    include ParserValidator

    @root : Group
    @groups : Hash(Symbol, Group)
    @tokens : Hash(Symbol, Token)
    getter groups, tokens

    @parsing_position = 0
    property parsing_position

    @parsing_tokens = Array(MatchedToken).new
    getter parsing_tokens

    @cache = Hash(
      Int32,                   # start index
      Hash(                    #
        Symbol,                # ident
        Tuple(                 #
          Context,             # content
          Int32                # end offset
        )
      )).new
    getter cache

    def initialize(@root : Group,
                   @groups : Hash(Symbol, Group),
                   @tokens : Hash(Symbol, Token))
      validate_group_rules
    end

    def parse(@parsing_tokens : Array(MatchedToken)) : NodeObj
      # parse
      result_context : Context?
      begin
        result_context = @root.parse(self)
      rescue ex
        raise Error::SevereParserError.new(self, ex)
      end

      if result_context.nil?
        raise Error::SafeParsingError.new(
          "Parsing failed to match anything.")
      end

      result_node : NodeObj = result_context.result

      # verify that every token was consumed
      position = @parsing_position
      if @parsing_tokens.size > position+1
        raise Error::SafeParsingError.new( \
          "Unconsumed tokens (#{@parsing_tokens.size-position}" \
          "/#{@parsing_tokens.size}):\n" +
          @parsing_tokens[position..].join("\n"))
      end

      # restore before return
      @parsing_position = 0
      @cache.clear()

      return result_node
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
        position = @parsing_position
        @parsing_position += 1

        #@cache.delete(position-1)

        if @parsing_tokens.size <= position
          return nil
        else
          tok = @parsing_tokens[position]
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
