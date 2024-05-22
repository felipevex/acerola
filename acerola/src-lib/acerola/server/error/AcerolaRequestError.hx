package acerola.server.error;

class AcerolaRequestError {
    public var status:Int;
    public var errorSource:String;
    public var message:String;
    public var internal:String;

    public function new(status:Int, errorSource:String, message:String, internal:String) {
        this.status = status;
        this.errorSource = errorSource;
        this.message = message;
        this.internal = internal;
    }
    
    public function toString():String {
        if (this.errorSource.length == 0) return this.message;
        else return '${this.errorSource}: ${this.message}';
    }

    static private function dispatch(error:AcerolaRequestError, cb:ServerDispatchErrorFunction):Void {
        cb(error.toString(), error.status, error.internal);
    }

    // Essa resposta significa que o servidor não entendeu a requisição pois está com uma sintaxe inválida.
    static public function INVALID_REQUEST(techMessage:String, cb:ServerDispatchErrorFunction):Void dispatch(new AcerolaRequestError(400, '', 'Bad Request', techMessage), cb);
    static public function INVALID_REQUEST_DETAILED(message:String, techMessage:String, cb:ServerDispatchErrorFunction):Void dispatch(new AcerolaRequestError(400, '', message, techMessage), cb);

    // Embora o padrão HTTP especifique "unauthorized", semanticamente, essa resposta significa "unauthenticated".
    // Ou seja, o cliente deve se autenticar para obter a resposta solicitada.
    // https://developer.mozilla.org/pt-BR/docs/Web/HTTP/Status/401
    static public function UNAUTHORIZED_REQUEST(techMessage:String, cb:ServerDispatchErrorFunction):Void dispatch(new AcerolaRequestError(401, '', 'Unauthorized', techMessage), cb);

    // O cliente não tem direitos de acesso ao conteúdo portanto o servidor está rejeitando dar a resposta.
    // Diferente do código 401, aqui a identidade do cliente é conhecida.
    // Esse status é semelhante ao 401 , mas neste caso, a re-autenticação não fará diferença.
    // O acesso é permanentemente proibido e vinculado à lógica da aplicação (como uma senha incorreta).
    // https://developer.mozilla.org/pt-BR/docs/Web/HTTP/Status/403
    static public function FORBIDDEN(message:String, ?techMessage:String, cb:ServerDispatchErrorFunction):Void dispatch(new AcerolaRequestError(403, '', message, techMessage), cb);

    // O servidor não pode encontrar o recurso solicitado.
    static public function NOT_FOUND(techMessage:String, cb:ServerDispatchErrorFunction):Void dispatch(new AcerolaRequestError(404, '', 'Not Found', techMessage), cb);

    // Esta resposta será enviada quando uma requisição conflitar com o estado atual do servidor.
    static public function CONFLICT(message:String, techMessage:String, cb:ServerDispatchErrorFunction):Void dispatch(new AcerolaRequestError(409, '', message, techMessage), cb);

    // O servidor encontrou uma situação com a qual não sabe lidar.
    static public function SERVER_ERROR(techMessage:String, cb:ServerDispatchErrorFunction):Void dispatch(new AcerolaRequestError(500, '', 'Server Error', techMessage), cb);

    static public function SERVER_UNAVAILABLE(techMessage:String, cb:ServerDispatchErrorFunction):Void dispatch(new AcerolaRequestError(503, '', 'Service Unavailable', techMessage), cb);
    static public function SERVER_TIMEOUT(techMessage:String, cb:ServerDispatchErrorFunction):Void dispatch(new AcerolaRequestError(504, '', 'Server Timeout', techMessage), cb);

}

private typedef ServerDispatchErrorFunction = (message:String, status:Int, internalMessage:String)->Void;