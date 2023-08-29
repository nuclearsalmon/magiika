require "./position.cr"
require "./token.cr"
require "./tokenizer.cr"
require "./group.cr"
require "../node/base.cr"
require "../node/type/**"
require "../node/stmt/**"
require "../scope/MODULE.cr"


module Magiika::Lang
  class Parser
    include Tokenizer

    @root : Group
    @groups : Hash(Symbol, Group)
    @tokens : Hash(Symbol, Token)
    getter groups, tokens

    @parsing_pos = 0
    property parsing_pos

    @parsing_tokens = Array(MatchedToken).new
    getter parsing_tokens

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

    def initialize(@root : Group,
                   @groups : Hash(Symbol, Group),
                   @tokens : Hash(Symbol, Token))
    end

    def parse(@parsing_tokens : Array(MatchedToken)) \
        : Tuple(Array(MatchedToken), Array(Node::Node))?
      @parsing_pos = 0
      @cache.clear()

      root = @root
      if root.nil?
        raise Error::Internal.new("Undefined root.")
      else
        result = root.parse(self)

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

  class Parser::Builder
    private macro type(obj, typ)
      raise Error::InternalType.new unless {{obj}}.is_a?({{typ}})
    end

    @root : Group? = nil
    @groups = Hash(Symbol, Group).new
    @tokens = Hash(Symbol, Token).new

    def self.new(&)
      instance = self.class.new
      with instance yield instance
      instance
    end

    def build : Parser
      root = @root
      raise Error::Internal.new("Undefined root") if root.nil?
      
      return Parser.new(root, @groups, @tokens)
    end

    private def token(name : Symbol, pattern : Regex)
      @tokens[name] = Token.new(name, Regex.new("\\A" + pattern.source))
    end

    private def root(&)
      raise Error::Internal.new("root already defined") unless @root.nil?
      
      builder = Group::Builder.new(:root)
      with builder yield
      @root = builder.build
    end

    private def group(name : Symbol, &)
      builder = Group::Builder.new(name)
      with builder yield
      @groups[name] = builder.build
    end
  end
end
