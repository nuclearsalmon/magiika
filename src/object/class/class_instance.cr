module Magiika
  class Object::ClassInstance < Instance
    # note: don't run constructor in initialize,
    #  it shall be a separate function. this lets us initialize
    #  fields before calling the constructor, including in the parent class instance.

    delegate name, to: @cls
    delegate superclass, to: @cls
    delegate type_name, to: @cls
    delegate is_of?, to: @cls

    getter extended_instance : self? = nil

    def initialize(
      @cls : Class,
      position : Position? = nil,
    )
      super(cls: @cls, position: position)

      # create instance of extended class
      unless (extended_cls = @cls.extended_cls).nil?
        @extended_instance = extended_cls.create_instance(position: position)
      end

      # Initialize instance scopes
      @cls.instance_stmts.each { |stmt| stmt.eval(@scope) }
    end

    def run_constructor(args : Array(Object::Argument), arg_scope : Scope) : ::Nil
      # retrieve constructor method
      init_fn = @cls.scope.retrieve?("init")

      unless init_fn.nil?
        Util.is_a!(init_fn, Object::Function)

        # run constructor
        init_fn = init_fn.as(Object::Function)
        init_fn.call_safe_raise(args, arg_scope)
      end

      # check that all fields are initialized
      check_all_initialized
    end

    private def check_all_initialized : ::Nil
      @scope.seek { |scope|
        scope.each_slot { |name, slot|
          if !slot.nilable? && slot.value.is_a?(Object::Nil)
            raise Error::Lazy.new("`#{name}` was not initialized in `#{scope.name}`.")
          end
        }
        nil
      }
    end

    def eval(scope : Scope) : self
      self
    end

    def []?(name : ::String) : AnyObject?
      info = @scope.get?(name)
      info = @cls.scope.get?(name) if info.nil?
      return info.as(Object::Slot).try(&.value)
    end

    def to_s_internal : ::String
      "cls #{self.name}()"
    end

    def type_name : ::String
      "Cls::#{self.name}()"
    end
  end
end
