module Magiika::Lang::Syntax
  protected def register_var
    group(:set_var) do
      rule(:DEFINE, :NAME, :ASSIGN, :value) do \
        |(df,name,op),(value)|
        type(value, Node::Node)

        Magiika::Node::Assign.new(df.pos, name, value)
      end
    end

    group(:get_var) do
      rule(:NAME) do |(name),_|
        Magiika::Node::Retrieve.new(name.pos, name)
      end
    end

    group(:member) do
      rule(:fn_call)
      rule(:get_var)
    end

    group(:members) do
      rule(:member, :MEMBER) do |(act), (src)|
        Node::GetMember.new(src, act)
      end
      rule(:member)
    end

    group(:member_set) do
      rule(:set_var)
      rule(:members, :ASSIGN, :expr) do |(op), (dest,value)|
        Node::SetMember.new(dest, op, value)
      end
    end
  end
end
