package acerola.server.error;

class AcerolaRequestError {
    public var status:Int;
    public var source:String;
    public var message:String;

    public function new(status:Int, source:String, message:String) {
        this.status = status;
        this.source = source;
        this.message = message;
    }
    
    public function toString():String {
        return this.source + ' - ' + this.message;
    }
}