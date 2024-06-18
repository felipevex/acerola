package project.api.service.test;

import anonstruct.AnonStruct;
import acerola.server.service.AcerolaServerServiceRest;

class TestGetService extends AcerolaServerServiceRest<Dynamic> {
    
    override function setup() {
        this.paramsValidator = TestGetServiceDataValidator;
    }

    override function run() {
        var params:TestGetServiceData = this.req.params;        
        this.resultSuccess(params);
    }

}

private typedef TestGetServiceData = {
    var id:Int;
    var hello:String;
}

private class TestGetServiceDataValidator extends AnonStruct {

    public function new() {
        super();

        this.propertyInt('id').refuseNull().greaterThan(0);
        this.propertyString('hello').refuseNull().refuseEmpty();

    }

}