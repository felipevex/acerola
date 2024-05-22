package acerola.test.api.database;

class AcerolaDatabaseTest extends ApiTest {
    
    public function new() {
        super("Database Test");
    }

    override function setup() {
        this.api.makeRequest('Run Database Test')
        .GETting('#url/v1/database')
        .mustPass()
        .makeDataAsserts({test:1});
    }
}