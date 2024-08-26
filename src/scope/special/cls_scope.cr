module Magiika
  class Scope::Cls < Scope::Nested
    # overriding get? to handle access
    def get?(
        ident : String,
        access : Access = Access::Public) : Node::Meta?
      meta = find_variable_in_scope(ident, access)
      return meta unless meta.nil?

      # Delegate to parent scope if not found
      if @parent.is_a?(Scope::Cls)
        return @parent.as(Scope::Cls).get?(ident, access)
      else
        return @parent.get?(ident)
      end

      nil
    end

    # overriding get to handle access
    def get(
        ident : String,
        access : Access = Access::Public) : Node::Meta
      meta = get?(ident, access)
      return meta unless meta.nil?

      if !(find_variable_in_scope(ident, Access::Private).nil?)
        raise Error::Lazy.new("#{ident} is not accessible from #{access}.")
      end

      if @parent.is_a?(Scope::Cls)
        @parent.as(Scope::Cls).get(ident, Access::Private)
      end

      raise Error::UndefinedVariable.new(ident, self)
    end

    def set(
        ident : String,
        value : TypeNode,
        access : Access = Access::Public) : ::Nil
      meta = Node::Meta.new(value, nil, nil, access)
      super(ident, meta.as(Node::Meta))
    end

    private def find_variable_in_scope(
        ident : String,
        access : Access) : Node::Meta?
      meta = @variables[ident]?
      return nil unless meta

      # Check access and static status
      return nil unless access_permitted?(meta.access, access)
      meta
    end

    private def access_permitted?(
        member_access : Access,
        requested_access : Access) : ::Bool
      case requested_access
      when Access::Public
        member_access == Access::Public
      when Access::Protected
        member_access != Access::Private
      when Access::Private
        true
      else
        false
      end
    end

    def copy_with(
        name = @name,
        parent = @parent,
        variables = @variables,
        position = @position)
      self.class.new(name, parent, variables, position)
    end

    def clone(position : Position? = nil)
      self.class.new(
        @name.clone,
        @parent.clone,
        @variables.clone,
        position.nil? ? position : @position.try(&.clone))
    end
  end
end
