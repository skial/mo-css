package ;

import haxe.io.Eof;
import utest.Assert;
import uhx.mo.Token;
import byte.ByteData;
import uhx.mo.css.Lexer;
import uhx.mo.css.Parser;

using StringTools;

/**
 * ...
 * @author Skial Bainn
 */
@:keep class CssSpec {
    
    public var lexer:Lexer;
    public var parser:Parser = new Parser();

    public var tests:Tests;

    public function new() {
        var content = haxe.Resource.getString('tests.json');
        tests = tink.Json.parse(content);
        //parser = new Parser();
    }
    
    public function parse(value:String):Array<Token<CssKeywords>> {
        #if debug
        trace(value);
        #end
        
        var tokens = [];
        
        lexer = new Lexer( ByteData.ofString( value ), 'css-lexer-spec' );
        
        try while (true) {
            tokens.push( lexer.token( Lexer.root ) );
        } catch (e:Eof) { } catch (e:Dynamic) @:privateAccess {
            #if debug
            trace( haxe.CallStack.callStack() );
            trace( e );
            trace( lexer.input.readString( lexer.curPos().pmin, lexer.curPos().pmax ) );
            #end
        }
        
        return tokens;
    }
    
    public function testTypeDeclaration() {
        var t = parse( tests["typeDeclaration"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( CssSelectors.Type( 'div' ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'display', n );
                        Assert.equals( 'block', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
        
        Assert.equals( 'div {\r\n\tdisplay: block;\r\n}', parser.printString( t[0] ) );
        Assert.equals( 'div{display:block;}', parser.printString( t[0], true ) );
    }
    
    public function testTypeDeclaration_Newline() {
        var t = parse( tests["typeDeclaration_Newline"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue(
                    s.match( Group( [Type( 'div' ), Type( 'img' )] ) )
                );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'display', n );
                        Assert.equals( 'block', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
        
        Assert.equals( 'div,\r\nimg {\r\n\tdisplay: block;\r\n}', parser.printString( t[0] ) );
        Assert.equals( 'div,img{display:block;}', parser.printString( t[0], true ) );
    }
    
    public function testTypeDeclaration_NewlineCarriageTab() {
        var t = parse( tests["typeDeclaration_NewlineCarriageTab"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue(
                    s.match( Group( [Type( 'div' ), Type( 'img' )] ) )
                );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'display', n );
                        Assert.equals( 'block', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
        
        Assert.equals( 'div,\r\nimg {\r\n\tdisplay: block;\r\n}', parser.printString( t[0] ) );
        Assert.equals( 'div,img{display:block;}', parser.printString( t[0], true ) );
    }
    
    public function testIdDeclaration() {
        var t = parse( tests["idDeclaration"].test );
        
        Assert.equals( 1, t.length );
        
        switch ( t[0] ) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( ID( 'a' ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'b', n );
                        Assert.equals( 'c', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testIdDeclaration_multi() {
        var t = parse( tests["idDeclaration_multi"].test );
        
        Assert.equals( 1, t.length );
        
        switch ( t[0] ) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Group( [ID('a'), ID('b'), ID('c')] ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'd', n );
                        Assert.equals( 'e', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testIdDeclaration_child() {
        var t = parse( tests["idDeclaration_child"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Combinator( ID( 'a' ), ID( 'b' ), Child ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'c', n );
                        Assert.equals( 'd', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testClassDeclaration() {
        var t = parse( tests["classDeclaration"].test );
        
        Assert.equals( 1, t.length );
        
        switch ( t[0] ) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue(
                    s.match( CssSelectors.Class( ['class'] ) )
                );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'display', n );
                        Assert.equals( 'block', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
        
        Assert.equals( '.class {\r\n\tdisplay: block;\r\n}', parser.printString( t[0] ) );
        Assert.equals( '.class{display:block;}', parser.printString( t[0], true ) );
    }
    
    public function testClassDeclaration_Newline() {
        var t = parse( tests["classDeclaration_Newline"].test );
        
        Assert.equals( 1, t.length );
        
        switch( t[0] ) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue(
                    s.match( CssSelectors.Class( ['class1', 'class2'] ) )
                );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'display', n );
                        Assert.equals( 'block', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
        
        Assert.equals( '.class1.class2 {\r\n\tdisplay: block;\r\n}', parser.printString( t[0] ) );
        Assert.equals( '.class1.class2{display:block;}', parser.printString( t[0], true ) );
    }
    
    public function testClassDeclaration_NewlineCarriageTab() {
        var t = parse( tests["classDeclaration_NewlineCarriageTab"].test );
        
        Assert.equals( 1, t.length );
        
        switch( t[0] ) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue(
                    s.match( CssSelectors.Class( ['class1', 'class2'] ) )
                );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'display', n );
                        Assert.equals( 'block', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testComment() {
        var t = parse( tests["comment"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Comment( value ):
                Assert.equals( 'div http://url.org/index.php?f=1&g=11#blob !@?&', value );
                
            case _:
                
        }
    }
    
    public function testComment_Multiline() {
        var t = parse( tests["comment_Multiline"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Comment( value ):
                Assert.equals( 'rgb(241,89,34) - http://www.colorhexa.com/f15922\r\ncomplementary colour \r\nrgb(34,186,241) - http://www.colorhexa.com/22baf1', value );
                
            case _:
                
        }
    }
    
    public function testComment_MultiAsterisk() {
        var t = parse( tests["comment_MultiAsterisk"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Comment( value ):
                Assert.equals( '*\r\n* something\r\n\t* else\r\n * again', value );
                
            case _:
                
        }
    }
    
    public function testCommentTypeClass() {
        var t = parse( tests["commentTypeClass"].test );
        
        Assert.equals( 3, t.length );
        Assert.isTrue( t[0].match( Comment( 'comment1' ) ) );
        Assert.isTrue( t[2].match( Comment( 'comment2' ) ) );
        
        switch (t[1]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Group( [CssSelectors.Type( 'img' ), CssSelectors.Class( ['class'] )] ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'display', n );
                        Assert.equals( 'block', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
        
        var html = [for (i in t) parser.printHTML( i )].join('\r\n');
        var string = [for (i in t) parser.printString( i )].join('\r\n');
        
        //Assert.equals( '<span class="comment"><wbr>&shy;/*comment1*//*</span>\r\n<span class="keyword ruleset">img,\r\n.class {\r\n\t<span class="keyword declaration">display: block;</span>\r\n}</span>\r\n<span class="comment"><wbr>&shy;/*comment2*//*</span>', html );
        Assert.equals( '/*comment1*/\r\nimg,\r\n.class {\r\n\tdisplay: block;\r\n}\r\n/*comment2*/', string );
    }
    
    public function testChild() {
        var t = parse( tests["child"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Combinator( Type( 'a' ), Type( 'b' ), Child ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'display', n );
                        Assert.equals( 'block', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testSingleCharacters() {
        var t = parse( tests["singleCharacters"].test );
        
        Assert.equals( 1, t.length );
    }
    
    public function testDecimalValue() {
        var t = parse( tests["decimalValue"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Type( 'a' ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'b', n );
                        Assert.equals( '1.1', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testStringValue() {
        var t = parse( tests["stringValue"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Type( 'a' ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'b', n );
                        Assert.equals( '"/unicode0123456789!?"£$"', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testMultiValue() {
        var t = parse( tests["multiValue"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Type( 'a' ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'b', n );
                        Assert.equals( '1, 2, 3', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testAttributeSelector() {
        var t = parse( tests["attributeSelector"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Combinator(
                    CssSelectors.Type('a'),
                    Attribute('b', Exact, '/'),
                    None
                ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'c', n );
                        Assert.equals( 'd', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
        
        var html = parser.printHTML( t[0] );
        var string = parser.printString( t[0] );
        
        //Assert.equals( '<span class="keyword ruleset">a[b="/"] {\r\n\t<span class="keyword declaration">c: d;</span>\r\n}</span>', html );
        //Assert.equals( 'a[b="/"] {\r\n\tc: d;\r\n}', string );
    }
    
    public function testDeclarationComment() {
        var t = parse( tests["declarationComment"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.equals( 3, t.length );
                
                for (i in 0...t.length) switch (t[0]) {
                    case Comment(v) if (i == 0 || i == 2):
                        Assert.contains( v, ['c1', 'c:2;']);
                        
                    case Keyword(Declaration(n, v)) if (i == 1):
                        Assert.equals( 'b', n );
                        Assert.equals( '1', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testUniversalSelector() {
        var t = parse( tests["universalSelector"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Universal ) );
                Assert.equals( 1, t.length );
                
            case _:
                
        }
    }
    
    public function testNotPseduo() {
        var t = parse( tests["notPseduo"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                //trace( s );
                Assert.isTrue( s.match( Combinator(
                    Universal,
                    //Pseudo('not', '[type]'),
                    Pseudo('not', Combinator(Universal, Attribute('type', -1, ''), None)),
                    None
                ) ) );
                Assert.equals( 1, t.length );
                
            case _:
                
        }
    }
    
    public function testHaxeIoCss() {
        var t = parser.toTokens( ByteData.ofString( haxe.Resource.getString('haxe.io.css') ), 'haxe.io.css' );
        var comments = t.filter( function (t) return t.match( Comment(_) ) );
        var media = t.filter( function(t) return t.match( Keyword( AtRule(_, _, _) ) ) );
        var rules = t.filter( function(t) return t.match( Keyword( RuleSet(_, _) ) ) );
        var remainder = t.filter( function(t) return switch (t) {
            case Comment(_), Keyword( AtRule(_, _, _) ), Keyword( RuleSet(_, _) ): false;
            case _: true;
        } );
        
        Assert.equals( 0, remainder.length );
        Assert.equals( 10, comments.length );
        Assert.equals( 5, media.length );
        Assert.equals( 48, rules.length );
        Assert.equals( t.length, comments.length + media.length + rules.length );
    }
    
    public function testNormalizeCss() {
        var t = parser.toTokens( ByteData.ofString( haxe.Resource.getString('normalize.css') ), 'normalize.css' );
        var comments = t.filter( function (t) return t.match( Comment(_) ) );
        var media = t.filter( function(t) return t.match( Keyword( AtRule(_, _, _) ) ) );
        var rules = t.filter( function(t) return t.match( Keyword( RuleSet(_, _) ) ) );
        var remainder = t.filter( function(t) return switch (t) {
            case Comment(_), Keyword( AtRule(_, _, _) ), Keyword( RuleSet(_, _) ): false;
            case _: true;
        } );
        
        Assert.equals( 0, remainder.length );
        Assert.equals( 46, comments.length );
        Assert.equals( 0, media.length );
        Assert.equals( 40, rules.length );
        Assert.equals( t.length, comments.length + media.length + rules.length );
    }
    
    public function testCssVariables() {
        var t = parse( tests["cssVariables"].test );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( CssSelectors.Class( ['class'] ) ) );
                Assert.equals( 2, t.length );
                Assert.isTrue( t[0].match( Keyword( Declaration( '--my-colour', 'red' ) ) ) );
                Assert.isTrue( t[1].match( Keyword( Declaration( 'color', 'var(--my-colour)' ) ) ) );
                
            case _:
                
        }
    }
    
    public function testCommentInSelector() {
        var t = parse( tests["commentInSelector"].test );
        
        Assert.equals( 1, t.length );
        switch (t[0]) {
            case Keyword( RuleSet(s, t) ):
                Assert.isTrue( s.match( Group( [Type('a'), Type('b')] ) ) );
                
            case _:
                
        }
    }
    
    public function testCalc() {
        var t = parse( tests["calc"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword( RuleSet(s, t) ):
                Assert.isTrue( s.match( Type('a') ) );
                Assert.isTrue( t[0].match( Keyword( Declaration('height', 'calc(100px - 2em)') ) ) );
                
            case _:
                
        }
    }
    
    public function testAtRule() {
        var t = parse( tests["atRule"].test );
        
        switch (t[0]) {
            case Keyword( AtRule(n, q, t) ):
                Assert.equals( 'media', n );
                Assert.equals( 
                    '' + [Feature('all'), Feature('and'), CssMedia.Expr('min-width', '1156px')],
                    '' + q
                );
                Assert.equals( 1, t.length );
                
            case _:
                
        }
        
        Assert.equals( '@media all and (min-width: 1156px) {\r\n\ta {\r\n\t\tb: c;\r\n\t}\r\n}', parser.printString( t[0] ) );
        Assert.equals( '@media all and (min-width:1156px) {a{b:c;}}', parser.printString( t[0], true ) );
    }
    
    public function testAtRule_MultiExpr() {
        var t = parse( tests["atRule_MultiExpr"].test );
        
        switch (t[0]) {
            case Keyword( AtRule(n, q, t) ):
                Assert.equals( 'media', n );
                Assert.equals( 
                    '' + [CssMedia.Group([ 
                        [Feature('all'), Feature('and'), CssMedia.Expr('max-width', '699px'),
                        Feature('and'), CssMedia.Expr('min-width', '520px')],
                        [CssMedia.Expr('min-width', '1151px')]
                    ])],
                    '' + q
                );
                Assert.equals( 1, t.length );
                
            case _:
                
        }
        
        Assert.equals( '@media all and (max-width: 699px) and (min-width: 520px), (min-width: 1151px) {\r\n\ta {\r\n\t\tb: c;\r\n\t}\r\n}', parser.printString( t[0] ) );
        Assert.equals( '@media all and (max-width:699px) and (min-width:520px),(min-width:1151px) {a{b:c;}}', parser.printString( t[0], true ) );
    }
    
    public function testRuleSet_Multi() {
        var t = parse( tests["ruleSet_Multi"].test );
        
        Assert.equals( 2, t.length );
        
        for (i in 0...t.length) switch (t[i]) {
            case Keyword(RuleSet(s, t)) if (i == 0):
                Assert.isTrue( s.match( Type('a') ) );
                Assert.equals( 1, t.length );
                
            case Keyword(RuleSet(s, t)) if (i == 1):
                Assert.isTrue( s.match( Type('d') ) );
                Assert.equals( 1, t.length );
                
            case _:
                
        }
        
        Assert.equals( 'a {\r\n\tb: c;\r\n}\r\nd {\r\n\te: f;\r\n}', [for (i in t) parser.printString( i )].join('\r\n') );
        Assert.equals( 'a{b:c;}d{e:f;}', [for (i in t) parser.printString( i, true )].join('') );
    }
    
    public function testClassDeclaration_SpacedRuleSet() {
        var t = parse( tests["classDeclaration_SpacedRuleSet"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match( Combinator(CssSelectors.Class(['a']), 
                    Combinator(CssSelectors.Class(['b']),
                        Combinator(CssSelectors.Class(['c']), CssSelectors.Class(['d']), Descendant),
                        Descendant
                    ),
                    Descendant
                ) ) );
                
            case _:
        }
    }
    
    public function testClassDeclaration_ChainedRuleSet() {
        var t = parse( tests["classDeclaration_ChainedRuleSet"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match( CssSelectors.Class(['a', 'b', 'c', 'd']) ) );
                
            case _:
        }
    }
    
    public function testPseudo_JoinedRuleSet() {
        var t = parse( tests["pseudo_JoinedRuleSet"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match( Combinator(
                    CssSelectors.Type('a'),
                    Pseudo('first-child', null),
                    None
                ) ) );
                
            case _:
        }
    }
    
    public function testAttribute_JoinedRuleSet() {
        var t = parse( tests["attribute_JoinedRuleSet"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match( Combinator(
                    CssSelectors.Type('a'),
                    Attribute('name', -1, ''),
                    None
                ) ) );
                
            case _:
        }
    }
    
    public function testAttribute_Multiple() {
        var t = parse( tests["attribute_Multiple"].test );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match( Combinator(
                    CssSelectors.Type('a'),
                    Combinator( 
                        Attribute('one', AttributeType.Exact, 'hello'),
                        Combinator( Attribute('two', AttributeType.Contains, 'bob'), Attribute('three', AttributeType.DashList, '123'), None ),
                        None
                    ),
                    None
                ) ) );
                
            case _:
                Assert.fail();
        }
    }
    
    public function testPseudo_ExprInExpr_1() {
        var t = parse( tests["pseudo_ExprInExpr_1"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match( Combinator(
                    CssSelectors.Type('a'),
                    //Pseudo('not', ':has(ab, ac, ad)'),
                    Pseudo('not', 
                        Combinator(Universal, Pseudo('has', Group([Type('ab'), Type('ac'), Type('ad')])), None)
                    ),
                    None
                ) ) );
                
            case _:
                Assert.fail();
                
        }
    }
    
    public function testPseudo_ExprInExpr_2() {
        var t = parse( tests["pseudo_ExprInExpr_2"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match( 
                    Group( [ 
                        //Type('style'), Combinator(Type('link'), Pseudo('not', '[rel="import"]'), None),
                        Type('style'), 
                        Combinator(Type('link'), Pseudo('not', Combinator(Universal, Attribute('rel', Exact, 'import'), None)), None),
                        Type('meta'), Combinator(Type('script'), Attribute('async', Unknown, ''), None),
                        Combinator(Type('script'), Attribute('defer', Unknown, ''), None)
                    ] )
                ) );
                
            case _:
                Assert.fail();
                
        }
    }
    
    public function testPseudo_ExprInExpr_Silly() {
        var t = parse( tests["pseudo_ExprInExpr_Silly"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                //trace(s);
                Assert.isTrue( s.match( Combinator(
                    Type('a'),
                    //Pseudo('not', ':has(ab, ac, :not(bb, bc:has(cb cc, cd), bd))'),
                    Pseudo('not', 
                        Combinator(
                            Universal,
                            Pseudo('has', 
                                Group([
                                    Type('ab'), 
                                    Type('ac'), 
                                    Pseudo('not', 
                                        Group([
                                            Type('bb'), 
                                            Combinator(
                                                Type('bc'),
                                                Pseudo('has', Group([
                                                    Combinator(Type('cb'), Type('cc'), Descendant), 
                                                    Type('cd')
                                                ])),
                                                None
                                            ), 
                                            Type('bd')
                                        ])
                                    ),
                                ])
                            ),
                            None
                        )
                    ),
                    None
                ) ) );
                
            case _:
                Assert.fail();
                
        }
    }
    
    // CSS4 Relative Selectors
    
    public function testRelativeSelector_Child() {
        Lexer.scoped = true;
        var t = parse( tests["relativeSelector_Child"].test );
        Lexer.scoped = false;
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match(
                    Combinator( Universal, Combinator( Pseudo( 'scope' ), ID( 'A' ), Child ), None )
                ) );
                
            case _:
                Assert.fail();
                
        }
    }
    
    public function testRelativeSelector_Adjacent() {
        Lexer.scoped = true;
        var t = parse( tests["relativeSelector_Adjacent"].test );
        Lexer.scoped = false;
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match(
                    Combinator( Universal, Combinator( Pseudo( 'scope' ), ID( 'A' ), Adjacent ), None )
                ) );
                
            case _:
                Assert.fail();
                
        }
    }
    
    public function testRelativeSelector_General() {
        Lexer.scoped = true;
        var t = parse( tests["relativeSelector_General"].test );
        Lexer.scoped = false;
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match(
                    Combinator( Universal, Combinator( Pseudo( 'scope' ), ID( 'A' ), General ), None )
                ) );
                
            case _:
                Assert.fail();
                
        }
    }
    
    public function testRelativeSelector_Group() {
        Lexer.scoped = true;
        var t = parse( tests["relativeSelector_Group"].test );
        Lexer.scoped = false;
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                Assert.isTrue( s.match(
                    Group( [
                        // Currently parentless pseudo selectors dont always get prepended by Universal, but they should and will.
                        /*Combinator( Universal, Combinator(Pseudo('scope', ''), ID('ID'), Child), None ),
                        Combinator( Universal, Combinator(Pseudo('scope', ''), Class(['class']), Adjacent), None )*/
                        Combinator(Pseudo('scope'), ID('ID'), Child),
                        Combinator(Pseudo('scope'), Class(['class']), Adjacent)
                    ] )
                ) );
                
            case _:
                Assert.fail();
                
        }
    }
    
    public function testEscapedSequence_SingleCharacter() {
        var t = parse( tests["escapedSequence_SingleCharacter"].test );
        
        Assert.equals( 1, t.length );
        //Assert.equals( 'div\\+ {\r\n\ta: b;\r\n}', parser.printString( t[0] ) );
        //Assert.equals( 'div\\+{a:b;}', parser.printString( t[0], true ) );
    }
    
    public function testEscapedSequence_FullCharacters() {
        var t = parse( tests["escapedSequence_FullCharacters"].test );
        
        Assert.equals( 1, t.length );
        //Assert.equals( 'div\\!\\#\\$\\%\\&\\\'\\(\\)\\*\\+\\,\\-\\.\\/\\:\\;\\<\\=\\>\\?\\@\\[\\\\\\]\\^\\`\\{\\|\\}\\~ {\r\n\ta: b;\r\n}', parser.printString( t[0] ) );
        //Assert.equals( 'div\\!\\#\\$\\%\\&\\\'\\(\\)\\*\\+\\,\\-\\.\\/\\:\\;\\<\\=\\>\\?\\@\\[\\\\\\]\\^\\`\\{\\|\\}\\~{a:b;}', parser.printString( t[0], true ) );
    }
    
    public function testEscapedSequence_ShortUnicode() {	
        var t = parse( tests["escapedSequence_ShortUnicode"].test );
        
        Assert.equals( 1, t.length );
        //Assert.equals( 'div\\2b {\r\n\ta: b;\r\n}', parser.printString( t[0] ) );
        //Assert.equals( 'div\\2b{a:b;}', parser.printString( t[0], true ) );
    }
    
    public function testEscapedSequence_FullUnicode() {	
        var t = parse( tests["escapedSequence_FullUnicode"].test );
        
        Assert.equals( 1, t.length );
        //Assert.equals( 'div\\00002b {\r\n\ta: b;\r\n}', parser.printString( t[0] ) );
        //Assert.equals( 'div\\00002b{a:b;}', parser.printString( t[0], true ) );
    }
    
    public function testEscapedSequence_Attribute() {
        var t = parse( tests["escapedSequence_Attribute"].test );
        
        Assert.equals( 1, t.length );
        
        switch (t[0]) {
            case Keyword(RuleSet(s, t)):
                Assert.isTrue( s.match( Combinator(
                    CssSelectors.Type('div'),
                    Attribute('name\\+', -1, ''),
                    None
                ) ) );
                Assert.equals( 1, t.length );
                
                switch (t[0]) {
                    case Keyword(Declaration(n, v)):
                        Assert.equals( 'a', n );
                        Assert.equals( 'b', v );
                        
                    case _:
                        
                }
                
            case _:
                
        }
    }
    
    public function testPseudo_UniversalFix() {
        var t = parse( ':a :b :c { d:e; }' );	// Should be *:a *:b *:c { d:e; }
        
        switch (t[0]) {
            case Keyword(RuleSet(s, _)):
                switch s {
                    case Combinator(Universal, Pseudo(a, c), None):
                        Assert.equals(a, 'a');
                        
                        switch (cast c:CssSelectors) {
                            case Combinator(Universal, Pseudo(b, c), None):
                                Assert.equals(b, 'b');

                                switch (cast c:CssSelectors) {
                                    case Combinator(Universal, Pseudo(c, _), None):
                                        Assert.equals(c, 'c');

                                    case x:
                                        trace( x );
                                        Assert.fail();

                                }

                            case x:
                                trace( x );
                                Assert.fail();

                        }

                    case x:
                        trace( x );
                        Assert.fail();

                }
                
            case _:
                Assert.fail();
                
        }
    }
    
}