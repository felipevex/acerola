package acerola.server.service;

import acerola.server.error.AcerolaServerError;
import acerola.server.service.behavior.AcerolaServiceBehaviorDatabase;
import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;
import database.DatabaseSuccess;
import database.DatabaseError;
import database.DatabaseRequest;

class AcerolaServerDatabaseService<S> extends AcerolaServerServiceRest<S> {

    override function setupBehavior() {
        super.setupBehavior();
        this.behavior.addBehavior(AcerolaServiceBehaviorDatabase);
    }

    public function query<Q>(query:DatabaseRequest<Q>, onComplete:(success:DatabaseSuccess<Q>)->Void, onError:(error:DatabaseError)->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).query(
            query,
            onComplete,
            (err:DatabaseError) -> {
                if (onError == null) this.resultError(AcerolaServerError.SERVER_ERROR(err.message));
                else onError(err);
            }
        );
    }

    public function queryRun<Q>(query:DatabaseRequest<Q>, onComplete:()->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).queryRun(
            query,
            onComplete,
            this.resultError
        );
        
    }

    public function querySelectOne<Q>(query:DatabaseRequest<Q>, onRead:(data:Q)->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).querySelectOne(
            query,
            onRead,
            this.resultError
        );
    }

    public function querySelect<Q>(query:DatabaseRequest<Q>, protectFrom404:Bool, onRead:(data:Array<Q>)->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).querySelect(
            query,
            protectFrom404,
            onRead,
            this.resultError
        );
    }

    override function runBeforeResult(isSuccess:Bool, callback:() -> Void) {
        super.runBeforeResult(isSuccess, () -> {
            this.behavior.get(AcerolaServiceBehaviorDatabase).closeDatabaseTicket(callback, isSuccess);
        });
    }

    override function runAfterResult(isSuccess:Bool):Void {
        super.runAfterResult(isSuccess);
    }

}