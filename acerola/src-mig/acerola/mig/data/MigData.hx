package acerola.mig.data;

import util.kit.uuid.UUID;
import acerola.mig.data.MigStepData.MigStepDataValidator;
import anonstruct.AnonStruct;

typedef MigData = {
    var uuid:UUID;
    var migrations:Array<MigStepData>;
}

class MigDataValidator extends AnonStruct {

    public function new() {
        super();

        this.propertyString('uuid')
            .refuseEmpty()
            .refuseNull()
            .addValidation((value:String) -> {
                if (!UUID.isValid(value)) throw 'Invalid UUID';
            });

        this.propertyArray('migrations')
            .refuseNull()
            .minLen(1)
            .setStructClass(MigStepDataValidator);

    }
}