package acerola.server.service;

import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;
import acerola.server.error.AcerolaRequestError;
import acerola.model.AcerolaResponseError;

class AcerolaServerServiceRest<S> extends AcerolaServerService {

    public function new(req:AcerolaServerRequestData, res:AcerolaServerResponseData) {
        super(req, res);

        this.asyncInit((success:Bool) -> {
            try {
                this.setup();
                this.validate();
                this.run();
            } catch (e:AcerolaRequestError) {
                this.resultError(e.toString(), e.status, e.internal);
            } catch (e:Dynamic) {
                this.resultError('Unexpected server error.', 500, Std.string(e));
            }
        });
    }

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

    override function runTimeout() {
        AcerolaRequestError.SERVER_TIMEOUT('Timeout', this.resultError);
    }

}