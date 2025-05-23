module Magiika::Syntax
  @@__syntax_instructions = [] of Proc(Merlin::ParserBuilder(Symbol, Ast), Nil)

  macro define_syntax(&block)
    @@__syntax_instructions << ->(builder : Merlin::ParserBuilder(Symbol, Ast)) {
      builder.with_self {
        {{block.body}}
      }
    }
  end

  def self.apply_syntax(builder : Merlin::ParserBuilder(Symbol, Ast))
    @@__syntax_instructions.each &.call(builder)
  end

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
      position = l.position

      context.clear

      node = Ast::BinaryExpression.new(position, l, op.value, r)
      context.add(node)
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
        position = op.position
        right_side = false
      {% else %}
        op = context[{{r_s}}].token
        obj = context[{{l_s}}].node
        position = obj.position
        right_side = true
      {% end %}

      context.clear

      node = Ast::UnaryExpression.new(position, op.value, obj, right_side)
      context.add(node)
    end
  end

  private macro error_trap(trigger_token, expected_token_str)
    rule {{trigger_token}} do |context|
      position = context.after_last_position
      raise Error::ExpectedCharacter.new("Expected " + {{expected_token_str}} + ".", position)
    end
  end
end
