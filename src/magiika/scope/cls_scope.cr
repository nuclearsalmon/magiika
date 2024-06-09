require "./nested_scope.cr"


module Magiika
  class Scope::Cls < Scope::Nested
    # overriding get? to handle visibility
    def get?(
        ident : String,
        visibility : Visibility = Visibility::Public) : Node::Meta?
      meta = find_variable_in_scope(ident, visibility)
      return meta unless meta.nil?

      # Delegate to parent scope if not found
      if @parent.is_a?(Scope::Cls)
        return @parent.as(Scope::Cls).get(ident, visibility)
      else
        return @parent.get(ident)
      end

      nil
    end

    # overriding get to handle visibility
    def get(
        ident : String,
        visibility : Visibility = Visibility::Public) : Node::Meta
      meta = get?(ident, visibility)
      return meta unless meta.nil?

      if !(find_variable_in_scope(ident, Visibility::Private).nil?)
        raise Error::Lazy.new("#{ident} is not accessible from #{visibility}.")
      end

      if @parent.is_a?(Scope::Cls)
        @parent.as(Scope::Cls).get(ident, Visibility::Private)
      end

      raise Error::UndefinedVariable.new(ident, self)
    end

    def set(
        ident : String,
        value : Psuedo::TypeNode,
        visibility : Visibility = Visibility::Public) : Nil
      meta = Node::Meta.new(value, nil, nil, visibility)
      set(ident, meta)
    end

    private def find_variable_in_scope(
        ident : String,
        visibility : Visibility) : Node::Meta?
      meta = @variables[ident]?
      return nil unless meta

      # Check visibility and static status
      return nil unless visibility_permitted?(meta.visibility, visibility)
      meta
    end

    private def visibility_permitted?(
        member_visibility : Visibility,
        requested_visibility : Visibility) : ::Bool
      case requested_visibility
      when Visibility::Public
        member_visibility == Visibility::Public
      when Visibility::Protected
        member_visibility != Visibility::Private
      when Visibility::Private
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
