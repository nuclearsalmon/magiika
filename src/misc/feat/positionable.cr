module Magiika::Positionable
  getter? position : Position?
  
  def position : Position
    position = position?
    return Position.default if position.nil?
    position
  end

  def position! : Position
    position = position?
    if position.nil?
      raise Error::Internal.new("No position specified.")
    end
    position
  end
end
