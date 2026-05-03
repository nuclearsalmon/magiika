module Magiika
  # NOTE: The only immediate extending classes for `Object` are
  # expected to be `Type` and `Instance`
  abstract class ObjectT
    include Positionable

    def initialize(@position : Position? = nil)
    end

    def eval(scope : Scope) : Object; self; end
    def eval_bool(scope : Scope) : ::Bool; true; end;

    abstract def object_name : ::String

    @[AlwaysInline]
    def to_s : ::String
      "<#{self.object_name}>"
    end

    @[AlwaysInline]
    def inspect : ::String
      self.to_s
    end

    def to_s(io : IO) : Nil
      io.write_string(self.to_s.to_slice)
    end

    def inspect(io : IO) : Nil
      io.write_string(self.to_s.to_slice)
    end
  end
end
