package acerola.mig.data;

import anonstruct.AnonStruct;

typedef MigRunnerStepData = {
    var up_file:String;
    var hash:String;
}

class MigRunnerStepDataValidator extends AnonStruct {

    public function new() {
        super();

        this.propertyString('up_file')
            .refuseNull()
            .refuseEmpty();

        this.propertyString('hash')
            .refuseNull()
            .refuseEmpty();
    }
}