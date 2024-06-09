module Magiika::Lang::Tokenizer
  Log = ::Log.for("lang.tokenizer")

  def tokenize(str : String, filename : String? = nil) : Array(MatchedToken)
    tokens_found = Array(MatchedToken).new
    row, col = 1, 1

    until str.empty?
      raise Error::SafeParsingError.new("Unable to tokenize \"#{str}\".") \
          unless @tokens.values.any? do |token|
        match = token.pattern.match(str)

        unless match.nil?
          Log.debug { "Matched token :#{token._type}: \"#{match[0]}\"" }

          content = match[0]

          position = Position.new(row, col, filename)
          token = Lang::MatchedToken.new(token._type, content, position)
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
        raise Error::UnexpectedCharacter.new(str[0], Position.new(row, col, filename))
      end
    end

    return tokens_found
  end
end
