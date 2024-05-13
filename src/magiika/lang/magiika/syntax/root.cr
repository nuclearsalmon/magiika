module Magiika::Lang::Syntax
  protected def register_root
    root do
      ignore(:LINE_SEGMENT)
      ignore(:SPACE)

      rule(:stmts)
    end

    group(:stmts) do
      ignore(:NEWLINE)

      rule(:stmt, :stmts) do |context|
        context.absorb(:stmt)
      end
      rule(:stmt)
    end

    group(:stmt) do
      rule(:cond)
      rule(:fn_def)
    end

    group(:literal) do
      rule(:FLT) do |context|
        token = context.token

        context.clear
        context.add(Node::Flt.new(token.value.to_f32, token.position))
      end

      rule(:INT) do |context|
        token = context.token

        context.clear
        context.add(Node::Int.new(token.value.to_i32, token.position))
      end

      rule(:BOOL) do |context|
        token = context.token

        context.clear

        bool_value : Bool
        case token.value
        when "true"
          bool_value = true
        when "false"
          bool_value = false
        else
          raise Error::Internal.new("Invalid bool value: \"#{token.value}\".")
        end

        context.add(Node::Bool.new(bool_value, token.position))
      end

      rule :STR do |context|
        token = context.token
        value = token.value
        pos = token.position

        context.clear
        context.add(Node::Str.new(value, pos))
      end
    end

    group(:value) do
      rule(:literal)
      rule(:fn_call)
      rule(:member_access)
      rule(:L_PAR, :cond, :R_PAR)
    end
  end
end
