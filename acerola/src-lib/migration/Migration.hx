package migration;

import util.kit.uuid.UUID;
using terminal.Terminal;
import node.mysql.Mysql;
import database.DatabaseConnection;


class Migration {

    private var migrationUUID:UUID;
    private var migrationCurrentState:Null<String>;
    private var migrationFutureState:Null<String>;

    private var mysql:MysqlConnection;
    private var support:MigrationSupport;

    private var data:Array<{hash:String, sql:String}>;

    public function new(uuid:UUID) {
        this.data = [];
        this.migrationUUID = uuid;
    }

    static public function print(message:String, color):Void {
        'ACEROLA MIGRATION >> '.print(false);
        message.print(color);
    }

    public function connectDatabase(connection:DatabaseConnection, onSuccess:()->Void, onError:(error:String)->Void, ?maxRetry:Int = 5):Void {
        if (this.mysql == null) this.mysql = Mysql.createConnection({
            host : connection.host,
            user : connection.user,
            password : connection.password,
            port : connection.port,
            charset : 'utf8mb4',
            multipleStatements : true
        });

        this.mysql.connect((err:MysqlError) -> {
            if (err != null) {
                Migration.print('Database Connection Error: ${err.toString()}', RED);

                if (maxRetry < 1) {
                    Migration.print('Database Connection Error: Max retries reached.', RED);
                    onError("Max connection retries reached");
                }

                haxe.Timer.delay(this.connectDatabase.bind(connection, onSuccess, onError, maxRetry - 1), 2000);
                return;
            }

            Migration.print('Database connected!', GREEN);

            this.support = new MigrationSupport(this.mysql);
            this.runSupport(onSuccess, onError);
        });
    }

    private function runSupport(onSuccess:()->Void, onError:(error:String)->Void):Void {
        this.support.runSetup(
            this.runGetState.bind(onSuccess, onError),
            onError
        );
    }

    private function runGetState(onSuccess:()->Void, onError:(error:String)->Void):Void {
        this.support.readCurrentState(
            this.migrationUUID,
            (currentState:Null<String>, futureState:Null<String>) -> {
                this.migrationCurrentState = currentState;
                this.migrationFutureState = futureState;

                onSuccess();
        }, onError);
    }

    private function exit():Void {
        this.mysql.end();
        this.mysql = null;
    }

    public function add(hash:String, sql:String):Void {
        this.data.push({hash : hash, sql : sql});
    }

    public function up(onSuccess:()->Void, onFail:(error:String)->Void):Void {
        try {
            this.filterStates();
        } catch (e) {
            onFail(Std.string(e));
            return;
        }

        Migration.print('Starting Migration...', GREEN);
        this.runUp(onSuccess, onFail);
    }

    private function runUp(onSuccess:()->Void, onFail:(error:String)->Void):Void {
        if (this.data.length == 0) {
            Migration.print('Migration Done', BLUE);
            onSuccess();
            return;
        }

        this.executeMigration(this.data.shift(), onSuccess, onFail);
    }

    private function executeMigration(step:{hash:String, sql:String}, onSuccess:()->Void, onError:(error:String)->Void):Void {
        this.support.applyMigration(
            this.migrationUUID,
            step.hash,
            step.sql,
            this.runUp.bind(onSuccess, onError),
            onError
        );
    }

    private function filterStates():Void {
        if (this.migrationCurrentState == null) {
            Migration.print('First migration detected. Keeping all migration steps.', YELLOW);
            return;
        }

        var stateFound:Bool = false;

        while (!stateFound && this.data.length > 0) {
            if (this.migrationCurrentState != this.data[0].hash) {
                this.data.shift();
                continue;
            }

            if (this.migrationCurrentState == this.data[0].hash) {
                stateFound = true;
                this.data.shift();
                break;
            }
        }

        if (!stateFound) {
            Migration.print('There is no migration step with hash ${this.migrationCurrentState}.', RED);
            throw "Current migration step not found.";
        }

        if (this.data.length == 0) {
            Migration.print('All migrations are already applied.', GREEN);
            return;
        }

        var nextHash:String = this.data[0].hash;

        if (nextHash != this.migrationFutureState) {
            Migration.print('Expected next hash is ${this.migrationFutureState},', RED);
            Migration.print('but next migration step is ${nextHash}.', RED);
            Migration.print('Your last migration file may have been altered after being applied.', RED);

            throw 'Wrong migration hash.';
        }
    }

}