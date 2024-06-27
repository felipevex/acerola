package acerola.test.unit.request;

import haxe.ds.StringMap;
import project.api.service.test.requests.ExampleRequests.GetTestGetHeader;
import project.api.service.test.model.TestGetHeaderServiceData;
import project.api.service.test.model.TestPostServiceData;
import project.api.service.test.model.TestGetServiceData;
import project.api.service.test.requests.ExampleRequests.PostTestPost;
import project.api.service.test.requests.ExampleRequests.GetTestGet;
import utest.Async;
import acerola.request.AcerolaResponse;
import utest.Assert;
import project.api.service.test.requests.ExampleRequests.GetHelloWorldJson;
import utest.Test;

class TestAcerolaRequest extends Test {
    
    public function test_get_request(async:Async) {
        // ARRANGE
        var request:GetHelloWorldJson = new GetHelloWorldJson();

        var valueDomain:String = 'http://127.0.0.1:1000';

        var resultResult:{hello:String};
        var expectedResult:{hello:String} = {
            hello : 'world'
        }

        var assert:()->Void = null;

        // ACT
        request.request(
            valueDomain,
            (response:AcerolaResponse<{hello:String}>) -> {
                resultResult = response.result;
                assert();
            }
        );

        // ASSERT
        assert = () -> {
            Assert.same(expectedResult, resultResult);
            async.done();
        }
    }

    function test_get_request_with_params(async:Async) {
        // ARRANGE
        var request:GetTestGet = new GetTestGet();

        var valueDomain:String = 'http://127.0.0.1:1000';
        var valueParams:TestGetServiceData = {
            id : 1,
            hello : 'world'
        }

        var resultResult:TestGetServiceData;
        var expectedResult:TestGetServiceData = {
            id : 1,
            hello : 'world'
        }

        var assert:()->Void = null;

        // ACT
        request.request(
            valueDomain,
            (response:AcerolaResponse<TestGetServiceData>) -> {
                resultResult = response.result;
                assert();
            },
            valueParams
        );

        // ASSERT
        assert = () -> {
            Assert.same(expectedResult, resultResult);

            async.done();
        }
    }

    function test_post_request(async:Async) {
        // ARRANGE
        var request:PostTestPost = new PostTestPost();

        var valueDomain:String = 'http://127.0.0.1:1000';
        var valueBody:TestPostServiceData = {
            id : 1,
            hello : 'world'
        }

        var resultResult:TestPostServiceData;
        var expectedResult:TestPostServiceData = {
            id : 1,
            hello : 'world'
        }

        var assert:()->Void = null;

        // ACT
        request.request(
            valueDomain,
            (response:AcerolaResponse<TestGetServiceData>) -> {
                resultResult = response.result;
                assert();
            },
            
            valueBody
        );

        // ASSERT
        assert = () -> {
            Assert.same(expectedResult, resultResult);

            async.done();
        }
    }

    function test_get_with_header_request(async:Async) {
        // ARRANGE
        var request:GetTestGetHeader = new GetTestGetHeader();

        var valueDomain:String = 'http://127.0.0.1:1000';
        
        var valueHeaders:StringMap<String> = [
            "header" => "value"
        ];

        var resultResult:TestGetHeaderServiceData;
        var expectedResult:TestGetHeaderServiceData = {
            header : "value"
        }

        var assert:()->Void = null;

        // ACT
        request.request(
            valueDomain,
            (response:AcerolaResponse<TestGetHeaderServiceData>) -> {
                resultResult = response.result;
                assert();
            },
            valueHeaders
        );

        // ASSERT
        assert = () -> {
            Assert.same(expectedResult, resultResult);

            async.done();
        }
    }

}