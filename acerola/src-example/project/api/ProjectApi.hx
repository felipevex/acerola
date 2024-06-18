package project.api;

import project.api.service.test.TestGetService;
import project.api.service.test.TestDatabaseService;
import database.DatabaseConnection;
import project.api.service.test.TestTimeoutService;
import project.api.service.test.TestPostService;
import project.api.service.test.HelloWorldTextService;
import project.api.service.test.HelloWorldJsonService;
import acerola.server.model.AcerolaServerVerbsType;
import acerola.server.AcerolaServer;

class ProjectApi {
    
    static public function main() {

        var connection:DatabaseConnection = {
            host : 'mysql',
            user : 'root',
            password : 'mysql_root_password',
            port : 3306,
            max_connections: 64
        }
        
        var server:AcerolaServer = new AcerolaServer(connection);
        
        server.route.registerService(AcerolaServerVerbsType.GET, '/v1/hello-world-json', HelloWorldJsonService);
        server.route.registerService(AcerolaServerVerbsType.GET, '/v1/hello-world-text', HelloWorldTextService);
        server.route.registerService(AcerolaServerVerbsType.POST, '/v1/test-post', TestPostService);
        server.route.registerService(AcerolaServerVerbsType.POST, '/v1/timeout', TestTimeoutService);
        server.route.registerService(AcerolaServerVerbsType.GET, '/v1/database', TestDatabaseService);
        server.route.registerService(AcerolaServerVerbsType.GET, '/v1/test-get/[id:Int]/[hello:String]', TestGetService);
        
        
        server.start();
        
    }
}