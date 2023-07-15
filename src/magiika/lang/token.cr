module Magiika::Lang
  record Token, 
    name : Symbol, 
    pattern : Regex

  record MatchedToken,
    name : Symbol,
    value : String,
    pos : Lang::Position
end
