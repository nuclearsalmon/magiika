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

    @parsing_position : Int32 = 0
    property parsing_position

    @parsing_tokens = Array(MatchedToken).new

    alias CacheData = Tuple(Context, Int32)         # content, end offset
    private alias CacheContainer = Hash(Symbol, CacheData)  # identifier, data
    private alias Cache = Hash(Int32, CacheContainer)       # start index, container

    @parsing_group_cache = Cache.new

    def initialize(
        @root : Group,
        @groups : Hash(Symbol, Group),
        @tokens : Hash(Symbol, Token))
      validate_group_rules
    end

    def parse(@parsing_tokens : Array(MatchedToken)) : NodeObj
      # clear before parsing
      @parsing_position = 0
      @parsing_group_cache.clear()

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

    private def next_token(resolved_ignores : Array(Symbol)) : MatchedToken?
      loop do
        token = @parsing_tokens[@parsing_position]?
        @parsing_position += 1
        if token.nil? || !(resolved_ignores.includes?(token._type))
          return token
        end
      end
      return nil
    end

    def expect_token(
        ident : Symbol,
        ignores : Array(Symbol)? = nil,
        noignores : Array(Symbol)? = nil) : MatchedToken?
      computed_ignores = resolve_ignores(ignores, noignores)

      initial_parsing_position = @parsing_position
      token = next_token(computed_ignores)

      if token.nil? || token._type != ident
        @parsing_position = initial_parsing_position
        return nil
      end
      return token
    end

    private def expect_cache(sym : Symbol) : Context?
      cache_data = @parsing_group_cache[@parsing_position]?.try(&.[sym]?)
      return nil if cache_data.nil?

      cached_context, cached_token_length = cache_data
      @parsing_position += cached_token_length

      return cached_context.clone
    end

    private def save_to_cache(
        ident : Symbol,
        context : Context,
        start_position : Int32)
      number_of_tokens = @parsing_position - start_position
      cache_data = CacheData.new(context.clone, number_of_tokens)
      #(@parsing_group_cache[start_position] ||= CacheContainer.new)[ident] = cache_data
    end

    def expect_group(
        ident : Symbol,
        ignores : Array(Symbol)? = nil,
        noignores : Array(Symbol)? = nil) : Context?
      initial_parsing_position = @parsing_position
      computed_ignores = resolve_ignores(ignores, noignores)

      context = nil
      loop do
        # try the cache
        context = expect_cache(ident)
        break unless context.nil? # break if we got a result
        # try parsing
        before_parsing_position = @parsing_position
        context = @groups[ident].parse(self)
        if context.nil?
          # get the first token and check if it should be ignored
          token = @parsing_tokens[@parsing_position]?
          break if token.nil?
          break unless computed_ignores.includes?(token._type)
          @parsing_position += 1
        else
          save_to_cache(ident, context, before_parsing_position)
          break
        end
      end

      if context.nil?
        # reset position if there's no match
        @parsing_position = initial_parsing_position
      end

      return context
    end

    def not_enough_tokens?(min_amount : Int32) : Bool
      @parsing_tokens[@parsing_position ..].size < min_amount
    end

    def inspect_cache : String
      @parsing_group_cache.pretty_inspect
    end
  end
end
