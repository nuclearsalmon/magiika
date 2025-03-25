module Magiika::Syntax
  define_syntax do
    group :fn_param do
      rule :any_def, :ASSIGN, :cond do |context|
        name = context[:any_def][:NAME].token.value
        _type_t = context[:any_def][:_TYPE]?.try(&.token)
        _type = (_type_t.nil? ?
          nil : Ast::Retrieve.new(_type_t.value, position: _type_t.position))

        value = context[:cond].node
        position = context.first_position

        node = Ast::Parameter.new(name, value, _type, position: position)
        context.become(node)
      end

      rule :any_def do |context|
        name = context[:any_def][:NAME].token.value
        _type_t = context[:any_def][:_TYPE]?.try(&.token)
        _type = (_type_t.nil? ?
          nil : Ast::Retrieve.new(_type_t.value, position: _type_t.position))

        position = context.first_position

        node = Ast::Parameter.new(name, Object::Nil.instance, _type, position: position)
        context.become(node)
      end
    end

    group :fn_parameters do
      ignore :SPACE

      rule :fn_param, :SEP, :fn_parameters do |context|
        context.drop(:SEP)
        context.flatten
      end
      rule :fn_param
    end

    group :_fn_parameters_block do
      ignore :NEWLINE

      rule :R_PAR

      rule :fn_parameters, :R_PAR do |context|
        context.become(:fn_parameters)
      end

      # error trap
      rule :fn_parameters do |context|
        position = context[:fn_parameters].nodes.last.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end
    end

    group :fn_parameters_block do
      ignore :NEWLINE

      rule :L_PAR, :_fn_parameters_block do |context|
        context.become(:_fn_parameters_block)
      end

      # error trap
      rule :L_PAR do |context|
        position = context.token.position
        position = position.clone(col: position.col + 1)
        raise Error::ExpectedCharacter.new("Expected \")\".", position)
      end
    end
  end
end
