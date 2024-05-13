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

    def initialize(
        @root : Group,
        @groups : Hash(Symbol, Group),
        @tokens : Hash(Symbol, Token))
      validate_group_rules
    end

    def parse(@parsing_tokens : Array(MatchedToken)) : NodeObj
      # clear before parsing
      @parsing_position = 0
      @cache.clear()

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
      if position < @parsing_tokens.size
        raise Error::SafeParsingError.new( \
          "Unconsumed tokens (#{@parsing_tokens.size-position}" \
          "/#{@parsing_tokens.size}):\n" +
          @parsing_tokens[position..].map(&.to_s).join("\n"))
      end

      return result_node
    end

    private def resolve_ignores(
        ignores : Array(Symbol)? = nil,
        noignores : Array(Symbol)? = nil) : Array(Symbol)
      root = @root
      raise Error::Internal.new("root should not be nil") if root.nil?

      final_ignores = Array(Symbol).new
      root_ignores = root.ignores

      if noignores.nil?
        final_ignores.concat(root_ignores) unless root_ignores.nil?
      elsif noignores.size > 0
        unless root_ignores.nil?
          root_ignores.each { |ig_sym|
            next if !(noignores.nil?) && noignores.includes?(ig_sym)
            final_ignores << ig_sym
          }
        end
      end
      final_ignores.concat(ignores) unless ignores.nil?

      return final_ignores
    end

    private def next_token(
        ignores : Array(Symbol)? = nil,
        noignores : Array(Symbol)? = nil) : MatchedToken?
      resolved_ignores = resolve_ignores(ignores, noignores)
      loop do
        position = @parsing_position
        @parsing_position += 1

        #@cache.delete(position-1)

        tok = @parsing_tokens[position]?
        return tok if tok.nil? || !(resolved_ignores.includes?(tok._type))
      end
      return nil
    end

    def expect(
        expected_token_type : Symbol,
        ignores : Array(Symbol)? = nil,
        noignores : Array(Symbol)? = nil) : MatchedToken?
      tok = next_token(ignores, noignores)

      return tok if tok.nil? || tok._type == expected_token_type
      return nil
    end
  end
end
