package acerola.server.service;

import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;
import acerola.server.error.AcerolaRequestError;
import acerola.model.AcerolaResponseError;

class AcerolaServerServiceRest<S> extends AcerolaServerService {

    public function new(req:AcerolaServerRequestData, res:AcerolaServerResponseData) {
        super(req, res);

        try {
            this.setup();
        } catch (e:AcerolaRequestError) {
            this.resultError(e.toString(), e.status, e.internal);
            return;
        } catch (e:Dynamic) {
            this.resultError('Unexpected server error.', 500, Std.string(e));
            return;
        }

        this.behavior.reset();
        this.executeBehavior();
    }

    private function executeBehavior():Void {
        if (!this.behavior.hasNext()) {
            try {
                this.validate();
                this.run();
            } catch (e:AcerolaRequestError) {
                this.resultError(e.toString(), e.status, e.internal);
            } catch (e:Dynamic) {
                this.resultError('Unexpected server error.', 500, Std.string(e));
            }

            return;
        }
        
        var b = this.behavior.next();
        
        b.start({
            onSuccess : this.executeBehavior,
            onError : this.onBehaviorError
        });
    }

    private function onBehaviorError(error:AcerolaResponseError):Void this.result(error, error.status, 'application/json');

    public function resultHtml(data:String, status:Int = 200):Void this.result(data, status, 'text/html; charset=utf-8');
    public function resultSuccess(data:S, status:Int = 200):Void this.result(data, status, 'application/json');

    public function resultError(message:String, status:Int, internalMessage:String):Void {
        var error:AcerolaResponseError = {
            status : status,
            message : message,
            error_code : '000',
            internal : internalMessage
        }
        
        this.result(error, status, 'application/json');
        this.runAfterResult(false);
    }

    override private function runAfterResult(isSuccess:Bool):Void {
        this.behavior.reset();
        for (b in this.behavior) b.teardown(isSuccess);
    }

    override function runTimeout() {
        AcerolaRequestError.SERVER_TIMEOUT('Timeout', this.resultError);
    }

}