package peg.parser;

using peg.parser.Tools;

class Tools {
	static public function expect(stream:TokenStream, type:TokenType):Token {
		var token = stream.next();
		if(token.type != type) {
			throw new UnexpectedTokenException(token);
		}
		return token;
	}

	static public function skipTo(stream:TokenStream, types:TokenTypeSet):Token {
		for (token in stream) {
			if(types.contains(token.type)) {
				return token;
			}
		}
		throw throw new PegException('Unexpected end of file');
	}

	static public function skipValue(stream:TokenStream) {
		var token = stream.next();
		switch token.type {
			case T_LEFT_SQUARE:
				skipBalancedTo(stream, T_RIGHT_SQUARE);
			case T_LEFT_PARENTHESIS:
				skipBalancedTo(stream, T_RIGHT_PARENTHESIS);
			case _:
				skipTo(stream, [T_COMMA, T_SEMICOLON, T_RIGHT_PARENTHESIS]);
				stream.back();
		}
	}

	static public function skipBalancedTo(stream:TokenStream, type:TokenType) {
		switch type {
			case T_RIGHT_CURLY | T_RIGHT_SQUARE | T_RIGHT_PARENTHESIS:
			case _: throw new PegException('Invalid token type for skipBalancedTo: $type');
		}

		inline function validateEnd(token:Token) {

		}

		for (token in stream) {
			switch token.type {
				case T_RIGHT_CURLY | T_RIGHT_SQUARE | T_RIGHT_PARENTHESIS:
					if(token.type == type) break;
					throw new UnexpectedTokenException(token);
				case T_LEFT_CURLY | T_CURLY_OPEN | T_DOLLAR_OPEN_CURLY_BRACES:
					stream.skipBalancedTo(T_RIGHT_CURLY);
				case T_LEFT_SQUARE:
					stream.skipBalancedTo(T_RIGHT_SQUARE);
				case T_LEFT_PARENTHESIS:
					stream.skipBalancedTo(T_RIGHT_PARENTHESIS);
				case _:
			}
		}
	}
}