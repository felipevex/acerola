package acerola.mig.data;

import acerola.mig.enums.MigCommandType;

typedef MigCommandData = {
    var mig_command:String;
    var cur_path:String;
    var command:MigCommandType;
    var params:Array<String>;
}