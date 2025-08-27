package acerola.mig.command;

import util.kit.uuid.UUID;
import acerola.mig.data.MigData;
import haxe.io.Path;
import haxe.Json;
import sys.io.File;
import haxe.crypto.Sha1;
import sys.FileSystem;
using acerola.terminal.Terminal;

class MigCommandInit extends MigCommand {

    override function run() {
        this.validatePath();

        var path:String = this.getFullPath();
        var local:String = this.getLocalPath();

        'MIGRATION INIT'.print(YELLOW);

        // 1. Verificar se a pasta informada está vazia
        this.printStep('Verify if path ${local} is empty');
        if (FileSystem.readDirectory(path).length > 0) this.checkHasError('Path is not empty. Please, remove all files and folders from the path before running this command.');
        else this.checkSuccess();

        // 2. Criar Arquivo de Migração
        this.printStep('Starting migration files');

        var migStepFile:String = this.createNewMigStepKey();

        var migData:MigData = {
            uuid : UUID.createRandom(),
            migrations : [
                {
                    hash : Sha1.encode(''),
                    file : migStepFile
                }
            ]
        }

        this.createMigRunnerFile(migData);

        this.createMigrationUpFile(migStepFile);
        this.checkSuccess();

        ''.print();
        'INIT DONE'.print(BLUE);
    }


}