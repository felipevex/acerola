package migration;

import haxe.crypto.Sha1;
import helper.maker.QueryMaker;
import util.kit.uuid.UUID;
using terminal.Terminal;
import node.mysql.Mysql;

class MigrationSupport {

    private var connection:MysqlConnection;

    public function new(connection:MysqlConnection) {
        this.connection = connection;
    }

    public function runSetup(onSuccess:()->Void, onError:(error:String)->Void):Void {
        Migration.print('Running migration setup...', GREEN);

        var query:String = '
            CREATE DATABASE IF NOT EXISTS `acerola_mig` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
            CREATE TABLE IF NOT EXISTS `acerola_mig`.`mig` (
                `uuid` CHAR(36) NOT NULL,
                `current` VARCHAR(1024) NOT NULL,
                `future` VARCHAR(1024) NOT NULL,
                PRIMARY KEY (`uuid`)
            )
            ENGINE=InnoDB;
        ';

        this.connection.queryResult(
            query,
            (error:MysqlError, result:MysqlResultSet<Dynamic>) -> {
                if (error == null) {
                    Migration.print('Migration setup completed successfully.', YELLOW);
                    onSuccess();
                    return;
                }

                Migration.print('Migration setup failed: ${error.message}', RED);
                onError(error.message);

            }
        );
    }

    public function readCurrentState(uuid:UUID, onSuccess:(currentState:Null<String>, futureState:Null<String>)->Void, onError:(error:String)->Void):Void {
        Migration.print('Reading current migration state for ${uuid}', GREEN);

        var query:String = QueryMaker.make(
            '
                SELECT
                    m.current,
                    m.future
                FROM acerola_mig.mig m
                WHERE m.uuid = :uuid
                ;
            ',
            {
                uuid : uuid.toString()
            },
            this.connection.escape
        );

        this.connection.queryResult(
            query,
            (error:MysqlError, result:MysqlResultSet<{current:String, future:String}>) -> {
                if (error == null) {
                    if (!result.hasNext()) {
                        Migration.print('Current Migration State: NONE', YELLOW);
                        onSuccess(null, null);
                        return;
                    }

                    var result = result.next();
                    var currentState:String = result.current;
                    var futureState:String = result.future;

                    Migration.print('Current Migration State: ${currentState}', YELLOW);
                    onSuccess(currentState, futureState);

                    return;
                }

                Migration.print('Read current state failed: ${error.message}', RED);
                onError(error.message);
                return;
            }
        );

    }

    public function updateCurrentState(uuid:UUID, hash:String, futureHash:String, onSuccess:()->Void, onError:(error:String)->Void):Void {
        Migration.print('${hash} -> Updating migration state', MAGENTA);

        var query:String = QueryMaker.make(
            '
                INSERT INTO acerola_mig.mig (`uuid`, `current`, `future`)
                VALUES (
                    :uuid,
                    :current,
                    :future
                )

                ON DUPLICATE KEY UPDATE
                    `current` = :current,
                    `future` = :future
                ;
            ',
            {
                uuid : uuid.toString(),
                current : hash,
                future : futureHash
            },
            this.connection.escape
        );

        this.connection.queryResult(
            query,
            (error:MysqlError, result:MysqlResultSet<Dynamic>) -> {
                if (error == null) {
                    Migration.print('${hash} -> Migration state updated', MAGENTA);
                    onSuccess();
                    return;
                }

                Migration.print('${hash} -> Update migration state failed: ${error.message}', RED);
                onError(error.message);
            }
        );

    }

    public function applyMigration(uuid:UUID, hash:String, sql:String, onSuccess:()->Void, onError:(error:String)->Void):Void {
        Migration.print('Applying migration ${hash}', GREEN);

        this.connection.queryResult(
            sql,
            (error:MysqlError, result:MysqlResultSet<Dynamic>) -> {
                if (error == null) {
                    Migration.print('${hash} -> Applied successfully', MAGENTA);
                    this.updateCurrentState(
                        uuid,
                        hash,
                        this.generateHash(
                            uuid,
                            hash,
                            sql
                        ),
                        onSuccess,
                        onError
                    );
                    return;
                }

                Migration.print('${hash} -> Migration failed: ${error.message}', RED);
                onError(error.message);
            }
        );
    }

    private function generateHash(uuid:UUID, lastHash:String, fileContent:String):String {
        var hash:String = Sha1.encode(uuid.toString() + lastHash + fileContent);
        return hash;
    }
}