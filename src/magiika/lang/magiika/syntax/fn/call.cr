module Magiika::Lang::Syntax
  protected def register_function_call
    group :fn_arg do
      rule :value do |context|
        value = context.node

        node = Node::FnArg.new(value)
        context.become(node)
      end

      rule :NAME, :EQ, :value do |context|
        name = context[:NAME].token.value
        value = context[:value].node

        node = Node::FnArg.new(value, name)
        context.become(node)
      end
    end

    group :fn_args do
      rule :fn_arg, :SEP, :fn_args do |context|
        context.drop(:SEP)
        context.flatten
      end

      rule :fn_arg
    end

    group :fn_args_block do
      rule :PAR
      rule :L_PAR, :fn_args, :R_PAR do |context|
        context.become(:fn_args)
      end
    end

    group :fn_call do
      rule :get_value, :fn_args_block do |context|
        define_arg(context, false)
      end
      rule :get_member_value, :fn_args_block do |context|
        define_arg(context, true)
      end
    end
  end

  protected def define_arg(context : Context, value_is_member : Bool)
    if value_is_member
      target = context[:get_member_value].node
    else
      target = context[:get_value].node
    end

    node_args = context[:fn_args_block].nodes?

    args = FnArgs.new
    unless node_args.nil?
      node_args.each { |node|
        Util.is_a!(node, Node::FnArg)
        args << node.as(Node::FnArg)
      }
    end

    position = context.position
    node = Node::Call.new(position, target, args)
    context.become(node)
  end
end