package acerola.server.service;

import acerola.server.model.AcerolaServerVerbsType;
import acerola.server.error.AcerolaServerError;
import acerola.server.behavior.AcerolaBehaviorManager;
import anonstruct.AnonStructError;
import anonstruct.AnonStruct;
import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;

/**
   Classe base para serviços do servidor Acerola que gerencia requisições HTTP, validação de dados e comportamentos.
   
   #### Responsabilidades:
   - **Processamento de requisições**: Gerencia o ciclo de vida de uma requisição HTTP no servidor Acerola.
   - **Validação de dados**: Valida estruturas de dados de entrada como parâmetros e corpo da requisição.
   - **Gerenciamento de resposta**: Prepara e envia respostas HTTP adequadas com os dados processados.
   - **Extensibilidade**: Fornece uma estrutura para implementações específicas através de métodos que podem ser sobrescritos.
*/
class AcerolaServerService {

    private var req:AcerolaServerRequestData;
    private var res:AcerolaServerResponseData;

    private var bodyValidator:Class<AnonStruct>;
    private var paramsValidator:Class<AnonStruct>;
    
    private var behavior:AcerolaBehaviorManager;

    /**
       Cria uma nova instância do serviço inicializando com os dados de requisição e resposta.
       Também inicializa o gerenciador de comportamentos e chama o método de configuração.
       
       @param req:AcerolaServerRequestData Dados da requisição HTTP recebida
       @param res:AcerolaServerResponseData Objeto para preparar a resposta HTTP
    */
    public function new(req:AcerolaServerRequestData, res:AcerolaServerResponseData) {
        this.req = req;
        this.res = res;

        this.behavior = new AcerolaBehaviorManager(this.req, this.res);
        this.setupBehavior();
    }

    /**
       Configura comportamentos específicos para este serviço.
       Este método deve ser sobrescrito por subclasses para adicionar comportamentos personalizados.
    */
    public function setupBehavior():Void {
        
    }

    /**
       Realiza configurações adicionais para o serviço.
       Este método deve ser sobrescrito por subclasses para configurações específicas.
    */
    public function setup():Void {
        
    }

    /**
       Executa os processos de validação de corpo e parâmetros da requisição.
       Chama internamente os métodos `validateBody` e `validateParams`.
    */
    public function validate():Void {
        this.validateBody();
        this.validateParams();
    }

    private function validateObject(objectType:String, data:Dynamic, validator:Class<AnonStruct>):Void {
        if (validator == null) return;

        var validatorInstance = Type.createInstance(validator, []);
        
        try {
            validatorInstance.validate(data);
        } catch (e:AnonStructError) {
            throw new AcerolaServerError(400, objectType, e.toStringFriendly(), e.toString());
        } catch (e:Dynamic) {
            throw new AcerolaServerError(500, objectType, 'Undefined Error.', Std.string(e));
        }
    }

    /**
       Valida os parâmetros da requisição utilizando o validador configurado.
       
       @throws AcerolaServerError Se os parâmetros não passarem na validação
    */
    public function validateParams():Void this.validateObject('Params', this.req.params, this.paramsValidator);
    
    /**
       Valida o corpo da requisição utilizando o validador configurado.
       
       @throws AcerolaServerError Se o corpo da requisição não passar na validação
    */
    public function validateBody():Void this.validateObject('Body', this.req.body, this.bodyValidator);

    /**
       Método principal que executa a lógica do serviço.
       Este método deve ser obrigatoriamente sobrescrito por subclasses.
       
       @throws String Erro indicando que o método deve ser sobrescrito
    */
    public function run():Void {
        throw 'Override run method.';
    }

    /**
       Executa uma função informativa que retorna metadados sobre a requisição atual.
       Útil para fins de depuração ou para endpoints de informação.
    */
    public function runInfo():Void {
        var className:String = Type.getClassName(Type.getClass(this));
        var verb:AcerolaServerVerbsType = this.req.verb;
        var params:Dynamic = this.req.params;
        var body:Dynamic = this.req.body;

        this.result(
            {
                className: className,
                verb: verb,
                params: params,
                body: body
            }, 
            200, 
            'application/json'
        );
    }

    /**
       Método executado quando ocorre um timeout na requisição.
       Pode ser sobrescrito por subclasses para tratamento específico de timeout.
    */
    public function runTimeout():Void {
        
    }
    
    private function result(data:Dynamic, status:Int, contentType:String):Void {
        var isSuccess:Bool = !Std.isOfType(data, AcerolaServerError);

        this.runBeforeResult(isSuccess, () -> {
            this.res.headers.set('Content-Type', contentType);
            this.res.status = status;
            this.res.data = isSuccess ? data : data.toData();
            this.res.send();

            this.runAfterResult(isSuccess);
        });
    }

    private function runBeforeResult(isSuccess:Bool, callback:()->Void):Void {
        haxe.Timer.delay(callback, 0);
    }

    private function runAfterResult(isSuccess:Bool):Void {
        
    }

}