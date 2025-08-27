package acerola.mig;

import haxe.Json;
import acerola.mig.data.MigRunnerData;
import migration.Migration;
import database.DatabaseConnection;


class MigRunner {

    static public function main() new MigRunner();

    private var mig:Migration;

    public var data:MigRunnerData;

    public function new() {
        var args:Array<String> = Sys.args();

        if (args.length == 0) return;

        try {
            var runnerJson:String = args[0];
            this.data = Json.parse(runnerJson);

            var validator:MigRunnerDataValidator = new MigRunnerDataValidator();
            validator.validate(this.data);

        } catch (e) {
            Sys.stderr().writeString('Input inválido: ${e}\n');
            Sys.exit(1);
        }

        var connection:DatabaseConnection = {
            host : Sys.getEnv('MIGRATION_HOST'),
            user : Sys.getEnv('MIGRATION_USER'),
            password : Sys.getEnv('MIGRATION_PASSWORD'),
            port : Std.parseInt(Sys.getEnv('MIGRATION_PORT')),
            auto_json_parse : true
        }

        this.mig = new Migration(this.data.uuid);
        for (step in this.data.steps) this.mig.add(step.hash, step.up);

        this.mig.connectDatabase(
            connection,
            this.mig.up.bind(this.onSuccess, this.onError),
            onError
        );
    }

    private function onSuccess():Void {
        Sys.exit(0);
    }

    private function onError(error:String) {

        Sys.stderr().writeString(error);
        Sys.exit(1);
    }
}