module Magiika
  class Ast::Chain < AstBase
    def initialize(@stmts : Array(Ast), position : Position? = nil)
      super(position)
    end

    private def extract_scope(obj : AnyObject) : Scope
      if obj.is_a?(SubScopingFeat)
        obj.scope
      else
        raise Error::Lazy.new("No scope for #{obj.pretty_inspect}")
      end
    end

    def eval(scope : Scope) : AnyObject
      with_obj = @stmts[0].eval(scope)
      with_obj = Object::Slot.unpack(with_obj)
      with_scope = extract_scope(with_obj)

      @stmts[1..].each_with_index(2) { |stmt, index|
        if stmt.is_a?(CallerEvalFeat)
          with_obj = stmt.caller_eval(with_scope, scope)
        else
          with_obj = stmt.eval(with_scope)
        end

        if index < @stmts.size
          with_obj = Object::Slot.unpack(with_obj)
          with_scope = extract_scope(with_obj)
        end
      }

      Object::Slot.unpack(with_obj)
    end
  end
end
