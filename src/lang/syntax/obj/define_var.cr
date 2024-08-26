module Magiika::Syntax
  protected def register_define_var
    group :_define_var do
      ignore :NEWLINE

      rule :any_def, :ASSIGN, :cond
    end

    group :instance_define_var do
      rule :ACCESS, :DOT, :_define_var do |context|
        access = get_access(context)

        context.become(:_define_var)

        define_var(context, false, access)
      end

      rule :DOT, :_define_var do |context|
        context.become(:_define_var)

        define_var(context, false)
      end
    end

    group :static_define_var do
      rule :COLON, :_define_var do |context|
        context.become(:_define_var)

        define_var(context, true)
      end

      rule :ACCESS, :COLON, :_define_var do |context|
        access = get_access(context)

        context.become(:_define_var)

        define_var(context, true, access)
      end
    end
  end

  private def get_access(context) : Access
    access_str = context[:ACCESS].token.value
    case access_str
    when "prot"
      return Access::Protected
    when "priv"
      return Access::Private
    else
      raise Error::Lazy.new("Unknown access string: #{access_str}")
    end
  end

  private def define_var(
      context,
      static : ::Bool,
      access : Access = Access::Public)
    type_t = context[:any_def][:_TYPE]?.try(&.token)
    type = type_t ?
      Node::Resolver.new(type_t.value, type_t.position) :
      nil

    name_t = context[:any_def][:NAME].token
    name = name_t.value

    value = context[:cond].node
    pos = name_t.position

    node = Node::DefineVar.new(
      pos,
      static,
      name,
      value,
      type,
      access)
    context.become(node)
  end
end
