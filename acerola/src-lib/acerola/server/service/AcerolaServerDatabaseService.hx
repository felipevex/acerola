package acerola.server.service;

import acerola.server.error.AcerolaRequestError;
import database.DatabaseSuccess;
import database.DatabaseError;
import database.DatabaseRequest;

class AcerolaServerDatabaseService<S> extends AcerolaServerServiceRest<S> {

    private var ticket:String;

    override function asyncInit(cb:(success:Bool) -> Void) {
        this.req.pool.getTicket((ticket:String) -> {
            // TODO : Validar situacao quando o ticket nao tiver sido criado com sucesso
            this.ticket = ticket;
            cb(true);
        });
    }

    public function query<Q>(query:DatabaseRequest, onComplete:(success:DatabaseSuccess<Q>)->Void, ?onError:(err:DatabaseError)->Void):Void {
        this.req.pool.query(
            this.ticket,
            query,
            onComplete,
            function(err:DatabaseError):Void {
                if (onError == null) AcerolaRequestError.SERVER_ERROR(err.message, this.resultError);
                else onError(err);
            }
        );
    }

    public function queryRun(query:DatabaseRequest, onComplete:()->Void):Void {
        this.query(
            query,
            function(success:DatabaseSuccess<Dynamic>):Void onComplete()
        );
    }

    public function querySelectOne<Q>(query:DatabaseRequest, onRead:(data:Q)->Void):Void this.querySelect(query, true, function(data:Array<Q>):Void onRead(data[0]));

    public function querySelect<Q>(query:DatabaseRequest, protectFrom404:Bool, onRead:(data:Array<Q>)->Void):Void {
        this.query(
            query,
            function(success:DatabaseSuccess<Q>):Void {
                if (protectFrom404 && success.length == 0) {
                    var error:String = 'Unable to find data: ${haxe.Json.stringify(query.data)}';
                    AcerolaRequestError.NOT_FOUND(error, this.resultError);
                } else {
                    var result:Array<Q> = [];
                    for (item in success.raw) result.push(item);
                    onRead(result);
                }
            }
        );
    }

    override function runAfterResult(isSuccess:Bool):Void {
        this.req.pool.closeTicket(this.ticket, !isSuccess);
        super.runAfterResult(isSuccess);
    }

}