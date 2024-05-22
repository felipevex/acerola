package project.api;

import project.api.service.test.TestTimeoutService;
import project.api.service.test.TestPostService;
import project.api.service.test.HelloWorldTextService;
import project.api.service.test.HelloWorldJsonService;
import acerola.server.model.AcerolaServerVerbsType;
import acerola.server.AcerolaServer;

class ProjectApi {
    
    static public function main() {
        
        var server:AcerolaServer = new AcerolaServer();
        
        server.route.registerService(AcerolaServerVerbsType.GET, '/v1/hello-world-json', HelloWorldJsonService);
        server.route.registerService(AcerolaServerVerbsType.GET, '/v1/hello-world-text', HelloWorldTextService);
        server.route.registerService(AcerolaServerVerbsType.POST, '/v1/test-post', TestPostService);
        server.route.registerService(AcerolaServerVerbsType.POST, '/v1/timeout', TestTimeoutService);
        
        server.start();
        
    }
}