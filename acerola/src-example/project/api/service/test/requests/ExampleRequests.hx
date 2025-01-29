package project.api.service.test.requests;

import util.kit.nothing.Nothing;
import project.api.service.test.model.TestGetHeaderServiceData;
import project.api.service.test.model.TestGetServiceData;
import project.api.service.test.model.TestPostServiceData;
import acerola.server.model.AcerolaServerVerbsType;
import acerola.request.AcerolaRequest;

class GetHelloWorldJson extends AcerolaRequest<{hello:String}, Nothing, Nothing> {
    public function new() {
        super(AcerolaServerVerbsType.GET, '/v1/hello-world-json');
    }
}


class PostTestPost extends AcerolaRequest<TestPostServiceData, Nothing, TestPostServiceData> {
    public function new() {
        super(AcerolaServerVerbsType.POST, '/v1/test-post');
    }
}

class GetTestGet extends AcerolaRequest<TestGetServiceData, TestGetServiceData, Nothing> {
    public function new() {
        super(AcerolaServerVerbsType.GET, '/v1/test-get/[id:Int]/[hello:String]');
    }
}

class GetTestGetHeader extends AcerolaRequest<TestGetHeaderServiceData, Nothing, Nothing> {
    public function new() {
        super(AcerolaServerVerbsType.GET, '/v1/test-get-header');
    }
}

class GetHelloWorldText extends AcerolaRequest<Dynamic, Nothing, Nothing> {
    public function new() {
        super(AcerolaServerVerbsType.GET, '/v1/hello-world-text');
    }
}

class PostTimeout extends AcerolaRequest<Dynamic, Nothing, Nothing> {
    public function new() {
        super(AcerolaServerVerbsType.POST, '/v1/timeout');
    }
}

class PostDatabase extends AcerolaRequest<Dynamic, Nothing, Nothing>  {
    public function new() {
        super(AcerolaServerVerbsType.POST, '/v1/database');
    }
}