module Magiika
  # Typing-related metadata associated with a *TypeNode*.
  class TypeMeta
    include EvalType

    @id : Typing::TypeID
    @name : ::String
    @reference : TypeNode.class | InstTypeNode
    @superclass : TypeMeta?

    getter id : Typing::TypeID
    getter name : ::String
    getter reference : TypeNode.class | InstTypeNode

    def initialize(
        @id : Typing::TypeID,
        @name : ::String,
        @reference : TypeNode.class | InstTypeNode,
        superclass : ::Class)
      if superclass.is_a?(TypeNode) && !superclass.type_base?
        @superclass = superclass.type_meta
      else
        @superclass = nil
      end
    end

    def eval_type(scope : Scope) : TypeMeta
      self
    end

    def superclass? : TypeMeta?
      @superclass
    end

    def superclass : TypeMeta
      superclass? || raise Error::Lazy.new("Superclass is not defined")
    end

    def inherits_from_type?(other : TypeMeta) : ::Bool
      it_count = 0
      target : TypeMeta? = other.superclass?
      while !target.nil?
        return false if target.nil?
        return true if target.fits_exact_type?(self)

        it_count += 1
        target = target.superclass?
        if it_count > Magiika::INHERITANCE_LIMIT
          raise Error::Type.new(
            other,
            self,
            "Exceeded inheritance limit when looking up #{other}.")
        end
      end
      false
    end

    def inherits_from_type!(other : TypeMeta) : ::Nil
      if !inherits_from_type?(other)
        raise Error::Type.new(
          other,
          self,
          "Expected #{self} to inherit from #{other}")
      end
    end

    def fits_exact_type?(other : TypeMeta) : ::Bool
      self.id == other.id
    end

    def fits_exact_type!(other : TypeMeta) : ::Nil
      if !fits_exact_type?(other)
        raise Error::Type.new(other, self, "Expected exact type")
      end
    end

    def fits_type?(other : TypeMeta) : ::Bool
      if other.responds_to?(:type_metas)
        other.type_metas.each { |type_meta|
          return true if fits_type?(type_meta)
        }
        return false
      else
        return true if fits_exact_type?(other)
        return inherits_from_type?(other)
      end
    end

    def fits_type!(other : TypeMeta) : ::Nil
      if !fits_type?(other)
        raise Error::Type.new(other, self)
      end
    end

    def valid? : ::Bool
      Typing::TYPE_IDS.has_key?(self.id)
    end
  end
end
