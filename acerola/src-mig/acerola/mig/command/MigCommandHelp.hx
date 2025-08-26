package acerola.mig.command;

using acerola.terminal.Terminal;

class MigCommandHelp extends MigCommand {

    override function validateData() {
        if (params.length > 0) throw 'Help command does not accept parameters -> ${params.join(' ')}';
    }

    override function run():Void {
        this.validateData();

        var message:String = '';
        message += 'usage: haxelib run acerola mig help\n'.colorizeYellow();
        message += 'usage: haxelib run acerola mig init <path>\n'.colorizeYellow();
        message += 'usage: haxelib run acerola mig create <path>\n'.colorizeYellow();
        message += 'usage: haxelib run acerola mig info <path>\n'.colorizeYellow();
        message += 'usage: haxelib run acerola mig up <path> [<count>]\n'.colorizeYellow();
        message += 'usage: haxelib run acerola mig down <path> [<count>]\n'.colorizeYellow();

        message += '\n\n';
        message += 'Available commands:\n'.colorizeMagenta();
        message += '    ${'help'.colorizeCyan()}         - Show this help message\n';
        message += '    ${'init'.colorizeCyan()}         - Initialize migration in the specified path\n';
        message += '    ${'create'.colorizeCyan()}       - Create a new migration file\n';
        message += '    ${'info'.colorizeCyan()}         - Show information about the migration\n';
        message += '    ${'up'.colorizeCyan()} <count>   - Apply the migration\n';
        message += '                       param count: The number of times to apply the migration (default: 0)\n';
        message += '                       0 means apply all pending migrations\n';
        message += '    ${'down'.colorizeCyan()} <count> - Rollback the migration\n';
        message += '                       param count: The number of times to rollback the migration (default: 1)\n';
        message += '                       1 means rollback only the last migration\n';

        message.print();
    }
}