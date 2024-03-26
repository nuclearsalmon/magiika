module Magiika::Lang::Syntax
  private def register_base
    root do
      ignore(:LINE_SEGMENT)
      ignore(:SPACE)

      rule(:stmts)
    end

    group(:stmts) do
      ignore(:NEWLINE)

      rule(:stmt, :stmts) do |context|
        stmt = context[:stmt].node
        stmts = context[:stmts].nodes

        context.clear
        context.add(:stmts, stmts)
        context.add(:stmts, stmt)
        nil
      end
      rule(:stmt)
    end

    group(:stmt) do
      rule(:cond)
    end

    group(:literal) do
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

        context.add(Node::Bool.new(bool_value, token.pos))
      end

      rule(:INT) do |context|
        token = context.token

        context.clear
        context.add(Node::Int.new(token.value.to_i32, token.pos))
      end

      rule(:FLT) do |context|
        token = context.token

        context.clear
        context.add(Node::Flt.new(token.value.to_f32, token.pos))
      end
    end

    group(:value) do
      rule(:literal)
      rule(:member_access)
      rule(:L_PAR, :cond, :R_PAR)
    end
  end
end
