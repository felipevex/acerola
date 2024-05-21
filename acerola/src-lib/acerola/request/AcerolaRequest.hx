package acerola.request;

import acerola.server.model.AcerolaServerVerbsType;

typedef AcerolaRequest = {
    
    var verb:AcerolaServerVerbsType;
    var path:AcerolaPath;

}