module Magiika::Lang::Syntax
  protected def register_function_call
    group :fn_call do
      rule :get_value, :PAR do |context|
        target = context[:get_value].node

        node = Node::Call.new(nil, target, FnArgs.new)
        context.become(node)
      end
      rule :get_member_value, :PAR do |context|
        target = context[:get_member_value].node

        node = Node::Call.new(nil, target, FnArgs.new)
        context.become(node)
      end
    end
  end
end