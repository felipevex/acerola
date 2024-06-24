package acerola.server.service;

import acerola.server.service.behavior.AcerolaServiceBehaviorDatabase;
import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;
import database.DatabaseSuccess;
import database.DatabaseError;
import database.DatabaseRequest;

class AcerolaServerDatabaseService<S> extends AcerolaServerServiceRest<S> {

    private var ticket:String;

    public function new(req:AcerolaServerRequestData, res:AcerolaServerResponseData) {
        super(req, res);
    }

    override function setup() {
        super.setup();
        this.behavior.addBehavior(AcerolaServiceBehaviorDatabase);
    }

    public function query<Q>(query:DatabaseRequest, onComplete:(success:DatabaseSuccess<Q>)->Void, ?onError:(err:DatabaseError)->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).query(
            this.resultError,
            query,
            onComplete,
            onError
        );
    }

    public function queryRun(query:DatabaseRequest, onComplete:()->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).queryRun(
            this.resultError,
            query,
            onComplete
        );
        
    }

    public function querySelectOne<Q>(query:DatabaseRequest, onRead:(data:Q)->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).querySelectOne(
            this.resultError,
            query,
            onRead
        );
    }

    public function querySelect<Q>(query:DatabaseRequest, protectFrom404:Bool, onRead:(data:Array<Q>)->Void):Void {
        this.behavior.get(AcerolaServiceBehaviorDatabase).querySelect(
            this.resultError,
            query,
            protectFrom404,
            onRead
        );
    }

    override function runAfterResult(isSuccess:Bool):Void {
        this.req.pool.closeTicket(this.ticket, !isSuccess);
        super.runAfterResult(isSuccess);
    }

}