module Magiika
  class DummyType < Type
    def initialize
      super(Scope.new("dummy"))
    end

    def create_instance(*args, position : Position? = nil, **kwargs) : Instance
      raise "can't create instance of dummy type"
    end
  end
end
