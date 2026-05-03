module Magiika
  class Worker
    @queue : Deque(Ast) = Deque.new(policy.worker_queue_init_size)
    
    def push(ast : Ast)
      @queue << ast
    end
  end
  
  class Runtime
    @policy : Policy
    @workers = Deque(Worker).new
    
    def initialize(@policy : Policy)
    end
    
    def push(ast : Ast)
    end
  end
end
