module Magiika
  class Node::DefCls < NodeClass
    def initialize(
        @name : String,
        @abstract : ::Bool,
        @stmts : Array(Psuedo::Node),
        position : Position?)
      super(position)
    end

    private def process_stmts(scope : Scope) : Tuple(Scope::Cls, Scope::Cls)
      cls_scope = Scope::Cls.new(@name + "_cls", scope, @position)
      inst_scope_base = Scope::Cls.new(@name + "_inst", scope, @position)

      @stmts.each { |stmt|
        if (stmt.is_a?(Node::Fn))
          stmt_fn = stmt.as(Node::Fn)
          if stmt_fn.name == "init"
            ret = stmt_fn.returns
            if !ret.nil? && ret._type != self
              raise Error::Lazy.new("wrong type for constructor")
            end
          end
        end

        stmt.eval(cls_scope)
      }

      return Tuple(Scope::Cls, Scope::Cls).new(cls_scope, inst_scope_base)
    end

    def eval(scope : Scope) : Psuedo::TypeNode
      cls_scope, inst_scope_base = process_stmts(scope)

      cls = Node::Cls.new(
        @name,
        @abstract,
        cls_scope,
        inst_scope_base,
        self.position?)

      cls_scope.set("this", cls)
      scope.set(@name, cls)
      cls
    end

    def eval_bool(scope : Scope) : ::Bool
      eval(scope).eval_bool(scope)
    end
  end
end