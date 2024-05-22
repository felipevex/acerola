package project.api.service.test;

import database.DatabaseRequest;
import acerola.server.service.AcerolaServerDatabaseService;

class TestDatabaseService extends AcerolaServerDatabaseService<{test:Int}> {
    
    override public function run():Void {
        var query:DatabaseRequest = {
            query : 'Select 1 as test'
        }

        this.querySelectOne(query, (data:{test:Int}) -> {
            this.resultSuccess(data);
        });
    }

}