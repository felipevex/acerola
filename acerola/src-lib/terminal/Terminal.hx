package terminal;

import sys.io.Process;
import haxe.io.BytesOutput;
import haxe.io.Bytes;

class Terminal {

    public static function colorizeRed(s:String):String return '${TerminalColor.RED}${s}${NC}';
    public static function colorizeGreen(s:String):String return '${TerminalColor.GREEN}${s}${NC}';
    public static function colorizeYellow(s:String):String return '${TerminalColor.YELLOW}${s}${NC}';
    public static function colorizeBlue(s:String):String return '${TerminalColor.BLUE}${s}${NC}';
    public static function colorizeMagenta(s:String):String return '${TerminalColor.MAGENTA}${s}${NC}';
    public static function colorizeCyan(s:String):String return '${TerminalColor.CYAN}${s}${NC}';

    public static function printContext(context:String, message:String):Void {
        Sys.println('   ${context.toUpperCase()} : ${message}');
    }

    static public function print(s:String, ?color:TerminalColor, ?breakLine:Bool = true):Void {
        if (color == null) Sys.print(s);
        else Sys.print('${color}${s}${NC}');

        if (breakLine) Sys.println('');
    }

    static public function printTitle(s:String, ?color:TerminalColor):Void {
        var result:String = '\n\n' + s + '\n\n';
        print(result, color);
    }

    public static function run(processPath:String, args:Array<String>, timeoutSeconds:Float = 1.0) {

        var isDone:Bool = false;
        var exitCode:Int = -1;

        var outp:BytesOutput = new BytesOutput();
        var oute:BytesOutput = new BytesOutput();

        var runProcess:()->Void = () -> {
            var loading:Bool = true;
            var process:Process = new Process(processPath, args);

            while (loading) {
                try {
                    var current:Bytes = process.stdout.readAll(1024);
                    outp.write(current);
                    if (current.length == 0) loading = false;

                } catch (e:Dynamic) {
                    loading = false;
                }
            }

            exitCode = process.exitCode();

            if (exitCode != 0 && process.stderr != null) {
                oute.write(process.stderr.readAll());
            }

            process.close();
            process = null;

            isDone = true;
        };

        runProcess();

        if (exitCode != 0) return {
            message : "Process failed",
            code : exitCode,
            output : outp.getBytes().toString(),
            out_err: oute.getBytes().toString()
        } else return {
            message : "Success",
            code : 0,
            output : outp.getBytes().toString(),
            out_err : null
        }
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
