module Magiika
  class Object::ClassInstance < Magiika::Instance
    # note: don't run constructor in initialize,
    #  it shall be a separate function. this lets us initialize
    #  fields before calling the constructor, including in the parent class instance.

    delegate superclass, to: @type
    delegate type_name, to: @type
    delegate is_of?, to: @type

    getter extended_instance : self? = nil

    protected def initialize(
      type : Magiika::Object::Class,
      position : Position? = nil,
    )
      super(type, position)

      # create instance of extended class
      unless (extended_cls = type.extended_cls).nil?
        @extended_instance = extended_cls.create_instance(position: position)
      end

      # Initialize instance scopes
      type.instance_stmts.each { |stmt| stmt.eval(@scope) }
    end

    def run_constructor(args : Array(Object::Argument), arg_scope : Scope) : ::Nil
      # retrieve constructor method
      init_fn = @type.static_scope.retrieve?("init")

      unless init_fn.nil?
        Util.is_a!(init_fn, Object::FunctionInstance)

        # run constructor
        init_fn = init_fn.as(Object::FunctionInstance)
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

    def []?(name : ::String) : Object?
      info = @scope.get?(name)
      info = @type.scope.get?(name) if info.nil?
      return info.as(Object::Slot).try(&.value)
    end

    def to_s_internal : ::String
      "cls #{self.type_name}()"
    end

    def type_name : ::String
      "Cls::#{self.type_name}()"
    end
  end
end
