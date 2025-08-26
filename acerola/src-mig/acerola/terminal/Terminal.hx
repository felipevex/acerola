package acerola.terminal;

class Terminal {

    public static function colorizeRed(s:String):String return '${TerminalColor.RED}${s}${NC}';
    public static function colorizeGreen(s:String):String return '${TerminalColor.GREEN}${s}${NC}';
    public static function colorizeYellow(s:String):String return '${TerminalColor.YELLOW}${s}${NC}';
    public static function colorizeBlue(s:String):String return '${TerminalColor.BLUE}${s}${NC}';
    public static function colorizeMagenta(s:String):String return '${TerminalColor.MAGENTA}${s}${NC}';
    public static function colorizeCyan(s:String):String return '${TerminalColor.CYAN}${s}${NC}';

    static public function print(s:String, ?color:TerminalColor, ?breakLine:Bool = true):Void {
        if (color == null) Sys.print(s);
        else Sys.print('${color}${s}${NC}');

        if (breakLine) Sys.println('');
    }

    static public function printTitle(s:String, ?color:TerminalColor):Void {
        var result:String = '\n\n' + s + '\n\n';
        print(result, color);
    }

}

private enum abstract TerminalColor(String) {
    var RED = "\033[0;31m";
    var GREEN = "\033[0;32m";
    var YELLOW = "\033[0;33m";
    var BLUE = "\033[34m";
    var MAGENTA = "\033[0;35m";
    var CYAN = "\033[0;36m";
    var NC = "\033[0m";
}
