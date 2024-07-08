require "./scope"


module Magiika
  class Scope::Global < Scope::Standalone
    def initialize(
        position : Position)
      super("global", position)
    end
  end
end
