module Magiika::Lang::Syntax
  protected def register_variables
    group(:set_var) do
      rule(:DEFINE, :NAME, :ASSIGN, :expr) do |context|
        define = context[:DEFINE].token
        name = context[:NAME].token
        expr = context[:expr].node

        context.clear
        context.add(Node::DeclareVar.new(define.position, name, expr))
      end

      rule(:NAME, :ASSIGN, :expr) do |context|
        name = context[:NAME].token
        expr = context[:expr].node

        context.clear
        context.add(Node::AssignVar.new(name.position, name, expr))
      end
    end

    group(:member) do
      rule(:NAME) do |context|
        name = context.token

        context.clear
        context.add(Node::RetrieveVar.new(name.position, name))
      end
    end

    group(:members) do
      rule(:member, :MEMBER, :members) do |context|
        src = context[:member].node
        act = context[:members].node

        Node::RetrieveMember.new(src.position, src, act)
      end

      rule(:member)
    end

    group(:member_set) do
      rule(:set_var)
      rule(:members, :ASSIGN, :expr) do |context|
        dest = context[:members].node
        value = context[:expr].node
        op = context[:ASSIGN].token

        Node::AssignMember.new(dest.position, dest, value, op.value)
      end
    end

    group(:member_access) do
      rule(:member_set)
      rule(:members)
    end
  end
end
