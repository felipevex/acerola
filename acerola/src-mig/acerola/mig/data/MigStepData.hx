package acerola.mig.data;

import anonstruct.AnonStruct;

typedef MigStepData = {
    var hash:String;
    var file:String;
}

class MigStepDataValidator extends AnonStruct {

    public function new() {
        super();

        this.propertyString('hash')
            .refuseNull()
            .refuseEmpty();

        this.propertyString('file')
            .refuseNull()
            .refuseEmpty();
    }
}