package acerola.server;

import acerola.model.AcerolaResponseError;
import node.express.Response;
import node.express.Request;
import acerola.server.route.AcerolaRoute;
import node.express.Application;
import node.express.Express;

class AcerolaServer {
    
    private var express:Application;

    public var serverStarted:Bool;
    public var route:AcerolaRoute;

    public function new() {
        this.serverStarted = false;
        this.createApplication();
        this.route = new AcerolaRoute(this.express);
    }

    private function createApplication():Void {
        this.express = Express.application();

        var cors:()->Dynamic = js.Syntax.code("require({0})", 'cors');

        this.express.use(cors());
        this.express.use(Express.urlencoded({extended:true}));
        // this.express.use(Express.raw({limit:'10mb'}));
        // this.express.use(Express.text({limit:'10mb'}));
        this.express.use(Express.json({limit:'10mb'}));
        this.express.options('*', cors());

        this.express.use(this.handleError);
    }

    public function start(port:Int = 1000):Void {
        if (this.serverStarted) return;

        Sys.println('Starting Server at port ${port}');

        this.express.listen(
            port,
            function():Void {
                this.serverStarted = true;

                Sys.println('Server running in port ${port}');
            }
        );
    }


    function handleError (err, req:Request, res:Response, next) {
        if (err.type == "entity.parse.failed") {
            res.status(400);
            res.setHeader('Content-Type', 'application/json');

            var error:AcerolaResponseError = {
                status : 400,
                message: "Invalid JSON format",
                error_code: "INVALID_JSON" 
            }
            res.send(error);

            return;
        }

        // TODO LOG ERROR

        res.status(500);
        res.setHeader('Content-Type', 'application/json');
        var error:AcerolaResponseError = {
            status : 500,
            message: "Internal Server Error",
            error_code: "INTERNAL_SERVER_ERROR"
        }
        res.send(error);
    }

}