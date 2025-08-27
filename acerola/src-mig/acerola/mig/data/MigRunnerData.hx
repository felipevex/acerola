package acerola.mig.data;

import acerola.mig.data.MigRunnerStepData;
import anonstruct.AnonStruct;
import util.kit.uuid.UUID;

typedef MigRunnerData = {
    var uuid:UUID;
    var steps:Array<MigRunnerStepData>;
}

class MigRunnerDataValidator extends AnonStruct {

    public function new() {
        super();

        this.propertyString('uuid')
            .refuseNull()
            .refuseEmpty()
            .addValidation((value:String) -> {
                if (!UUID.isValid(value)) throw 'Invalid UUID format';
            });

        this.propertyArray('steps')
            .refuseNull()
            .minLen(1)
            .setStructClass(MigRunnerStepDataValidator)
        ;
    }
}