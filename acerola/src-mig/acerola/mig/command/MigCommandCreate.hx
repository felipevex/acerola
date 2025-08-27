package acerola.mig.command;

import acerola.mig.data.MigData;
using terminal.Terminal;

class MigCommandCreate extends MigCommand {

    override function run() {
        this.validatePath();
        this.healthCheck();

        var path:String = this.getFullPath();
        var local:String = this.getLocalPath();

        'MIGRATION CREATE'.print(YELLOW);

        // 1. Carregar e validar migration.json (MigRunnerData)
        var data:MigData = this.getMigData();

        // 2. Criar os arquivos de migração
        this.printStep('Creating migration files');

        try {
            var lastStep = data.migrations[data.migrations.length - 1];
            var lastStepContent = this.loadStepData(lastStep);
            var hash:String = this.generateHash(data.uuid, lastStep.hash, lastStepContent);
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