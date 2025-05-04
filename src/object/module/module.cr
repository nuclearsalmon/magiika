class Magiika::Object::ModuleType < Type
  getter name : ::String
  getter defining_scope : Scope
  getter statements : Array(Ast)

  def initialize(
    @name : ::String,
    @defining_scope : Scope,
    @statements : Array(Ast),
    global_scope : Scope,
    position : Position? = nil,
  )
    super(global_scope: global_scope, position: position)

    if !(Util.upcase?(@name[0]))
      raise Error::NamingConvention.new(
        "Module names must start with an uppercase character.")
    end

    init_statements
  end

  private def init_statements : ::Nil
    @statements.each { |stmt|
      case stmt
      when Ast::DefineFunction
        stmt.eval(@scope)
      when Ast::DefineVariable
        stmt.eval(@scope)
      when Ast::DefineClass, Ast::DefineModule
        stmt.eval(@scope)
      else
        raise Error::Syntax.new(
          "Invalid statement in module body: #{stmt.class}")
      end
    }
  end

  # Modules cannot be instantiated
  protected def create_instance(**args) : Instance
    raise Error::Type.new("Cannot create instance of a module.")
  end

  def to_s_internal : ::String
    "module #{@name}"
  end
end
