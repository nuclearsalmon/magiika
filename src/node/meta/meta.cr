module Magiika
  # Metadata for a stored Node
  class Node::Meta < TypeNode
    getter value : TypeNode

    @resolved_type : TypeMeta? = nil
    @unresolved_type : EvalType? = nil

    property descriptors : Set(Node::Desc)?
    property access : Access

    def initialize(
        @value : TypeNode,
        @resolved_type : TypeMeta? = nil,
        @descriptors : Set(Node::Desc)? = nil,
        @access : Access = Access::Public)
      super(nil)
    end

    def initialize(
        @value : TypeNode,
        @unresolved_type : EvalType? = nil,
        @descriptors : Set(Node::Desc)? = nil,
        @access : Access = Access::Public)
      super(nil)
    end

    def type : EvalType?
      @resolved_type || @unresolved_type
    end

    def resolve_type(scope : Scope) : EvalType
      resolved_type = @resolved_type
      if resolved_type.nil?
        eval_type = @unresolved_type
        unless eval_type.nil?
          resolved_type = eval_type.eval_type(scope)
          @resolved_type = resolved_type
        end
      end
      return resolved_type
    end

    def set_value(value : TypeNode, scope : Scope) : ::Nil
      resolved_type = resolve_type(scope)
      if !resolved_type.nil? && !resolved_type.fits_type?(value)
        raise Error::Lazy.new("value #{value} does not fit type #{resolved_type}")
      end
      @value = value
    end

    def set_type(new_type : TypeMeta?, scope : Scope) : ::Nil
      current_type = resolve_type(scope)
      current_value = @value
      if !current_type.nil? && !new_type.fits_type?(current_value)
        raise Error::Lazy.new("type #{new_type} does not fit value #{current_value}")
      end
      @resolved_type = new_type
    end

    def magic? : ::Bool
      @resolved_type.nil? && @unresolved_type.nil?
    end

    def nilable? : ::Bool
      true
    end

    def const? : ::Bool
      false
      #descriptors = @descriptors
      #return false if descriptors.nil?
      #descriptors.any? { |descriptor| descriptor.is_a?(ConstConstraint) }
    end

    def eval(scope : Scope) : TypeNode
      value = @value.eval(scope)
      unresolved_type = @resolved_type
      unless unresolved_type.nil?
        resolved_type = unresolved_type.eval_type(scope)
        unless value.as(TypeNode).eval_type(scope).fits_type?(resolved_type)
          raise Error::Lazy.new("value #{value} does not fit type #{resolved_type}")
        end
      end
      value
    end
  end
end
