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
        stmt = context.node(:stmt)
        stmts = context.nodes(:stmts)
        
        #stmts = [stmt, *stmts]
        stmts << stmt

        context.clear
        context.update(:stmts, stmts)
        nil
      end
      rule(:stmt)
    end

    group(:stmt) do
      #rule(:member_set)
      rule(:cond)
    end

    group(:literal) do
      rule(:BOOL) do |context|
        value = context.token(:BOOL)
        case value.value
        when "true"
          Node::Bool.new(true, value.pos)
        when "false"
          Node::Bool.new(false, value.pos)
        else
          raise Error::Internal.new("Invalid bool value: \"#{value.value}\".")
        end
      end

      rule(:INT) do |context|
        value = context.token(:INT)
        Node::Int.new(value.value.to_i32, value.pos)
      end

      rule(:FLT) do |context|
        value = context.token(:FLT)
        Node::Flt.new(value.value.to_f32, value.pos)
      end
    end

    group(:value) do
      rule(:literal)
      rule(:member_access)
      rule(:L_PAR, :cond, :R_PAR)
    end
  end
end
