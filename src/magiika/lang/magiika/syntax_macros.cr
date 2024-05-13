module Magiika::Lang::Syntax
  private macro bin_expr_rule(l_s, op_s, r_s)
    {% l_ss = l_s.stringify %}
    {% if l_ss.upcase == l_ss %}
      {% raise "Compile-time validation of binary expr rule " +
               "(#{l_s}, #{op_s}, #{r_s}) failed.\n" +
               "Left-hand side must be a rule, but it is a token." %}
    {% end %}

    {% op_ss = op_s.stringify %}
    {% if op_ss.upcase != op_ss %}
      {% raise "Compile-time validation of binary expr rule " +
               "(#{l_s}, #{op_s}, #{r_s}) failed.\n" +
               "Operator must be a token, but it is a rule." %}
    {% end %}

    {% r_ss = r_s.stringify %}
    {% if r_ss.upcase == r_ss %}
      {% raise "Compile-time validation of binary expr rule " +
               "(#{l_s}, #{op_s}, #{r_s}) failed.\n" +
               "Right-hand side must be a rule, but it is a token." %}
    {% end %}

    rule({{l_s}}, {{op_s}}, {{r_s}}) do |context|
      l = context[{{l_s}}].node
      op = context[{{op_s}}].token
      r = context[{{r_s}}].node

      context.clear

      position = l.position
      expr = Node::BinaryExpr.new(position, l, op.value, r)
      context.add(expr)
    end
  end

  private macro un_expr_rule(l_s, r_s)
    {% l_ss = l_s.stringify %}
    {% l_is_tok = l_ss.upcase == l_ss %}
    {% r_ss = r_s.stringify %}
    {% r_is_tok = r_ss.upcase == r_ss %}

    {% if l_is_tok == r_is_tok %}
      {% raise "Compile-time validation of unary expr rule " +
               "(#{l_s}, #{r_s}) failed.\n" +
               "One argument must be referencing a group, " +
               "the other one must be referencing a token." %}
    {% end %}

    rule({{l_s}}, {{r_s}}) do |context|
      # NOTE: Operator is not always left-side
      {% if l_is_tok %}
        op = context[{{l_s}}].token
        obj = context[{{r_s}}].node
        pos = op.position
        side = false
      {% else %}
        op = context[{{r_s}}].token
        obj = context[{{l_s}}].node
        pos = obj.position
        side = true
      {% end %}

      context.clear

      pp op.value
      pp obj

      expr = Node::UnaryExpr.new(pos, op.value, obj, side)
      context.add(expr)
    end
  end
end
