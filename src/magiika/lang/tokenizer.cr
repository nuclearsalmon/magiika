module Magiika::Lang::Tokenizer
  Log = ::Log.for("lang.tokenizer")
  
  def tokenize(str : String, filename : String) : Array(MatchedToken)
    tokens_found = Array(MatchedToken).new
    row, col = 1, 1

    until str.empty?
      raise Error::Internal.new("Failed to tokenize \"#str\".") \
          unless @tokens.values.any? do |token|
        match = token.pattern.match(str)
        
        unless match.nil?
          Log.debug { "Matched token :#{token.name}: \"#{match[0]}\"" }

          content = ""
          match.to_a.each { | group | content += group unless group.nil? }
          
          position = Lang::Position.new(filename, row, col)
          token = Lang::MatchedToken.new(token.name, content, position)
          tokens_found << token

          str = match.post_match
  
          content.each_char { | char |
            if char == '\n'
              row += 1
              col = 1
            else
              col += 1
            end
          }

          true
        else
          false
        end
      end

      if tokens_found.empty?
        raise Error::UnexpectedCharacter.new(str[0], Position.new(filename, row, col))
      end
    end

    return tokens_found
  end
end
