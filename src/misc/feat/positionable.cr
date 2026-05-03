module Magiika::Positionable
  getter? position : Position?

  def position : Position
    @position || Position.default
  end

  def position! : Position
    @position || raise Error::Internal.new("No position specified.")
  end
end
