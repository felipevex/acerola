package acerola.test.api.info;

class AcerolaGetInfoTest extends ApiTest {
    
    public function new() {
        super('Get Test');
    }
    override function setup() {
        this.api.makeRequest('Run info from Get Test')
        .GETting('#url/v1/test-get/1/world')
        .sendingHeader('info', '')
        .mustPass()
        .makeDataAsserts({
            className : "project.api.service.test.TestGetService",
            verb : "GET",
            body : {},
            params : {
                hello : "world",
                id : 1
            }
        });
    }

}