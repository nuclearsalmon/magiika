module Magiika
  class Ast::DefineClass < AstBase
    def initialize(
        @name : ::String,
        @abstract : ::Bool,
        @info_stmts : Array(Ast),
        @body_stmts : Array(Ast),
        position : Position?)
      super(position)
    end

    private record ClassInfo, 
      extends_cls : Object::Class? = nil

    private def process_info_stmts(defining_scope : Scope) : ClassInfo
      extends_cls = nil

      @info_stmts.each { |stmt|
        case stmt
        when Ast::ExtendsStmt
          extends_cls_name = stmt.as(Ast::ExtendsStmt).name
          extends_cls_tmp = defining_scope.retrieve(extends_cls_name).value

          extends_cls_tmp.is_of!(
            Object::Class, 
            "Cannot extend a non-class type. Extending an instance is also not allowed."
          )
          extends_cls = extends_cls_tmp.as(Object::Class)
        else
          raise Error::NotImplemented.new("Unsupported info statement: #{stmt.class}")
        end
      }

      ClassInfo.new(extends_cls)
    end

    def eval(scope : Scope) : AnyObject
      # process info statements
      cls_info = process_info_stmts(scope)
    
      # build class
      cls = Object::Class.new(  
        @name,
        @abstract,
        scope,
        @body_stmts,
        cls_info.extends_cls,
        self.position?)

      # create reference to class
      scope.define(@name, cls)
      
      return cls
    end

    def eval_bool(scope : Scope) : ::Bool
      eval(scope).eval_bool(scope)
    end
  end
end
