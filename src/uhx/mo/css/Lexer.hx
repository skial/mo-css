package uhx.mo.css;

import haxe.io.Eof;
import uhx.mo.Token;
import uhx.lexer.Css;
import hxparse.Lexer;
import byte.ByteData;
import hxparse.Ruleset;
import haxe.extern.EitherType;

using Std;
using StringTools;

/**
 * ...
 * @author Skial Bainn
 */
private typedef Tokens = Array<Token<CssKeywords>>;

enum CssKeywords {
	RuleSet(selector:CssSelectors, tokens:Tokens);
	AtRule(name:String, query:Array<CssMedia>, tokens:Tokens);
	Declaration(name:String, value:String);
}

private typedef Selectors = Array<CssSelectors>;

enum CssSelectors {
	Group(selectors:Selectors);
	Type(name:String);
	Universal;
	Attribute(name:String, type:AttributeType, value:String);
	Class(names:Array<String>);
	ID(name:String);
	Pseudo(name:String, expr:CssSelectors);
	Combinator(selector:CssSelectors, next:CssSelectors, type:CombinatorType);
}

@:enum abstract AttributeType(Int) from Int to Int {
	public var Unknown = -1;
	public var Exact = 0;						//	att=val
	public var List = 1;						//	att~=val
	public var DashList = 2;				//	att|=val
	public var Prefix = 3;					//	att^=val
	public var Suffix = 4;					//	att$=val
	public var Contains = 5;				//	att*=val
}

@:enum abstract CombinatorType(Int) from Int to Int {
	public var None = 0;						// Used in `type.class`, `type:pseudo` and `type[attribute]`
	public var Child = 1;						//	`>`
	public var Descendant = 2;			//	` `
	public var Adjacent = 3;				//	`+`
	public var General = 4;					//	`~`
	public var Shadow = 5;					//	`>>>`
}

private typedef Queries = Array<CssMedia>;

enum CssMedia {
	Only;
	Not;
	Feature(name:String);
	Group(queries:Array<Queries>);
	Expr(name:String, value:String);
}

enum NthExpressions {
	Index(position:Int);
	Notation(a:Int, b:Int, negative:Bool);
}
 
@:access(hxparse.Lexer) class Lexer extends hxparse.Lexer {

	public function new(content:ByteData, name:String) {
		super( content, name );
	}
	
	public static var s = ' \t\r\n';
	public static var escaped = '(\u005c\u005c.?)';
	public static var ident = 'a-zA-Z0-9\\-\\_';
	public static var selector = "a-zA-Z0-9\\$\\:\\#\\>\\~\\=\\.\\-\\_\\*\\^\\|\\+";
	public static var any = 'a-zA-Z0-9 "\',%#~=:;@!$&\t\r\n\\{\\}\\(\\)\\[\\]\\|\\.\\-\\_\\*';
	public static var declaration = '[$ident]+[$s]*:[$s]*[^;{]+;';
	//public static var combinator = '( +| *> *| *\\+ *| *~ *|\\.|:|\\[)?';
	public static var combinator = '( +| *> *| *\\+ *| *~ *)?';
    public static var comma = '(,)?';
	
	private static function makeRuleSet(rule:String, tokens:Tokens) {
		var selector = parse(ByteData.ofString(rule), 'selector', selectors);
		
		// Any Attribute or Pseudo selector without a preceeding selector is treated
		// as having a Universal selector preceeding it. 
		// `[a=1]` becomes `*[a=1]`
		// `:first-child` becomes `*:first-child`
		for (i in 0...selector.length) switch(selector[i]) {
			case Attribute(_, _, _) | Pseudo(_, _) | 
			Combinator(Attribute(_, _, _), _, _) | Combinator(Pseudo(_, _), _, _):
				selector[i] = Combinator(Universal, selector[i], None);
				
			case _:
				
		}
		
		return Keyword(RuleSet(selector.length > 1? CssSelectors.Group(selector) : selector[0], tokens));
	}
	
	private static function makeAtRule(rule:String, tokens:Tokens) {
		var index = rule.indexOf(' ');
		var query = parse(ByteData.ofString(rule.substring(index)), 'media query', mediaQueries);
		return Keyword(AtRule(rule.substring(1, index), /*query.length > 1? CssMedia.Group(query) : query[0]*/query, tokens));
	}
	
	private static function handleRuleSet(lexer:Lexer, make:String->Tokens->Token<CssKeywords>, breakOn:Token<CssKeywords>) {
		var current = lexer.current;
		var rule = current.substring(0, current.length - 1);
		var tokens:Tokens = [];
		
		try while (true) {
			var token:Token<CssKeywords> = lexer.token( root );
			switch (token) {
				case x if(x == breakOn): break;
				case _:
			}
			tokens.push( token );
		} catch (e:Eof) {
			
		} catch (e:Dynamic) {
			trace( e );
		}
		
		return make(rule.trim(), tokens);
	}
	
	public static var root = Mo.rules([
	'[\n\r\t ]*' => lexer.token( root ),
	'/\\*' => {
		var tokens = [];
		try while ( true ) {
			var token:String = lexer.token( comments );
			switch (token) {
				case '*/': break;
				case _:
			}
			tokens.push( token );
		} catch (e:Eof) { } catch (e:Dynamic) {
			trace( e );
		}
		
		Comment( tokens.join('').trim() );
	},
	'[^\r\n/@}{]([$selector,"\'/ \\[\\]\\(\\)$s]+$escaped*)+{' => handleRuleSet(lexer, makeRuleSet, BraceClose),
	'@[$selector \\(\\),]+{' => {
		handleRuleSet(lexer, makeAtRule, BraceClose);
	},
	declaration => {
		var tokens = parse(ByteData.ofString(lexer.current), 'declaration', declarations);
		Keyword(Declaration(tokens[0], tokens[1]));
	},
	'{' => BraceOpen,
	'}' => BraceClose,
	';' => Semicolon,
	':' => Colon,
	'#' => Hash,
	',' => Comma,
	]);
	
	public static var comments = Mo.rules([
	'\\*/' => '*/',
	'[^*/]+' => lexer.current,
	'\\*' => '*',
	'/' => '/',
	]);
	
	private static function handleSelectors(lexer:Lexer, single:Int->CssSelectors) {
		var result = null;
        var group = false;
		var current = lexer.current;
		var idx = current.length-1;
		var len = current.length-1;
		var type:CombinatorType = None;

        if (group = current.fastCodeAt(idx) == ','.code) {
            current = current.substring(0, idx);
            idx--;
            len--;

        }

		//trace(current);

		while (idx > -1) {
            switch current.fastCodeAt(idx) {
                    case ' '.code: 
                        if (type == None) type = Descendant;
                        idx--;
                        
                    case '>'.code: 
                        type = Child;
                        idx--;
                        
                    case '+'.code: 
                        type = Adjacent;
                        idx--;
                        
                    case '~'.code: 
                        type = General;
                        idx--;
                        
                    case x: 
                        idx++;
                        break;
            }
            //trace( idx, type, current.substring(0, idx).replace(' ', '_') );
        }
		//trace(current, type, idx, current.substring(0, idx));
		var tokens = [];
		try while (true) {
			tokens.push( lexer.token(selectors) );
			
		} catch (e:Eof) {
			
		} catch (e:Dynamic) {
			trace( e );
			trace( lexer.source );
			trace( lexer.input );
			trace( lexer.input.readString(0, lexer.pos) );
		}

		//trace( tokens );
		if (!group) {
            if (tokens.length > 0) {
                //trace(tokens, tokens.length);
                var remainder = [];
		        var next = tokens.length > 1 ? CssSelectors.Group(tokens) : tokens[0];
                switch next {
                    case CssSelectors.Group(toks): 
                        next = toks[0];
                        for (t in 1...toks.length) remainder.push(toks[t]);

                    case _:
                }
                result = remainder.length > 0 ? CssSelectors.Group([Combinator(single(idx), next, type)].concat(remainder)) : Combinator(single(idx), next, type);
                //trace(result);
            } else {
                result = single(idx);

            }

        } else {
            //trace( tokens );
            var t = [];
            for (tok in tokens) switch tok {
                case CssSelectors.Group(ts): for (tok in ts) t.push(tok);
                case _: t.push(tok);
            }
            t.unshift(single(idx));
            //trace( t );
            result = t.length > 1 ? CssSelectors.Group(t) : t[0];

        }
		
		return result;
	}
	
	public static var combinators = Mo.rules([
	'(.?\u005c\u005c)?' => lexer.token( combinators ),	// reversed escape sequence
	'[.:\\[]' => None,
	' ' => Descendant,
	'>' => Child,
	'+' => Adjacent,
	'~' => General,
	'>>>' => Shadow,
	]);
	
	public static var scoped:Bool = false;
	
	public static var selectors = Mo.rules([
    //',' => lexer.token( selectors ),
	' +' => lexer.token( selectors ),
	'/\\*[^\\*]*\\*/' => lexer.token( selectors ),
	'[\t\r\n]+' => lexer.token( selectors ),
	'\\*$combinator$comma' => {
		handleSelectors(lexer, function(_) return Universal);
	},
	'([$ident]+$escaped*)+$combinator$comma' => {
		var current = lexer.current.trim();
		var name = ['.'.code, ':'.code].indexOf(current.charCodeAt(current.length - 1)) > -1 
			? current.substring(0, current.length - 1).trim() 
			: current;
		handleSelectors(lexer, function(i) { 
            //trace(current, name, name.substring(0, i), i);
			return Type( i > 0 ? name.substring(0, i).rtrim() : name );
		} );
	},
	'#([$ident]+$escaped*)+$combinator$comma' => {
		var name = lexer.current;
		handleSelectors(lexer, function(i) {
			return ID( i > -1 ? name.substring(1, i).rtrim() : name.substring(1, name.length) );
		} );
	},
	'([\t\r\n]*\\.([$ident]+$escaped*)+)+$combinator$comma' => {
		var parts = [];
		
		if (lexer.current.lastIndexOf('.') != 0) {
			parts = lexer.current.split('.').map(function(s) return s.trim()).filter(function(s) return s != '');
		} else {
			parts = [lexer.current.substring(1).trim()];
		}
		
		handleSelectors(lexer, function(i) {
			if (i > -1) {
				var j = parts.length -1;
				parts[j] = parts[j].substring(0, i - 1).trim();
			}
			
			return Class( parts );
		} );
	},
	//'::?([$ident]+$escaped*)+[ ]*(\\([^\\(\\)]*\\))?($combinator)' => {
    '::?([$ident]+$escaped*)+[ ]*\\(' => {
		var current = lexer.current.trim();
        //trace( current );
		var expression = '';
		var index = current.length;
		var lindex = current.length;
        current = current.substring(0, current.length-1);
		
		/*if ((lindex = current.lastIndexOf(')')) > -1) {
			index = current.indexOf('(');
			expression = current.substring(index + 1, lindex);
            trace(expression);
		}

        */

        //var lexer = new Css(value, name);
		var tokens = [];
		
		try while (true) {
			tokens.push( lexer.token( selectors ) );
		} catch (e:Eof) {
			
		} catch (e:Any) {
			//untyped trace( lexer.input.readString( lexer.curPos().pmin, lexer.curPos().pmax ) );
			trace( e );
            trace( lexer.source );
			trace( lexer.input );
			trace( lexer.input.readString(0, lexer.pos) );
            //@:privateAccess lexer.pos--;
			
		}
		
		//trace(tokens);
        var closing = try lexer.token( pseudoCombinator ) catch(e:Any) {
            trace(e);
            -1;
        };
        trace(closing);
		handleSelectors(lexer, function(i) {
			if (i > -1 && i < index) {
				index = i;
			}
			//trace( i, index, lindex, current, current.substring(1) );
			//return Pseudo(current.substring(1, index).trim(), expression);
            return Pseudo(current.substring(1), tokens.length > 1 ? Group(tokens) : tokens[0]);
		} );
	},
	'\\[[$s]*([$ident]+$escaped*)+[$s]*([=~$\\*\\^\\|]+[$s]*[^\r\n\\[\\]]+)?\\]$combinator$comma' => {
		var current = lexer.current;
        //trace(current);
		handleSelectors(lexer, function(i) {
			//var tokens:Array<Dynamic> = parse(ByteData.ofString(current.substring(1, i == -1 ? current.length - 1 : i-1)), 'attributes', attributes);
			var tokens:Array<Dynamic> = parse(ByteData.ofString(current.substring(1, current.lastIndexOf(']'))), 'attributes', attributes);
			return Attribute( 
				(tokens.length > 0) ? tokens[0] : '', 
				(tokens.length > 1) ? tokens[1] : -1, 
				(tokens.length > 2) ? tokens[2] : '' 
			);
		} );
	},
	/*//'[^,]+(,[^,]+)+' => {
		var tokens = [];
        trace( lexer.current );
        for (c in lexer.current.split(',')) trace(c);
		for (part in lexer.current.split(',')) {
			tokens = tokens.concat(parse(ByteData.ofString(part.trim()), 'css-group-selector', selectors));
		}
		
		//tokens = parse(ByteData.ofString(lexer.current), 'grouped', selectors);

        trace( tokens );
		
		(tokens.length == 1)? tokens[0] : CssSelectors.Group(tokens);
	},*/
	'>' => {
		!scoped
			? lexer.token( selectors )
			: Combinator(Pseudo('scope', Group([])), lexer.token( selectors ), Child);
	},
	'\\+' => {
		!scoped
			? Pseudo('not', Universal)
			: Combinator(Pseudo('scope', Group([])), lexer.token( selectors ), Adjacent);
	},
	'~' => {
		!scoped
			? Pseudo('not', Universal)
			: Combinator(Pseudo('scope', Group([])), lexer.token( selectors ), General);
	},
	]);

    public static var pseudoCombinator = Mo.rules([
    '\\)?$combinator$comma' => {
        trace(lexer.current);
        -1;
    }
    ]);
	
	public static var attributes = Mo.rules([
	'=' => Exact,
	'~=' => AttributeType.List,
	'\\|=' => DashList,
	'\\^=' => Prefix,
	'$=' => Suffix,
	'\\*=' => Contains,
	'[$s]*[^\t\n\r=~\\$\\|\\^\\*\\[\\]]+[$s]*' => {
		var value = lexer.current.trim();
		if (value.startsWith('"') || value.startsWith("'")) value = value.substring(1);
		if (value.endsWith('"') || value.endsWith("'")) value = value.substring(0, value.length - 1);
		value;
	}
	]);
	
	public static var declarations = Mo.rules([
	'[$ident]+[$s]*:' => {
		untyped lexer.pos--;
		lexer.current.substring(0, lexer.current.length - 1).trim();
	},
	':[$s]*[^;]+;' => lexer.current.substring(1, lexer.current.length-1).trim(),
	]);
	
	public static var mediaQueries = Mo.rules([
	'([^,]+,[^,]+)+' => {
		var tokens = [];
		
		for (part in lexer.current.split(',')) {
			tokens.push( parse(ByteData.ofString(part.trim()), 'group-media', mediaQueries) );
		}
		
		CssMedia.Group(tokens);
	},
	'(n|N)(o|O)(t|T)' => Not,
	'(o|O)(n|N)(l|L)(y|Y)' => Only,
	//'(a|A)(n|N)(d|D)|(a|A)(l|L)+' => lexer.token( mediaQueries ),
	'[$ident]+' => Feature(lexer.current),
	'[$ident]+[$s]*:[$s]*[$ident]+' => {
		var current = lexer.current;
		var parts = current.split(':');
		CssMedia.Expr(parts[0].trim(), parts[1].trim());
	},
	'\\(' => {
		var tokens = [];
		try while (true) {
			var token = lexer.token( mediaQueries );
			switch (token) {
				case Feature(')'): break;
				case _:
			}
			tokens.push( token );
		} catch (e:Eof) {
			
		} catch (e:Dynamic) {
			trace( e );
		}
		
		tokens[0];
	},
	'\\)' => Feature(')'),
	'[ :,]' => lexer.token( mediaQueries ),
	]);
	
	public static var nthExpression = Mo.rules([
		'[$s]*' => lexer.token( nthExpression ),
		'odd' => Notation(2, 1, false),
		'even' => Notation(2, 0, false),
		'[0-9]*n' => {
			var a = lexer.current.substring(0, lexer.current.length-1).parseInt();
			var b = try lexer.token( nthExpression ) catch(e:Any) Index(0);
			var r = Notation(a != null ? a : 1, switch b {
				case Index(v): v;
				case _: 0;
			}, false);
			r;
		},
		'[0-9]+' => {
			Index(lexer.current.parseInt());
		},
		'-' => {
			var r = switch lexer.token( nthExpression ) {
				case Index(v): Index(-v);
				case Notation(a, b, n): Notation(a, b, true);
			}
			r;
		},
		'+' => lexer.token( nthExpression ),
	]);
	
	private static function parse<T>(value:ByteData, name:String, rule:Ruleset<T>):Array<T> {
		var lexer = new Css(value, name);
		var tokens = [];
		
		try while (true) {
			tokens.push( lexer.token( rule ) );
		} catch (e:Eof) {
			
		} catch (e:Dynamic) {
			//untyped trace( lexer.input.readString( lexer.curPos().pmin, lexer.curPos().pmax ) );
			trace( e );
			trace( name );
			trace( tokens );
			trace( value.readString(0, value.length) );
		}
		
		return tokens;
	}
	
}
