package acerola.model;

typedef AcerolaResponseError = {
    var status:Int;
    var message:String;
    var error_code:String;
    @:optional var internal:String;
}