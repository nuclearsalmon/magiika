module Magiika::Lang::Syntax
  protected def register_variables
    group(:set_var) do
      rule(:DEFINE, :NAME, :ASSIGN, :expr) do \
        |(_def,name,op),(value)|
        Node::AssignVar.new(_def.pos, name, value)
      end
    end

    group(:get_var) do
      rule(:NAME) do |(name),_|
        Node::RetrieveVar.new(name.pos, name)
      end
    end

    group(:member) do
      #rule(:fn_call)
      rule(:get_var)
    end

    group(:members) do
      rule(:member, :MEMBER, :members) do |_, (src, act)|
        Node::RetrieveMember.new(src.position, src, act)
      end
      rule(:member)
    end

    group(:member_set) do
      rule(:members, :ASSIGN, :expr) do |(op), (dest,value)|
        Node::AssignMember.new(dest.position, dest, value, op.value)
      end
      rule(:set_var)
    end

    group(:member_access) do
      rule(:member_set)
      rule(:members)
    end
  end
end
