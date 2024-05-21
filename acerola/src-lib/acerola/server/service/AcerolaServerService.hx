package acerola.server.service;

import acerola.server.error.AcerolaRequestError;
import anonstruct.AnonStructError;
import anonstruct.AnonStruct;
import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;

class AcerolaServerService {

    private var req:AcerolaServerRequestData;
    private var res:AcerolaServerResponseData;

    private var bodyValidator:Class<AnonStruct>;
    
    public function new(req:AcerolaServerRequestData, res:AcerolaServerResponseData) {
        this.req = req;
        this.res = res;
        
        try {
            this.setup();
            this.validate();
            this.run();
        } catch (e:AcerolaRequestError) {
            this.resultError(e.toString(), e.status, e.toString());
        } catch (e:Dynamic) {
            this.resultError('Unexpected server error.', 500, Std.string(e));
        }
    }

    public function setup():Void {
        
    }

    public function validate():Void {
        this.validateBody();
    }

    public function validateBody():Void {
        if (this.bodyValidator == null) return;

        var body = this.req.body;
        var validator = Type.createInstance(this.bodyValidator, []);
        
        try {
            validator.validate(body);
        } catch (e:AnonStructError) {
            throw new AcerolaRequestError(400, 'Body', e.toString());
        } catch (e:Dynamic) {
            throw new AcerolaRequestError(500, 'Body', 'Undefined Error.');
        }
    }

    public function run():Void {
        throw 'Override run method.';
    }

    public function resultSuccess(data:Dynamic, status:Int = 200):Void {
        this.res.status = status;
        this.res.data = data;
        this.res.send();
    }

    public function resultError(message:String, status:Int = 500, internalMessage:String =  ''):Void {
        this.res.status = status;
        this.res.headers.set('Content-Type', 'application/json');
        
        this.res.data = {
            error : status, 
            error_message: message,
            internal_message : internalMessage
        };

        this.res.send();
    }


}