module Magiika
  def bootstrap(policy : SecurityPolicy)
    global = GlobalScope.new(policy)
    
    Type.core_types.each { |type| 
      global.define(type.name, type)
    }
    
    global
  end
end
