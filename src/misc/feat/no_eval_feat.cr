module Magiika::NoEvalFeat
  def eval(scope : Scope) : AnyObject
    raise Error::NotImplemented.new("#{self.class} is not meant to be evaluated.")
  end

  def eval_bool(scope : Scope) : ::Bool
    raise Error::NotImplemented.new("#{self.class} is not meant to be evaluated.")
  end
end
