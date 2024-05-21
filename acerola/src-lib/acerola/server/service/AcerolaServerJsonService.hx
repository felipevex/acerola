package acerola.server.service;

import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;

class AcerolaServerJsonService<S> extends AcerolaServerService {

    public function new(req:AcerolaServerRequestData, res:AcerolaServerResponseData) {
        res.headers.set('Content-Type', 'application/json');
        
        super(req, res);
    }

    public function resultJson(data:S, status:Int = 200):Void {
        this.resultSuccess(data, status);
    }

}