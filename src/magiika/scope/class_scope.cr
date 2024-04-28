require "./nested_scope.cr"


module Magiika
  class Scope::ClassScope < Scope::NestedScope
    def set(
        ident : String,
        node : NodeObj,
        visibility : Visibility = Visibility::Private,
        is_static : Bool = false) : Nil
      meta = Node::Meta.new(node, nil, visibility, is_static)
      super(ident, meta)
    end

    # overriding get? to handle visibility and static members
    def get?(
        ident : String,
        request_visibility : Visibility = Visibility::Private,
        request_static : Bool = false) : Node::Meta?
      meta = find_variable_in_scope(ident, request_visibility, request_static)
      return meta unless meta.nil?

      # Delegate to parent scope if not found
      if parent.is_a?(ClassScope)
        return parent.as(ClassScope).get(ident, request_visibility, request_static)
      end

      nil
    end

    # overriding get to handle visibility, static members, and parent scope
    def get(
        ident : String,
        request_visibility : Visibility = Visibility::Private,
        request_static : Bool = false) : Node::Meta
      var = get?(ident, request_visibility, request_static)
      return var if var
      raise Error::Internal.new("Not found")
    end

    private def find_variable_in_scope(
        ident : String,
        request_visibility : Visibility,
        request_static : ::Bool) : Node::Meta?
      meta = @variables[ident]?
      return nil unless meta

      # Check visibility and static status
      return nil unless visibility_permitted?(meta.visibility, request_visibility)
      return nil if meta.static? != request_static

      meta
    end

    private def visibility_permitted?(
        member_visibility : Visibility,
        request_visibility : Visibility) : ::Bool
      case request_visibility
      when Visibility::Public
        member_visibility == Visibility::Public
      when Visibility::Protected
        member_visibility != Visibility::Private
      else
        true
      end
    end

    def clone(scope : Scope, position : Lang::Position) : ClassScope
      new_values = @variables.to_h { |key, value| {key, value.clone(scope, position)} }
      new_parent = @parent.is_a?(ClassScope) ? @parent.clone(scope, position) : @parent

      new_scope = ClassScope.new(@name, new_parent, position)
      new_values.each { |key, value| new_scope.set(key, value) }
      new_scope
    end
  end
end
