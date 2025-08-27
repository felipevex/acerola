package acerola.mig.data;

import anonstruct.AnonStruct;

typedef MigRunnerStepData = {
    var up:String;
    var hash:String;
}

class MigRunnerStepDataValidator extends AnonStruct {

    public function new() {
        super();

        this.propertyString('up')
            .refuseNull()
            .refuseEmpty();

        this.propertyString('hash')
            .refuseNull()
            .refuseEmpty();
    }
}