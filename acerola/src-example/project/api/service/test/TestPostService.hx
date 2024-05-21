package project.api.service.test;

import acerola.server.service.AcerolaServerJsonService;

class TestPostService extends AcerolaServerJsonService<Dynamic> {
    
    override function run() {
        var data:Dynamic = this.req.body;
        
        this.res.data = data;
        this.res.status = 200;
        this.res.send();
    }

}