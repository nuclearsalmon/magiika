module Magiika
  class Object::Class < MetaObject
    getter name : ::String
    getter? is_abstract : ::Bool
    getter defining_scope : Scope
    getter extended_cls : Object::Class?

    getter scope : Scope
    getter instance_stmts : Array(Ast) = Array(Ast).new

    def initialize(
      @name : ::String,
      @is_abstract : ::Bool,
      @defining_scope : Scope,
      statements : Array(Ast),
      @extends_cls : Object::Class? = nil,
      position : Position? = nil,
    )
      super(position: position)

      if !(Util.upcase?(@name[0]))
        raise Error::NamingConvention.new(
          "Class names must start with an uppercase character.")
      end

      @scope, local_scope = create_static_scope
      @scope.define(THIS_NAME, self)
      init_statements(statements, local_scope)
      check_no_abstracts unless is_abstract?
    end

    private def check_no_abstracts : ::Nil
      # build simulated instance scope
      simulated_inst_scope = create_instance().scope
      @instance_stmts.each { |stmt| stmt.eval(simulated_inst_scope) }

      scopes = [@scope, simulated_inst_scope]
      scopes.each { |scope|
        filter = Set(AnyObject).new\
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
          end
          next
        when Ast::DefineVariable
          if stmt.static?
            stmt.eval(local_scope)
          end
          next
        when Ast::DefineClass
          stmt.eval(local_scope)
          next
        end
        @instance_stmts << stmt
      }
    end

    def create_instance(position : Position? = nil) : Object::ClassInstance
      Object::ClassInstance.new(cls: self, position: position)
    end

    # returns a tuple of (static_scope, local_static_scope)
    private def create_static_scope : Tuple(Scope, Scope)
      static_scope : Scope
      local_static_scope : Scope

      if (extends_cls = @extends_cls).nil?
        static_scope = Scope.new(@name, @position)

        immediate_defining_scope = @defining_scope.dup(parent: nil)
        local_static_scope = static_scope.dup(parent: immediate_defining_scope)
      else
        extends_static_scope = extends_cls.scope
        static_scope = Scope.new(@name, @position, extends_static_scope)

        injected_defining_scope = @defining_scope.dup(parent: extends_static_scope)
        local_static_scope = static_scope.dup(parent: injected_defining_scope)

        static_scope.define("superclass", extends_cls)
      end

      return {static_scope, local_static_scope}
    end

    def create_instance_scope(instance : Object::ClassInstance) : Tuple(Scope, Scope)
      ext_instance = instance.extended_instance
      parent_instance_scope = ext_instance \
        .try(&.create_instance_scope[0])
        .try(&.dup(parent: @scope)) || @scope  # reference static scope

      instance_scope = Scope.new(
        name: "#{@name}\##{self.type_id}",
        parent: parent_instance_scope,
        position: position)

      injected_defining_scope = @defining_scope.dup(parent: parent_instance_scope)
      local_instance_scope = instance_scope.dup(parent: injected_defining_scope)

      instance_scope.define(THIS_NAME, self)
      if (extended_cls = @extended_cls)
        instance_scope.define("superclass", extended_cls)
      end
      instance_scope.define(SELF_NAME, instance)

      return {instance_scope, local_instance_scope}
    end

    def eval(scope : Scope) : self
      self
    end

    def to_s_internal : ::String
      "cls #{@name}"
    end

    def type_name : ::String
      "Class::#{@name}"
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
