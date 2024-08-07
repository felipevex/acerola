package acerola.test.api.database;

class AcerolaDatabaseTest extends ApiTest {
    
    public function new() {
        super("Database Test");
    }

    override function setup() {
        
        this.api.makeRequest('Run Database Test')
        .POSTing('#url/v1/database')
        .sendingJsonData(haxe.Json.stringify({
            query : 'Select 1 as test',
            data : null
        }))
        .mustPass()
        .makeDataAsserts({test:1});


        this.api.makeRequest('Run Database Test')
        .POSTing('#url/v1/database')
        .sendingJsonData(haxe.Json.stringify({
            query : 'Select 2 as test',
            data : null
        }))
        .mustPass()
        .makeDataAsserts({test:2});


        this.api.makeRequest('Run Database Test')
        .POSTing('#url/v1/database')
        .sendingJsonData(haxe.Json.stringify({
            query : 'wrong query',
            data : null
        }))
        .mustPass()
        .makeDataAsserts({
            code : "ER_PARSE_ERROR",
            query : "wrong query"
        });

    }

}