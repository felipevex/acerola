package acerola.server.service;

import helper.kits.StringKit;
import acerola.server.error.AcerolaServerError;
import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;

class AcerolaServerServiceRest<S> extends AcerolaServerService {

    public function new(req:AcerolaServerRequestData, res:AcerolaServerResponseData) {
        super(req, res);

        try {
            if (this.req.headers.exists('info') && StringKit.isEmpty(this.req.headers.get('info'))) {
                this.setup();
                this.runInfo();
                
                return;
            }

            this.setup();

        } catch (e:AcerolaServerError) {
            this.resultError(e);
            return;
        } catch (e:Dynamic) {
            this.resultError(AcerolaServerError.SERVER_ERROR(Std.string(e)));
            return;
        }

        this.behavior.reset();
        this.executeBehavior();
    }

    private function executeBehavior():Void {
        if (this.behavior.hasNext()) {
            this.behavior.next().start({
                onSuccess : this.executeBehavior,
                onError : this.resultError
            });
            
            return;
        }
        
        try {
            this.validate();
            this.run();
        } catch (e:AcerolaServerError) {
            this.resultError(e);
            return;
        } catch (e:Dynamic) {
            this.resultError(AcerolaServerError.SERVER_ERROR(Std.string(e)));
            return;
        }

    }

    public function resultHtml(data:String, status:Int = 200):Void this.result(data, status, 'text/html; charset=utf-8');
    public function resultSuccess(data:S, status:Int = 200):Void this.result(data, status, 'application/json');

    public function resultError(error:AcerolaServerError):Void {
        this.result(error, error.status, 'application/json');
    }

    override private function runAfterResult(isSuccess:Bool):Void {
        this.behavior.reset();
        for (b in this.behavior) b.teardown(isSuccess);
    }

    override function runTimeout() {
        this.resultError(AcerolaServerError.SERVER_TIMEOUT('Timeout'));
    }

}