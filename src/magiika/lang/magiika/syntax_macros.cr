module Magiika::Lang::Syntax
  private macro bin_expr_rule(l_s, op_s, r_s)
    rule({{l_s}}, {{op_s}}, {{r_s}}) do |context|
      l = context[{{l_s}}].node
      op = context[{{op_s}}].token
      r = context[{{r_s}}].node

      context.clear

      position = l.position
      obj = Node::BinaryExpr.new(position, l, op.value, r)
      context.add(obj)
    end
  end

  private macro un_expr_rule(l, r)
    rule({{l}}, {{r}}) do |context|
      # FIXME: Operator is not always left
      op = context[{{l}}].token
      obj = context[{{r}}].node

      {% if ("#{l}".upcase == "#{l}") == ("#{r}".upcase == "#{r}") %}
        {% raise "Compile-time validation of unary expr rule (#{l}, #{r}) failed. " +
        "One argument must be referencing a group, the other one must be referencing a token." %}
      {% end %}

      context.clear

      context.add(Node::UnaryExpr.new(op.position, op.value, obj, false))
    end
  end
end
