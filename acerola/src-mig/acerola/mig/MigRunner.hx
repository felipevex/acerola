package acerola.mig;

import migration.Migration;
import database.DatabaseConnection;


class MigRunner {

    static public function main() new MigRunner();

    private var mig:Migration;

    public function new() {
        var connection:DatabaseConnection = {
            host : Sys.getEnv('MIGRATION-HOST'),
            user : Sys.getEnv('MIGRATION-USER'),
            password : Sys.getEnv('MIGRATION-PASSWORD'),
            auto_json_parse : true,
            port : Std.parseInt(Sys.getEnv('MIGRATION-PORT'))
        }

        this.mig = new Migration();
        this.mig.connectDatabase(connection, this.onConnected);
    }

    private function onConnected():Void {

    }
}