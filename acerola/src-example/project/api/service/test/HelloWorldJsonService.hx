package project.api.service.test;

import acerola.server.service.AcerolaServerJsonService;

class HelloWorldJsonService extends AcerolaServerJsonService<{hello:String}> {

    override function run() {
        this.resultSuccess({hello : "world"});
    }

}