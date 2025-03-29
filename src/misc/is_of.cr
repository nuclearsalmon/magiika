module IsOf
  private macro recursive_inherited_is_of
    def self.crystal_type : ::Object.class
      {{ @type }}
    end

    def crystal_type : ::Object.class
      {{ @type }}
    end

    protected def self.reverse_is_of?(
      reverse_self : ::Object | ::Object.class
    ) : ::Bool
      reverse_self.is_a?({{ @type }})
    end
  
    def self.is_of?(other) : ::Bool
      other = other.class unless other.is_a?(::Object.class)
      other.reverse_is_of?(self)
    end
  
    def is_of?(other) : ::Bool
      other = other.class unless other.is_a?(::Object.class)
      other.reverse_is_of?(self)
    end

    macro inherited; recursive_inherited_is_of; end
  end

  macro included; recursive_inherited_is_of; end
end
