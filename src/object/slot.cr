module Magiika
  # A slot to store a Objects in and track its constraints.
  class Object::Slot < Object::TypeConstraint
    getter value : AnyObject
    getter? final : ::Bool
    getter access : Access
    
    def initialize(
      @value : AnyObject, 
      @final : ::Bool = false, 
      @access : Access = Access::Public,
      *args,
      **kwargs
    )
      super(*args, **kwargs)
    end

    def value=(value : AnyObject) : AnyObject
      value.is_of!(type) unless (type = self.type).nil?
      @value = value
    end

    def self.unpack(node : AnyObject) : AnyObject
      node.is_a?(Object::Slot) ? node.value : node
    end

    def eval(scope : Scope) : AnyObject
      @value
    end
  end
end
