module Magiika::Syntax
  define_syntax do
    group :literal do
      rule :FLT do |context|
        token = context.token

        node = Ast::LateNative.new(token.position) do |scope|
          type = scope.definition(Object::Flt)
          
          type.create_instance(
            value: token.value.to_f32,
            position: token.position)
        end

        context.become(node)
      end

      rule :INT do |context|
        token = context.token

        node = Ast::LateNative.new(token.position) do |scope|
          type = scope.definition(Object::Int)
          
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

        node = Ast::LateNative.new(token.position) do |scope|
          type = scope.definition(Object::Bool)

          type.create_instance(
            value: bool_value,
            position: token.position)
        end
        
        context.become(node)
      end

      rule :STR do |context|
        token = context.token

        node = Ast::LateNative.new(token.position) do |scope|
          type = scope.definition(Object::Str)

          type.create_instance(
            value: token.value,
            position: token.position
          )
        end

        context.become(node)
      end
    end
  end
end
