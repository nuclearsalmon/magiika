module Magiika
  class Node::DefCls < Node
    def initialize(
        @name : String,
        @abstract : ::Bool,
        @stmts : Array(Node),
        position : Position?)
      super(position)
    end

    private def process_stmts(defining_scope : Scope) : Tuple(Scope::Cls, Scope::Cls)
      cls_scope = Scope::Cls.new(
        name: @name,
        parent: defining_scope,
        position: @position)
      inst_scope_base = Scope::Cls.new(
        name: @name + "_inst",
        parent: defining_scope,
        position: @position)

      @stmts.each { |stmt|
        if stmt.is_a?(Node::DefFn)
          stmt = stmt.as(Node::DefFn)
          if stmt.name == "init"
            ret = stmt.returns
            if !ret.nil? && ret._type != self
              raise Error::Lazy.new("wrong type for constructor")
            end
          elsif !(stmt.static?)
            stmt.eval(inst_scope_base)
          else
            stmt.eval(cls_scope)
          end
        elsif stmt.is_a?(Node::DefineVar)
          stmt = stmt.as(Node::DefineVar)
          if stmt.static?
            stmt.eval(cls_scope)
          else
            stmt.eval(inst_scope_base)
          end
        else
          stmt.eval(cls_scope)
        end
      }

      return Tuple(Scope::Cls, Scope::Cls).new(cls_scope, inst_scope_base)
    end

    def eval(scope : Scope) : TypeNode
      # eval scope becomes defining scope
      cls_scope, inst_scope_base = process_stmts(scope)

      cls = Node::Cls.new(
        @name,
        @abstract,
        cls_scope,
        inst_scope_base,
        scope,
        self.position?)

      cls_scope.define("this", cls)
      scope.define(@name, cls)
      cls
    end

    def eval_bool(scope : Scope) : ::Bool
      eval(scope).eval_bool(scope)
    end
  end
end
