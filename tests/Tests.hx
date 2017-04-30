package ;

typedef Tests = haxe.DynamicAccess<TestCase>;

typedef TestCase = {
    var test(default, never):String;
    @:optional var expected:Expected;
}

typedef Expected = {
    var pretty(default, never):String;
    var compact(default, never):String;
}