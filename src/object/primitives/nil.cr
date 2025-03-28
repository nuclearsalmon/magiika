module Magiika
  class Object::Nil < PrimitiveObject
    private def initialize
      super(nil)
    end

    def self.instance
      @@instance ||= new
    end

    def to_s : ::String
      type_name
    end

    def to_s_internal : ::String
      type_name
    end

    def self.to_s : ::String
      type_name
    end

    def self.to_s_internal : ::String
      type_name
    end

    def eval_bool(scope : Scope) : ::Bool
      return false
    end
  end
end
