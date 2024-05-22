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
    }

    public function asyncInit(cb:(success:Bool)->Void):Void {
        haxe.Timer.delay(cb.bind(true), 0);
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

    public function runTimeout():Void {
        
    }
    
    private function result(data:Dynamic, status:Int, contentType:String):Void {
        this.res.headers.set('Content-Type', contentType);
        this.res.status = status;
        this.res.data = data;
        this.res.send();
    }

}