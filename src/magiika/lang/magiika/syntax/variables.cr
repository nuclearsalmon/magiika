module Magiika::Lang::Syntax
  protected def register_variables
    group(:set_var) do
      rule(:DEFINE, :NAME, :ASSIGN, :expr) do |context|
        _def = context.token(:DEFINE)
        name = context.token(:NAME)
        value = context.node(:expr)

        Node::AssignVar.new(_def.pos, name, value)
      end
    end

    group(:get_var) do
      rule(:NAME) do |context|
        name = context.token(:NAME)

        Node::RetrieveVar.new(name.pos, name)
      end
    end

    group(:member) do
      #rule(:fn_call)
      rule(:get_var)
    end

    group(:members) do
      rule(:member, :MEMBER, :members) do |context|
        src = context.node(:member)
        act = context.node(:members)

        Node::RetrieveMember.new(src.position, src, act)
      end

      rule(:member)
    end

    group(:member_set) do
      rule(:members, :ASSIGN, :expr) do |context|
        dest = context.node(:members)
        value = context.node(:expr)
        op = context.token(:ASSIGN)

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
