module Magiika
  class Class < GenericType(ClassInstance)
    getter name : ::String
    getter? is_abstract : ::Bool
    
    def initialize(
      @name : ::String,
      @is_abstract : ::Bool,
      superclass : self? = nil,  # <-- limit to Class, not Type
      position : Position? = nil,
    )
      super(superclass: superclass, position: position)
      Checks.class_name(@name)
    end
    
    def object_name : ::String
      "#{@name}\{\}"
    end
    
    protected def define : ::Nil
      unless is_abstract?
        # TODO: verify no abstracts remain in scopes (incl. parent scopes),
        #  but surface level.
      end
    end
    
    def eval_ast(statements : Array(Ast)) : ::Nil
      stmts.each { |stmt|
        is_static = false
        case stmt
        when Ast::DefineFunction, Ast::DefineVariable
          is_static = stmt.static?
        when Ast::DefineClass
          is_static = true
        end
        
        stmt.eval(is_static ? static_scope : source_instance_scope)
      }
    end
  end
end
