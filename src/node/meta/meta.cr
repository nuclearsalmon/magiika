module Magiika
  # Metadata for a stored Node
  class Node::Meta < TypeNode
    @value : TypeNode
    getter value : TypeNode

    @_type : Typing::EvalsToType?
    getter type : Typing::EvalsToType?

    property descriptors : Set(Node::Desc)?
    property visibility : Visibility

    def initialize(
        @value : TypeNode,
        @_type : Typing::EvalsToType? = nil,
        @descriptors : Set(Node::Desc)? = nil,
        @visibility : Visibility = Visibility::Public)
      super(nil)
    end

    def value=(value : TypeNode)
      _type = @_type
      if !_type.nil? && !_type.fits_type?(value)
        raise Error::Lazy.new("value #{value} does not fit type #{_type}")
      end
      @value = value
    end

    def type=(_type : Typing::EvalsToType?)
      current_type = @_type
      current_value = @value
      if !current_type.nil? && !_type.fits_type?(current_value)
        raise Error::Lazy.new("type #{_type} does not fit value #{current_value}")
      end
      @_type = _type
    end

    def magic? : ::Bool
      @_type.nil?
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
      unresolved_type = @_type
      unless unresolved_type.nil?
        _type = unresolved_type.eval_type(scope)
        unless value.as(Typing::Type).fits_type?(_type)
          raise Error::Lazy.new("value #{value} does not fit type #{_type}")
        end
      end
      value
    end
  end
end
