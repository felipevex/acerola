package acerola.test.unit.database;

import database.DatabasePool;
import helper.kits.StringKit;

class Database9PoolTest extends DatabasePoolTest {

    override function setup() {
        this.testTable = 'test_${StringKit.generateRandomHex(6)}';

        this.connection = {
            host : 'mysql9',
            user : 'root',
            password : 'mysql_root_password',
            port : 3306,
            max_connections : 3,
            acquire_timeout : 150
        }

        this.pool = new DatabasePool(this.connection);
    }

}
