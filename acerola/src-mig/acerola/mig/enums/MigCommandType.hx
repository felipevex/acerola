package acerola.mig.enums;

enum abstract MigCommandType(String) from String to String {

    var HELP = 'help';
    var INIT = 'init';
    var CREATE = 'create';
    var INFO  = 'info';
    var UP = 'up';

}