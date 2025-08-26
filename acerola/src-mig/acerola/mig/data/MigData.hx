package acerola.mig.data;

import anonstruct.AnonStruct;

typedef MigData = {
    var migrations:Array<MigStepData>;
}

class MigDataValidator extends AnonStruct {

    public function new() {
        super();

        this.propertyArray('migrations')
            .refuseNull()
            .minLen(1)
            .setStructClass(MigStepDataValidator);

    }
}

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