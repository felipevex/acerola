package acerola.server.route;

import database.DatabaseConnection;
import database.DatabasePool;
import acerola.request.AcerolaPath;
import datetime.DateTime;
import helper.kits.StringKit;
import haxe.ds.StringMap;
import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;
import node.express.Response;
import node.express.Request;
import acerola.server.service.AcerolaServerService;
import acerola.server.model.AcerolaServerVerbsType;
import node.express.Application;

class AcerolaRoute {

    private var express:Application;
    private var database:DatabasePool;

    public function new(express:Application, connection:DatabaseConnection) {
        this.express = express;

        if (connection != null) this.database = new DatabasePool(connection);
    }

    // TIP : Use /my/route/[id:Int]/[name:String]
    public function registerService(verb:AcerolaServerVerbsType, route:AcerolaPath, service:Class<AcerolaServerService>):Void {
        Sys.println('ROUTE - ${verb} ${route} ${Type.getClassName(service)}');

        var routeCleaned:String = route.cleanPath;
        
        switch (verb) {
            case AcerolaServerVerbsType.GET : this.express.get(routeCleaned, this.serviceRunner.bind(verb, route, service, _, _));
            case AcerolaServerVerbsType.POST : this.express.post(routeCleaned, this.serviceRunner.bind(verb, route, service, _, _));
        }

    }

    private function serviceRunner(verb:AcerolaServerVerbsType, route:AcerolaPath, service:Class<AcerolaServerService>, xreq:Request, xres:Response):Void {
        
        var serviceInstance:AcerolaServerService;
        
        var requestHeader:StringMap<String> = new StringMap<String>();
        for (key in Reflect.fields(xreq.headers)) requestHeader.set(key, Reflect.field(xreq.headers, key));
        
        var req:AcerolaServerRequestData = {
            verb: verb,
            route: route,
            body: xreq.body,
            params : route.extractCleanData(xreq.params),
            headers : requestHeader,
            moment : DateTime.now(),
            hostname: (
                xreq.hostname == null 
                ? 'NO_HOSTNAME'
                : xreq.hostname
            ),
            user_agent: (
                StringKit.isEmpty(xreq.get('User-Agent'))
                ? 'NONE'
                : xreq.get('User-Agent')
            ),
            pool : this.database
        }

        var res:AcerolaServerResponseData = {
            headers : new StringMap<String>(),
            status: 200,
            data: null,
            send : null,
            timeout : null
        }

        res.headers.set('Content-Type', 'text/plain');
        res.send = () -> {
            if (res.timeout != null) {
                res.timeout.stop();
                res.timeout = null;
            }

            for (key in res.headers.keys()) xres.set(key, res.headers.get(key));
            xres.status(res.status).send(res.data);

            res.send = () -> {
                Sys.println('ERROR - Response already sent (${route})');
            };
        }
        

        res.timeout = haxe.Timer.delay(() -> {
            Sys.println('ERROR - Timeout reached (${route})');
            serviceInstance.runTimeout();
        }, 5000);

        serviceInstance = Type.createInstance(service, [req, res]);
    }
    
    // public function registerProxy(verb:CrappRouteVerb, route:String, proxyURL:String):Void {
    //     Crapp.S.controller.print(1, 'PROXY - ${verb} ${route} ${proxyURL}');

    //     switch (verb) {
    //         case CrappRouteVerb.GET : this.express.get(route, this.proxyRunner.bind(proxyURL, _, _));
    //         case CrappRouteVerb.POST : this.express.post(route, this.proxyRunner.bind(proxyURL, _, _));
    //     }
    // }

    // private function proxyRunner(proxyURL:String, req:Request, res:Response):Void {
    //     var http:HttpRequest = new HttpRequest(proxyURL);
    // }

}