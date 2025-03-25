module Magiika
  class Ast::Chain < AstBase
    def initialize(@stmts : Array(Ast), position : Position? = nil)
      super(position)
    end

    private def extract_scope(node : AnyObject) : Scope
      if node.is_a?(SubScopingFeat)
        node.scope
      else
        raise Error::Lazy.new("No scope for #{node.pretty_inspect}")
      end
    end

    def eval(scope : Scope) : AnyObject
      with_node = @stmts[0].eval(scope)

      with_node = Object::Slot.unpack(with_node)
      with_scope = extract_scope(with_node)

      @stmts[1..].each_with_index(2) { |stmt, index|
        if stmt.is_a?(CallerEvalFeat)
          with_node = stmt.caller_eval(with_scope, scope)
        else
          with_node = stmt.eval(with_scope)
        end

        if index < @stmts.size
          with_node = Object::Slot.unpack(with_node)
          with_scope = extract_scope(with_node)
        end
      }

      Object::Slot.unpack(with_node)
    end
  end
end
