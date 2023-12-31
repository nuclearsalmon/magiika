require "../group/group.cr"
require "../group/builder.cr"


module Magiika::Lang
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

    private def token(_type : Symbol, pattern : Regex)
      @tokens[_type] = Token.new(_type, Regex.new("\\A" + pattern.source))
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
