module Magiika::Syntax
  define_syntax do
    group :literal do
      rule :FLT do |context|
        token = context.token

        node = Ast::Eval.new(token.position) do |scope|
          type = scope.definition(Type::Flt)

          type.create_instance(
            value: token.value.to_f32,
            position: token.position)
        end

        context.become(node)
      end

      rule :INT do |context|
        token = context.token

        node = Ast::Eval.new(token.position) do |scope|
          type = scope.definition(Type::Int)

          type.create_instance(
            value: token.value.to_i32,
            position: token.position)
        end
        context.become(node)
      end

      rule :BOOL do |context|
        token = context.token

        bool_value : ::Bool
        case token.value
        when "true"
          bool_value = true
        when "false"
          bool_value = false
        else
          raise Error::Internal.new("Invalid bool value: \"#{token.value}\".")
        end

        node = Ast::Eval.new(token.position) do |scope|
          type = scope.definition(Type::Bool)

          type.create_instance(
            value: bool_value,
            position: token.position)
        end

        context.become(node)
      end

      rule :STR do |context|
        token = context.token

        node = Ast::Eval.new(token.position) do |scope|
          type = scope.definition(Type::Str)

          type.create_instance(
            value: token.value,
            position: token.position
          )
        end

        context.become(node)
      end
    end

    group :list_elems do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :list_elems, :SEP, :cond do |context|
        context.absorb(:list_elems)
        context.drop(:SEP)
        context.absorb(:cond)
      end

      rule :cond
    end

    group :cash_inspect do
      rule :CASH, :L_PAR, :NAME, :R_PAR do |context|
        name = context[:NAME].token.value
        position = context[:CASH].token.position

        node = Ast::Eval.new(position) do |scope|
          scope.retrieve(name).tap { |x| puts x.type_name }
        end
        context.become(node)
      end
    end

    group :list_literal do
      rule :L_SQBRC, :list_elems, :R_SQBRC do |context|
        position = context[:L_SQBRC].token.position
        elem_nodes = context[:list_elems].nodes

        node = Ast::Eval.new(position) do |scope|
          type = scope.definition(Type::List)
          values = elem_nodes.map { |n| n.eval(scope) }
          type.create_instance(values, position: position)
        end

        context.become(node)
      end

      rule :L_SQBRC, :R_SQBRC do |context|
        position = context[:L_SQBRC].token.position

        node = Ast::Eval.new(position) do |scope|
          type = scope.definition(Type::List)
          type.create_instance([] of Object, position: position)
        end

        context.become(node)
      end
    end
  end
end
