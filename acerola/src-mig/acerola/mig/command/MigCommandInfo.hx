package acerola.mig.command;

import acerola.mig.data.MigStepData;
import acerola.mig.data.MigData;
using terminal.Terminal;

class MigCommandInfo extends MigCommand {

    override function run() {
        this.validateData();

        'Migration Information:'.print(YELLOW);
        '-- Path: ${this.getFullPath()}'.print(BLUE);

        var data:MigData = null;

        try {
            data = this.loadMigData();
            '-- ${data.migrations.length} migration steps found.'.print(BLUE);
        } catch (e) {
            '-- There is no migration initialized in this path.'.print(RED);
            return;
        }

        try {
            this.healthCheck();
            '-- All migration files are valid.'.print(BLUE);
        } catch (e) {
            '-- Migration files are corrupted: ${e}'.print(RED);
            return;
        }

        var futureHash:String = this.generateHash(
            data.uuid,
            data.migrations[data.migrations.length - 1].hash,
            this.loadStepData(data.migrations[data.migrations.length - 1])
        );

        '-- Future hash: ${futureHash}'.print(BLUE);
        ''.print();
    }
}