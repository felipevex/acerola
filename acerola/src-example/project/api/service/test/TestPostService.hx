package project.api.service.test;

import acerola.server.service.AcerolaServerServiceRest;

class TestPostService extends AcerolaServerServiceRest<Dynamic> {
    
    override function run() {
        var data:Dynamic = this.req.body;
        this.resultSuccess(data);
    }

}