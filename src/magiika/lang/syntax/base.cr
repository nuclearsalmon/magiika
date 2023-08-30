module Magiika::Lang::Syntax
  private def register_base
    root do
      ignore(:LINE_SEGMENT)
      ignore(:SPACE)

      rule(:stmts)
    end

    group(:stmts) do
      ignore(:NEWLINE)

      rule(:stmt, :stmts) do |_,(stmt,stmts)|
        type(stmts, Array)
        type(stmt, Node::Node)

        [stmt, *stmts]
      end
      rule(:stmt)
    end

    group(:stmt) do
      rule(:set_var)
      rule(:get_var)
    end

    group(:literal) do
      rule(:BOOL) do |(value),_|
        case value.value
        when "true"
          Magiika::Node::Bool.new(true, value.pos)
        when "false"
          Magiika::Node::Bool.new(false, value.pos)
        else
          raise Error::Internal.new("Invalid bool value: \"#{value.value}\".")
        end
      end

      rule(:INT) do |(value),_|
        Magiika::Node::Int.new(value.value.to_i32, value.pos)
      end

      rule(:FLT) do |(value),_|
        Magiika::Node::Flt.new(value.value.to_f32, value.pos)
      end
    end

    group(:value) do
      rule(:literal)
      rule(:member_access)
      rule(:L_PAR, :cond, :R_PAR)
    end
  end
end
