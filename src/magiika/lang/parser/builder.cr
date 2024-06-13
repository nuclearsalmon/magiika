require "./group/group.cr"
require "./group/builder.cr"


module Magiika::Lang
  class Parser::Builder
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
      raise Error::Internal.new(
        "Undefined root"
      ) if root.nil?

      return Parser.new(root, @groups, @tokens)
    end

    private def token(
        name : Symbol,
        pattern : Regex,
        greedy : Bool = false) : Nil
      name_s = name.to_s

      raise Error::Internal.new(
        "name must be uppercase: #{name}"
      ) unless Util.upcase?(name_s)
      raise Error::Internal.new(
        "duplicate token: :#{name}"
      ) if @tokens[name]?

      @tokens[name] = Token.new(
        name,
        Regex.new("\\A" + pattern.source),
        greedy)
    end

    private def root(&) : Nil
      raise Error::Internal.new(
        "root already defined"
      ) unless @root.nil?

      builder = Group::Builder.new(:root)
      with builder yield
      @root = builder.build
    end

    private def group(name : Symbol, &) : Nil
      name_s = name.to_s

      raise Error::Internal.new(
        "name must be lowercase: #{name}"
      ) unless Util.downcase?(name_s)
      raise Error::Internal.new(
        "duplicate group: :#{name}"
      ) if @groups[name]?

      builder = Group::Builder.new(name)
      with builder yield
      @groups[name] = builder.build
    end
  end
end
