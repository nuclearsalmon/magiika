module Magiika::Syntax
  define_syntax do
    group :literal do
      rule :FLT do |context|
        token = context.token

        node = Object::Flt.new(token.value.to_f32, token.position)
        context.become(node)
      end

      rule :INT do |context|
        token = context.token

        node = Object::Int.new(token.value.to_i32, token.position)
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

        node = Object::Bool.new(bool_value, token.position)
        context.become(node)
      end

      rule :STR do |context|
        token = context.token

        node = Object::String.new(token.value, token.position)
        context.become(node)
      end
    end
  end
end
