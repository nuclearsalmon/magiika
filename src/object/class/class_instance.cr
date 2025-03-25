module Magiika
  class Object::ClassInstance < MetaObject
    include SubScopingFeat

    # note: don't run constructor in initialize,
    #  it shall be a separate function. this lets us initialize
    #  fields before calling the constructor, including in the parent class instance.

    delegate name, to: @cls
    delegate superclass, to: @cls
    delegate type_name, to: @cls
    delegate is_of?, to: @cls

    getter cls : Class
    getter extended_instance : self? = nil
    @scope : Scope = Scope.new(name: "temporary")

    def initialize(
      @cls : Class,
      position : Position? = nil,
    )
      super(@cls, position: position)

      # create instance of extended class
      unless (extended_cls = @cls.extended_cls).nil?
        @extended_instance = extended_cls.create_instance(position)
      end

      # create instance scope
      @scope, local_scope = create_instance_scope
      @cls.instance_stmts.each { |stmt| stmt.eval(local_scope) }
    end

    def run_constructor(args : Array(Object::Argument), arg_scope : Scope) : ::Nil
      # retrieve constructor method
      init_fn = @cls.scope.retrieve?("init")

      unless init_fn.nil?
        Util.is_a!(init_fn, Object::Function)

        # run constructor
        init_fn = init_fn.as(Object::Function)
        init_fn.call_safe_raise(args, arg_scope)

        # delete init functions
        delete_init_fns
      end

      # check if all initialized
      check_all_initialized
    end

    private def delete_init_fns : ::Nil
      @scope.seek { |scope|
        scope.delete("init")
        next nil # nil
      }
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

    def create_instance_scope : Tuple(Scope, Scope)
      @cls.create_instance_scope(self)
    end

    def eval(scope : Scope) : self
      self
    end

    def scope : Scope
      @scope
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
