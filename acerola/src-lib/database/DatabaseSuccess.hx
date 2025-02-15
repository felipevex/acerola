package database;

import node.mysql.Mysql.MysqlResultSet;

typedef DatabaseSuccess<T> = {
    var hasCreatedSomething:Bool;
    var hasUpdatedSomething:Bool;
    var hasAffectedSomething:Bool;
    
    var createdId:Int;

    var length:Int;
    var raw:MysqlResultSet<T>;
}
