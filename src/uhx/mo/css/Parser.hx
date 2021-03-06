package uhx.mo.css;

import haxe.io.Eof;
import uhx.mo.Token;
import byte.ByteData;
import uhx.mo.css.Lexer;

using Mo;
using StringTools;

/**
 * ...
 * @author Skial Bainn
 */
class Parser {

    public function new() {
        
    }
    
    public function toTokens(bytes:ByteData, name:String):Array<Token<CssKeywords>> {
        var lexer = new Lexer(bytes, name);
        var tokens = [];
        
        try while ( true ) {
            tokens.push( lexer.token( Lexer.root ) );
        } catch (e:Eof) {
            
        } catch (e:Dynamic) {
            
        }
        
        return tokens;
    }
    
    /*public function printHTML(token:Token<CssKeywords>, ?tag:String = 'span'):String {
        var css = token.toCSS();
        var result = '<$tag class="$css">' +
        (switch (token) {
            case Keyword( RuleSet(s, t) ):
                var css = s.toCSS();
                '<$tag class="$css">' + printSelector( s ) + '</$tag>'
                + '<$tag class="brace open"> {\r\n</$tag>'
                //+ [for (i in t) '\t' + printHTML( i )].join('\r\n')
                + t.map( function(i) return '\t' + printHTML( i ) ).join( '\r\n' )
                + '<$tag class="brace close">\r\n}</$tag>';
                
            case Keyword( AtRule(n, q, t) ):
                '@$n'
                //+ '(' + [for (i in q) printMediaQuery( i )].join(' ') + ') <$tag class="brace open">{\r\n</$tag>'
                + q.map( function(i) return printMediaQuery( i ) ).join(' ') + ') <$tag class="brace open">{\r\n</$tag>'
                //+ [for (i in t) '\t' + printHTML( i )].join('\r\n')
                + t.map( function(i) return '\t' + printHTML( i ) ).join( '\r\n' )
                + '<$tag class="brace close">\r\n}</$tag>';
                
            case Keyword( Declaration(n, v) ):
                '<$tag>$n</$tag><$tag class="colon">: </$tag><$tag>$v</$tag><$tag class="semicolon">;</$tag>';
                
            case _: '<wbr>&shy;' + printString( token );
        })
        + '</$tag>';
        
        return result;
    }*/
    
    public function printString(token:Token<CssKeywords>, compress:Bool = false):String {
        var result = '';
        var tab = '\t';
        var space = ' ';
        var newline = '\r\n';
        
        if (compress) {
            tab = space = newline = '';
        }
        
        switch (token) {
            case BraceOpen:
                result = '{';
                
            case BraceClose:
                result = '}';
                
            case Semicolon:
                result = ';';
                
            case Colon:
                result = ':';
                
            case Hash:
                result = '#';
                
            case Comma:
                result = ',';
                
            case Comment(c) if (!compress):
                result = '/*$c*/';
                
            case Keyword( RuleSet(s, t) ):
                result += printSelector( s, compress );
                result += '$space{$newline';
                result += [for (i in t) '$tab' + printString( i, compress)].join( newline );
                //result += t.map( function(i) return '$tab' + printString( i, compress ) ).join( newline );
                result += '$newline}';
                
            case Keyword( AtRule(n, q, t) ):
                result = '@$n';
                result += ' ' + [for (i in q) printMediaQuery( i, compress )].join(' ') + ' {$newline';
                //result += ' ' + q.map( function(i) return printMediaQuery( i, compress ) ).join(' ') + ' {$newline';
                //result += ' ' + [for (i in q) printMediaQuery( i, compress )].join(' ') + ' {$newline';
                //result += ' ' + q.map( function(i) return printMediaQuery( i, compress ) ).join(' ') + ' {$newline';
                result += [for (i in t) '$tab' + printString( i, compress ).replace(compress? '': '\n', compress? '' : '\n\t')].join( newline );
                //result += t.map( function(i) return '$tab' + printString( i, compress ).replace(compress?'':'\n', compress?'':'\n\t') ).join( newline );
                result += '$newline}';
                
            case Keyword( Declaration(n, v) ):
                result = '$n:$space$v;';
                
            case _:
                
        }
        
        return result;
    }
    
    public function printSelector(token:CssSelectors, compress:Bool = false):String {
        var result = '';
        var tab = '\t';
        var space = ' ';
        var newline = '\r\n';
        
        if (compress) {
            tab = space = newline = '';
        }
        
        switch (token) {
            case Group(s):
                for (i in s) switch (i) {
                    case _:
                        if (result != '' && !i.match( Attribute(_, _, _) )) {
                            result += ',$newline';
                        }
                        result += printSelector( i, compress );
                        
                }
                
            case Type(n):
                result = n;
                
            case Universal:
                result = '*';
                
            case Attribute(n, t, v):
                result = '[$n' + printAttributeType( t ) + '$v]';
                
            case Class(n):
                if (n.length > 0) {
                    result = '.' + [for (i in n) '$i'].join('.');
                    //result = '.' + n.map( function(i) return '$i' ).join('.');
                }
                
            case ID(n):
                result = '#$n';
                
            case Pseudo(n, e):
                result = ':$n' + e == ''? '' : '($e)';
                
            case Combinator(s, n, t):
                result = printSelector( s, compress );
                result += ' ' + printCombinatorType( t ) + ' ';
                result += printSelector( n, compress );
                
            case _:
                
        }
        
        return result;
    }
    
    public function printAttributeType(token:AttributeType):String {
        var result = '';
        
        switch (token) {
            case Exact:
                result = '=';
                
            case List:
                result = '~=';
                
            case DashList:
                result = '|=';
                
            case Prefix:
                result = '^=';
                
            case Suffix:
                result = '$=';
                
            case Contains:
                result = '*=';
                
            case _:
                
        }
        
        return result;
    }
    
    public function printCombinatorType(token:CombinatorType):String {
        var result = '';
        
        switch (token) {
            case Child:
                result = '>';
                
            case Descendant:
                result = ' ';
                
            case Adjacent:
                result = '+';
                
            case General:
                result = '~';
                
            case _:
                
        }
        
        return result;
    }
    
    public function printMediaQuery(token:CssMedia, compress:Bool = false):String {
        var result = '';
        var tab = '\t';
        var space = ' ';
        var newline = '\r\n';
        
        if (compress) {
            tab = space = newline = '';
        }
        
        switch (token) {
            case Only:
                result = 'only';
                
            case Not:
                result = 'not';
                
            case Feature(n):
                result = n;
                
            case Group(q) if(q.length > 0):
                result = [for (a in q) [for (b in a) printMediaQuery( b, compress )].join(' ') ].join(',$space');
                //result = q.map( function(i) return i.map( function(a) return printMediaQuery( a, compress ) ).join(' ') ).join(',$space');
                
            case Expr(n, v):
                result = '($n:$space$v)';
                
            case _:
                
        }
        
        return result;
    }
    
}