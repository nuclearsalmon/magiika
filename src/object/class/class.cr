module Magiika
  class Object::Class < Type
    @name : ::String
    getter? is_abstract : ::Bool
    getter extended_cls : Object::Class?
    getter instance_stmts : Array(Ast) = Array(Ast).new

    def type_name : ::String
      @name
    end

    def initialize(
      @name : ::String,
      @is_abstract : ::Bool,
      defining_scope : Scope,
      statements : Array(Ast),
      @extended_cls : Object::Class? = nil,
      position : Position? = nil,
    )
      super(defining_scope: defining_scope, position: position)

      if !(Util.upcase?(@name[0]))
        raise Error::NamingConvention.new(
          "Class names must start with an uppercase character.")
      end

      @static_scope, local_scope = create_static_scope
      set_instance_base_scope_parent(@defining_scope)
      init_statements(statements, local_scope)
      check_no_abstracts unless is_abstract?
    end

    def create_instance(
      *args, 
      position : Position? = nil,
      **kwargs
    ) : ClassInstance
      if is_abstract?
        raise Error::Lazy.new("Cannot instantiate abstract class `#{@name}`.")
      end
      
      ClassInstance.new(
        type: self,
        position: position
      )
    end

    private def check_no_abstracts : ::Nil
      # build simulated instance scope (instance_stmts already eval'd in ClassInstance#initialize)
      inst = create_instance()
      simulated_inst_scope = inst.scope

      scopes = [@static_scope, simulated_inst_scope]
      scopes.each { |scope|
        filter = Set(Object.class).new \
          .tap(&.add(Object::AbstractFunction))
        slots = scope.surface_slots(filter)
        name = slots.first_key?
        raise Error::Lazy.new(
          "Abstract method `#{name}` not implemented in class `#{@name}`."
        ) unless name.nil?
      }
    end

    private def init_statements(stmts : Array(Ast), local_scope : Scope) : ::Nil
      # sort and eval statements
      stmts.each { |stmt|
        case stmt
        when Ast::DefineFunction
          if stmt.abstract? && !is_abstract?
            raise Error::Lazy.new(
              "Abstract method #{stmt.name} not implemented in class #{@name}.")
          end
          if stmt.static?
            stmt.eval(local_scope)
            next
          end
        when Ast::DefineVariable
          if stmt.static?
            stmt.eval(local_scope)
            next
          end
        when Ast::DefineClass
          stmt.eval(local_scope)
          next
        end
        @instance_stmts << stmt
      }
    end

    # returns a tuple of (static_scope, local_static_scope)
    private def create_static_scope : Tuple(Scope, Scope)
      static_scope : Scope
      local_static_scope : Scope

      if (extends_cls = @extended_cls).nil?
        static_scope = Scope.new(@name, @position)
      else
        extends_static_scope = extends_cls.static_scope
        static_scope = Scope.new(@name, @position, extends_static_scope)

        static_scope.define("superclass", extends_cls)
      end

      # Define 'this' as the class itself in the static scope
      static_scope.define(THIS_NAME, Object::Slot.new(
        value: self,
        defining_scope: static_scope,
        final: true
      ))

      # Now create local_static_scope with 'this' already defined
      if (extends_cls = @extended_cls).nil?
        immediate_defining_scope = @defining_scope.dup(parent: nil)
        local_static_scope = static_scope.dup(parent: immediate_defining_scope)
      else
        extends_static_scope = extends_cls.static_scope
        injected_defining_scope = @defining_scope.dup(parent: extends_static_scope)
        local_static_scope = static_scope.dup(parent: injected_defining_scope)
      end

      return {static_scope, local_static_scope}
    end

    def create_instance_scope(instance : Object::ClassInstance) : Tuple(Scope, Scope)
      ext_instance = instance.extended_instance
      parent_instance_scope = ext_instance \
        .try(&.cls.create_instance_scope(ext_instance.not_nil!)[0])
        .try(&.dup(parent: @static_scope)) || @static_scope  # reference static scope

      instance_scope = Scope.new(
        name: "#{@name}\##{self.type_id}",
        parent: parent_instance_scope,
        position: position)

      injected_defining_scope = @defining_scope.dup(parent: parent_instance_scope)
      local_instance_scope = instance_scope
      
      # Define 'self' as the instance in the instance scope
      instance_scope.define(SELF_NAME, Object::Slot.new(
        value: instance,
        defining_scope: instance_scope,
        final: true
      ))
      
      if (extended_cls = @extended_cls)
        instance_scope.define("superclass", extended_cls)
      end

      return {instance_scope, local_instance_scope}
    end

    def eval(scope : Scope) : self
      self
    end

    def to_s_internal : ::String
      "cls #{@name}"
    end

    def type_name : ::String
      "#{@name}"
    end

    def superclass : Object::Class?
      @extended_cls
    end

    def is_of?(other : ::Object) : ::Bool
      return true if super(other)
      @extended_cls.try(&.is_of?(other)) || false
    end
  end
end
