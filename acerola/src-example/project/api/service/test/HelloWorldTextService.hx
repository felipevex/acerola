package project.api.service.test;

import acerola.server.service.AcerolaServerService;

class HelloWorldTextService extends AcerolaServerService {

    override function run() {
        this.resultSuccess({hello : "world"});
    }

}