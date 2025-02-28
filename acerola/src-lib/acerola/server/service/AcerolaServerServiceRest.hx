package acerola.server.service;

import helper.kits.StringKit;
import acerola.server.error.AcerolaServerError;
import acerola.server.model.AcerolaServerResponseData;
import acerola.server.model.AcerolaServerRequestData;

/**
    Classe responsável por processar requisições REST e gerar respostas apropriadas com conteúdo estruturado.
    Esta classe serve como base para implementação de serviços REST no framework Acerola, permitindo
    o processamento de requisições HTTP e a geração de respostas padronizadas.
    
    Para utilizar esta classe, você deve criar uma subclasse específica para cada endpoint da sua API,
    sobrescrevendo pelo menos o método `run()` para implementar a lógica de negócio do serviço. 
    
    Exemplo de uso básico:
    ```haxe
    // Serviço que retorna um JSON simples
    class HelloWorldJsonService extends AcerolaServerServiceRest<{hello:String}> {
        override function run() {
            this.resultSuccess({hello: "world"});
        }
    }
    
    // Serviço que retorna conteúdo HTML
    class HelloWorldTextService extends AcerolaServerServiceRest<Dynamic> {
        override function run() {
            this.resultHtml('<div>hello world</div>');
        }
    }
    ```
    
    Para validação de parâmetros de requisição, você pode sobrescrever o método [setup()](http://_vscodecontentref_/0):
    ```haxe
    class TestGetService extends AcerolaServerServiceRest<TestGetServiceData> {
        override function setup() {
            super.setup();
            this.paramsValidator = TestGetServiceDataValidator;
        }
        
        override function run() {
            var params:TestGetServiceData = this.req.params;
            this.resultSuccess(params);
        }
    }
    ```
    
    #### Responsabilidades:
    - **Processamento de Requisições**: Gerencia o fluxo de processamento de uma requisição REST, incluindo validação e execução.
    - **Gerenciamento de Comportamentos**: Executa comportamentos em ordem sequencial antes de processar a requisição principal.
    - **Formatação de Respostas**: Converte dados em respostas HTTP apropriadas com diferentes formatos de conteúdo.
    - **Tratamento de Erros**: Captura e processa exceções, convertendo-as em respostas de erro padronizadas.
**/
class AcerolaServerServiceRest<S> extends AcerolaServerService {

    /**
        Construtor da classe que inicializa o serviço com os dados da requisição e resposta.
        Este método configura o ambiente básico para o processamento da requisição, incluindo
        a inicialização de comportamentos e tratamento de exceções iniciais.
        
        @param req:AcerolaServerRequestData os dados da requisição HTTP recebida
        @param res:AcerolaServerResponseData o objeto para preparar a resposta HTTP
    **/
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

    /**
        Executa a sequência de comportamentos registrados no gerenciador de comportamentos.
        Quando todos os comportamentos são executados com sucesso, chama os métodos de validação e execução.
        Em caso de erro em qualquer etapa, encerra o processo e retorna uma resposta de erro adequada.
    **/
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

    /**
        Retorna uma resposta HTML ao cliente com o conteúdo fornecido.
        Este método é útil quando você precisa retornar uma página HTML completa
        ou qualquer conteúdo textual com formatação HTML.
        
        @param data:String o conteúdo HTML a ser enviado na resposta
        @param status:Int o código de status HTTP da resposta
    **/
    public function resultHtml(data:String, status:Int = 200):Void this.result(data, status, 'text/html; charset=utf-8');
    
    /**
        Retorna uma resposta JSON de sucesso ao cliente com os dados fornecidos.
        Este é o método mais comum para APIs REST, permitindo retornar dados
        estruturados que serão automaticamente serializados para JSON.
        
        @param data:S os dados a serem serializados como JSON na resposta
        @param status:Int o código de status HTTP da resposta
    **/
    public function resultSuccess(data:S, status:Int = 200):Void this.result(data, status, 'application/json');

    /**
        Retorna uma resposta de erro ao cliente com base no objeto de erro fornecido.
        O status HTTP e o conteúdo são extraídos do objeto de erro.
        Este método é utilizado automaticamente pelo tratamento de exceções interno,
        mas também pode ser chamado manualmente para casos de erro específicos.
        
        @param error:AcerolaServerError o objeto de erro que contém informações sobre o erro ocorrido
    **/
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