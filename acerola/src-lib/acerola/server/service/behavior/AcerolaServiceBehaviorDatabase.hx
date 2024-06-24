package acerola.server.service.behavior;

import database.DatabaseSuccess;
import acerola.server.error.AcerolaRequestError;
import database.DatabaseError;
import database.DatabaseRequest;
import acerola.model.AcerolaCallback;
import acerola.server.behavior.AcerolaBehavior;

class AcerolaServiceBehaviorDatabase extends AcerolaBehavior {

    private var ticket:String;

    override function start(cb:AcerolaCallback) {
        this.req.pool.getTicket((ticket:String) -> {
            // TODO : Validar situacao quando o ticket nao tiver sido criado com sucesso
            this.ticket = ticket;

            cb.onSuccess();
        });
    }

    override function teardown(isSuccess:Bool):Void {
        this.req.pool.closeTicket(this.ticket, !isSuccess);
    }

    public function query<Q>(serverErrorCallback, query:DatabaseRequest, onComplete:(success:DatabaseSuccess<Q>)->Void, ?onError:(err:DatabaseError)->Void):Void {
        this.req.pool.query(
            this.ticket,
            query,
            onComplete,
            function(err:DatabaseError):Void {
                if (onError == null) AcerolaRequestError.SERVER_ERROR(err.message, serverErrorCallback);
                else onError(err);
            }
        );
    }

    public function queryRun(serverErrorCallback, query:DatabaseRequest, onComplete:()->Void):Void {
        this.query(
            serverErrorCallback,
            query,
            function(success:DatabaseSuccess<Dynamic>):Void onComplete()
        );
    }

    public function querySelectOne<Q>(serverErrorCallback, query:DatabaseRequest, onRead:(data:Q)->Void):Void this.querySelect(serverErrorCallback, query, true, function(data:Array<Q>):Void onRead(data[0]));

    public function querySelect<Q>(serverErrorCallback, query:DatabaseRequest, protectFrom404:Bool, onRead:(data:Array<Q>)->Void):Void {
        this.query(
            serverErrorCallback,
            query,
            function(success:DatabaseSuccess<Q>):Void {
                if (protectFrom404 && success.length == 0) {
                    var error:String = 'Unable to find data: ${haxe.Json.stringify(query.data)}';
                    AcerolaRequestError.NOT_FOUND(error, serverErrorCallback);
                } else {
                    var result:Array<Q> = [];
                    for (item in success.raw) result.push(item);
                    onRead(result);
                }
            }
        );
    }
}