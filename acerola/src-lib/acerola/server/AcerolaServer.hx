package acerola.server;

import js.node.V8;
import database.DatabasePool;
import acerola.server.error.AcerolaServerError;
import database.DatabaseConnection;
import node.express.Response;
import node.express.Request;
import acerola.server.route.AcerolaRoute;
import node.express.Application;
import node.express.Express;

/**
    Classe responsável por criar e gerenciar um servidor web usando Express.js em Haxe.
    Fornece funcionalidades para inicializar o servidor, configurar rotas e lidar com erros.

    #### Responsabilidades:
    - **Inicialização de Servidor**: Configura e inicia um servidor Express.js com as configurações necessárias.
    - **Gerenciamento de Rotas**: Cria e disponibiliza um objeto de roteamento para registrar endpoints da API.
    - **Tratamento de Erros**: Fornece mecanismos para tratamento de erros HTTP e respostas adequadas.
    - **Conexão com Banco de Dados**: Gerencia a conexão com o banco de dados quando fornecido.

    ### Exemplo de Uso:
    ```haxe

    // Configuração da conexão com o banco de dados
    var connection = new DatabaseConnection({
        host: 'localhost',
        user: 'root',
        password: 'password',
        database: 'mydatabase'
    });

    // Criação do servidor Acerola
    var server = new AcerolaServer(connection);

    // Registro de rotas
    server.route.register(GetHelloWorldJson, HelloWorldJsonService);

    // Início do servidor na porta 3000
    server.start(3000);

    // A partir daqui, em outro arquivo, por exemplo, em uma pasta chamada "services":

    // Exemplo de requisição GET
    class GetHelloWorldJson extends AcerolaRequest<{hello:String}, Dynamic, Dynamic> {
        public function new() {
            super(GET, '/hello-world');
        }
    }

    // Exemplo de serviço que retorna um JSON simples
    class HelloWorldJsonService extends AcerolaServerServiceRest<{hello:String}> {
        override function run() {
            this.resultSuccess({hello: "world"});
        }
    }

    ```
**/
class AcerolaServer {
    
    private var express:Application;

    /**
        Indica se o servidor foi iniciado com sucesso.
    **/
    public var serverStarted:Bool;

    /**
        Gerenciador de rotas da aplicação, usado para registrar endpoints da API.
    **/
    public var route:AcerolaRoute;

    /**
        Gerenciador de pool de conexões de banco de dados.
    **/
    public var database:DatabasePool;

    /**
        Cria uma nova instância do servidor Acerola.
        Inicializa a aplicação Express e configura o roteamento básico.
        
        @param connection Configuração opcional de conexão com o banco de dados
    **/
    public function new(?connection:DatabaseConnection) {
        this.serverStarted = false;
        this.createApplication();

        if (connection != null) this.database = new DatabasePool(connection);

        this.route = new AcerolaRoute(this.express, this.database);
    }

    private function prevent404():Void {
        this.express.get('*', this.custom404);
        this.express.post('*', this.custom404);
        this.express.put('*', this.custom404);
        this.express.delete('*', this.custom404);
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

    /**
        Inicia o servidor na porta especificada.
        Configura as rotas de fallback para 404 e imprime informações de status no console.
        
        @param port Porta na qual o servidor será iniciado, o valor padrão é 1000
    **/
    public function start(port:Int = 1000):Void {
        if (this.serverStarted) return;

        Sys.println('Starting Server at port ${port}');

        this.express.listen(
            port,
            function():Void {
                this.serverStarted = true;

                Sys.println('Server running in port ${port}');
                Sys.println('Memory Available: ' + Math.round(V8.getHeapStatistics().total_available_size / 1024 / 1024) + 'mb');
                
            }
        );

        this.prevent404();
    }

    function custom404(req:Request, res:Response) {
        var error:AcerolaServerError = AcerolaServerError.NOT_FOUND('Not Found', 'NOT_FOUND');
        res.setHeader('Content-Type', 'application/json');
        res.status(error.status);
        res.send(error.toData());
    }


    function handleError (err, req:Request, res:Response, next) {
        var error:AcerolaServerError = switch (err.type) {
            case 'entity.parse.failed' : AcerolaServerError.INVALID_REQUEST_DETAILED('Invalid JSON format', 'INVALID_JSON', 'INVALID_JSON');
            case _ : AcerolaServerError.SERVER_ERROR('INTERNAL_SERVER_ERROR', 'INTERNAL_SERVER_ERROR');
        }

        res.setHeader('Content-Type', 'application/json');
        res.status(error.status);
        res.send(error.toData());
    }

}