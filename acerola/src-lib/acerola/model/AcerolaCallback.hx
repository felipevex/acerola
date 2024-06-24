package acerola.model;

typedef AcerolaCallback = {
    var onSuccess:()->Void;
    var onError:(error:AcerolaResponseError)->Void;
}