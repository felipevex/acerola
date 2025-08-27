package acerola.mig.command;

import haxe.Json;
import acerola.mig.data.MigData;
import acerola.mig.data.MigRunnerData;
import haxe.io.Path;
import anonstruct.AnonStruct;

using terminal.Terminal;

class MigCommandUp extends MigCommand {

    public var steps:Int = 0;

    override function run() {
        this.validatePath();
        this.healthCheck();
        // this.validateData();

        var data:MigRunnerData = this.createMigrationRunnerData();

        var app:String = 'node';
        var params:Array<String> = [
            Path.join([this.path, 'mig-runner/MigRunner.js']),
            Json.stringify(data)
        ];

        "   - Running Migration UP ".print(YELLOW);
        "".print();

        try {
            var out = Terminal.run(app, params, 10.0);
            if (out.code == 0) out.output.print();
            else {
                Sys.print(out.output);
            }
        } catch (e) {
            trace(e);
        }
    }

    override function validateData() {
        if (this.params == null || this.params.length <= 1) {
            this.steps = 0;
            return;
        }

        var validator:AnonStruct = new AnonStruct();
        validator
            .valueString()
            .refuseEmpty()
            .refuseNull()
            .allowChars('0123456789');

        try {
            validator.validate(this.params[1]);
        } catch (e:Dynamic) {
            trace(e);
            throw '<count> param has invalid value ${this.params[1]}. Should be integer >= 0.';
        }

        this.steps = Std.parseInt(this.params[1]);
    }


    public function createMigrationRunnerData():MigRunnerData {
        var data:MigData = this.getMigData();

        var result:MigRunnerData = {
            uuid: data.uuid,
            steps: []
        }

        for (step in data.migrations) {
            var sqlUp:String = this.loadStepData(step);

            result.steps.push({
                hash : step.hash,
                up : sqlUp
            });
        }

        return result;
    }
}