package acerola.mig;

import acerola.mig.command.MigCommandInfo;
import acerola.mig.command.MigCommandUp;
import acerola.mig.command.MigCommandCreate;
import acerola.mig.command.MigCommandInit;
import acerola.mig.command.MigCommandHelp;
import acerola.mig.enums.MigCommandType;
import acerola.mig.data.MigCommandData;

using terminal.Terminal;

class MigHelper {

    static public function main() {
        "Acerola Migration Helper".printTitle(GREEN);

        var mig:MigHelper = new MigHelper();

        try {
            mig.run();
        } catch (e) {
            var error:String = Std.string(e);
            error.print(RED);
            Sys.exit(1);
        }

        Sys.exit(0);
    }

    public function new() {

    }

    public function run():Void {
        var params:Array<String> = Sys.args();

        if (params.length == 0) params.push(Sys.getCwd());

        var data = this.getData(params);

        if (data.mig_command != "mig") return this.executeHelp(data);

        switch (data.command) {
            case HELP : return this.executeHelp(data);
            case INIT : return this.executeInit(data);
            case CREATE : return this.executeCreate(data);
            case UP : return this.executeUp(data);
            case INFO : return this.executeInfo(data);
            case _ : throw 'Invalid command ${data.command}';
        }
    }

    private function executeHelp(data:MigCommandData):Void {
        var command:MigCommandHelp = new MigCommandHelp(data.cur_path, data.params);
        command.run();
    }

    private function executeInit(data:MigCommandData):Void {
        var command:MigCommandInit = new MigCommandInit(data.cur_path, data.params);
        command.run();
    }

    private function executeCreate(data:MigCommandData):Void {
        var command:MigCommandCreate = new MigCommandCreate(data.cur_path, data.params);
        command.run();
    }

    private function executeUp(data:MigCommandData):Void {
        var command:MigCommandUp = new MigCommandUp(data.cur_path, data.params);
        command.run();
    }

    private function executeInfo(data:MigCommandData):Void {
        var command:MigCommandInfo = new MigCommandInfo(data.cur_path, data.params);
        command.run();
    }

    public function getData(params:Array<String>):MigCommandData {
        if (params.length == 0) throw "No parameters provided.";

        var cur_path:String = params.length == 0 ? "" : params.pop();
        var mig_command:String = params.length == 0 ?  "" : params.shift();
        var command:MigCommandType = params.length == 0 ? HELP : params.shift();
        var params:Array<String> = params.copy();

        return {
            cur_path: cur_path,
            mig_command : mig_command,
            command : command,
            params : params
        };
    }

}