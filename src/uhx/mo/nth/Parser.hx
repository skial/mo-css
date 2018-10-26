package uhx.mo.nth;

import haxe.io.Eof;
import byte.ByteData;
import uhx.mo.css.Lexer;
import uhx.mo.css.Lexer.NthExpressions;

class Parser {
    
    public function new() {
        
    }
    
    public function toTokens(bytes:ByteData, name:String):NthExpressions {
        var lexer = new Lexer(bytes, name);
        var tokens = [];
        
        try while ( true ) {
            tokens.push( lexer.token( Lexer.nthExpression ) );
        } catch (e:Eof) {
            
        } catch (e:Dynamic) {
            trace( e );
        }
        
        //if (tokens.length == 0) return Unknown;
        //trace( bytes, tokens[0] );
        return switch tokens[0] {
            case Notation(a, b, isNegative):
                if (a == 0 && b > 0) {
                    Index(b);
                    
                } else {
                    tokens[0];
                    
                }
                
            case _:
                tokens[0];
        }
        
    }
    
}
