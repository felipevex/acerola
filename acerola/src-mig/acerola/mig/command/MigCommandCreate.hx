package acerola.mig.command;

import acerola.mig.data.MigData;
import acerola.mig.data.MigData.MigStepData;
import haxe.crypto.Sha1;
using acerola.terminal.Terminal;

class MigCommandCreate extends MigCommand {

    override function run() {
        this.validatePath();

        var path:String = this.getFullPath();
        var local:String = this.getLocalPath();

        'MIGRATION CREATE'.print(YELLOW);

        // 1. Carregar e validar migration.json (MigRunnerData)
        var data:MigData = this.stepValidationMigrationFile();

        // 2. Criar os arquivos de migração
        this.printStep('Creating migration files');

        try {
            var lastStep = data.migrations[data.migrations.length - 1];
            var lastStepContent = this.loadStepData(lastStep);
            var hash:String = Sha1.encode(lastStep.hash + lastStepContent);
            var newStepFile:String = this.createNewMigStepKey();

            data.migrations.push({
                hash: hash,
                file: newStepFile
            });

            this.createMigRunnerFile(data);
            this.createMigrationUpFile(newStepFile);
        } catch (e) {
            this.checkHasError('Failed to create migration files: ${e}');
        }

        this.checkSuccess();
    }
}