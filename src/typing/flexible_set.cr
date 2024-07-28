class Magiika::FlexibleSet(A)
  include Enumerable(A)

  private abstract struct AbstractContainer; end

  private record Container(T) < AbstractContainer, value : T do
    def_equals @value
  end

  @set = Set(AbstractContainer).new

  def initialize(values : Enumerable(A))
    values.each do |v|
      self << v
    end
  end

  def <<(value : A) : Nil
    @set << Container.new value
  end

  def each(&)
    @set.each do |v|
      yield v.value
    end
  end
end