module Magiika::Syntax
  protected def register_define_var
    group :_define_var do
      ignore :NEWLINE

      rule :any_def, :ASSIGN, :cond do |context|
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
          true,
          name,
          value,
          type,
          Access::Public)
        context.become(node)
      end
    end

    group :instance_define_var do
      rule :DOT, :_define_var do |context|
        context.become(:_define_var)
      end
    end

    group :static_define_var do
      rule :COLON, :_define_var do |context|
        context.become(:_define_var)
      end
    end
  end
end
