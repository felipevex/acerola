package acerola.test.unit.database;

import database.DatabaseError;
import database.DatabaseSuccess;
import database.DatabasePool;
import database.DatabaseConnection;
import database.DatabaseRequest;
import utest.Test;
import helper.kits.StringKit;
import utest.Assert;
import utest.Async;

class DatabasePoolTest extends Test {

    private var connection:DatabaseConnection;
    private var pool:DatabasePool;
    private var testTable:String;

    function setup() {
        this.testTable = 'test_${StringKit.generateRandomHex(6)}';

        this.connection = {
            host : 'mysql',
            user : 'root',
            password : 'mysql_root_password',
            port : 3306,
            max_connections : 3,
            acquire_timeout : 150
        }

        this.pool = new DatabasePool(this.connection);
    }

    function teardown() {
        this.pool.close();
    }

    function test_simple_select_mysql_value(async:Async) {
        // ARRANGE
        var resultDataValue:Dynamic;
        var resultLength:Int;
        
        var expected_vint:Int = 1;
        var expected_vfloat:Float = 1.5;
        var expected_vchar:String = 'x';
        var expected_vjson:Dynamic = {a:1};

        var expectedLength:Int = 1;

        var assert:()->Void = null;
        var query:DatabaseRequest<{vint:Int, vfloat:Float, vchar:String, vjson:Dynamic}> = {
            query : '
                SELECT 
                    1 as vint,
                    1.5 as vfloat,
                    "x" as vchar,
                    JSON_OBJECT("a", 1) as vjson
            '
        }

        // ACT
        this.pool.getTicket(function(ticket:String):Void {

            this.pool.query(
                ticket,
                query,
                function(data:DatabaseSuccess<{vint:Int, vfloat:Float, vchar:String, vjson:Dynamic}>):Void {
                    resultDataValue = data.raw.next();
                    resultLength = data.length;

                    assert();
                }
            );

        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expected_vint, resultDataValue.vint);
            Assert.equals(expected_vfloat, resultDataValue.vfloat);
            Assert.equals(expected_vchar, resultDataValue.vchar);
            Assert.same(expected_vjson, resultDataValue.vjson);

            Assert.equals(expectedLength, resultLength);
            async.done();
        }

    }

    function test_get_an_ticket_and_check_if_its_open(async:Async) {
        // ARRANGE
        var resultTicket:String;
        var resultTicketStatus:Bool;
        var expectedTicketStatus:Bool = true;
        var assert:()->Void = null;

        // ACT
        this.pool.getTicket(function(ticket:String):Void {
            resultTicket = ticket;
            resultTicketStatus = this.pool.isOpen(ticket);

            assert();
        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedTicketStatus, resultTicketStatus);

            async.done();
        }

    }

    function test_ticket_should_not_be_opened_after_close_ticket(async:Async) {
        // ARRANGE
        var resultTicket:String;
        var resultTicketStatus:Bool;
        var expectedTicketStatus:Bool = false;
        var assert:()->Void = null;

        // ACT
        this.pool.getTicket(function(ticket:String):Void {
            resultTicket = ticket;

            this.pool.closeTicket(resultTicket);

            resultTicketStatus = this.pool.isOpen(ticket);

            assert();
        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedTicketStatus, resultTicketStatus);

            async.done();
        }

    }

    function test_run_a_simple_query_and_check_result(async:Async) {
        // ARRANGE
        var resultDataValue:Int;
        var resultLength:Int;
        var expectedDataValue:Int = 1;
        var expectedLength:Int = 1;
        var assert:()->Void = null;
        var query:DatabaseRequest<{value:Int}> = {
            query : 'SELECT :value AS `value`',
            data : {
                value : 1
            }
        }

        // ACT
        this.pool.getTicket(function(ticket:String):Void {

            this.pool.query(
                ticket,
                query,
                function(data:DatabaseSuccess<{value:Int}>):Void {
                    resultDataValue = data.raw.next().value;
                    resultLength = data.length;

                    assert();
                }
            );

        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedDataValue, resultDataValue);
            Assert.equals(expectedLength, resultLength);
            async.done();
        }

    }

    function test_run_a_malformated_query_and_check_error(async:Async) {
        // ARRANGE
        var resultErrorCode:String;
        var expectedErrorCode:String = 'ER_PARSE_ERROR';
        var assert:()->Void = null;

        var query:DatabaseRequest<{value:Int}> = {
            query : 'invalid query'
        }

        // ACT
        this.pool.getTicket(function(ticket:String):Void {

            this.pool.query(
                ticket,
                query,
                function(data:DatabaseSuccess<{value:Int}>):Void {},
                function(error:DatabaseError):Void {
                    resultErrorCode = error.code;
                    assert();
                }
            );

        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedErrorCode, resultErrorCode);
            async.done();
        }

    }

    function test_a_connection_that_take_too_much_time_to_return_to_pool(async:Async) {
        // ARRANGE
        var resultErrorCode:String;
        var expectedErrorCode:String = DatabasePool.ERROR_INVALID_TICKET;
        var assert:()->Void = null;
        var query:DatabaseRequest<{value:Int}> = {
            query : 'SELECT 1'
        }

        // ACT
        this.pool.getTicket(function(ticket:String):Void {
            haxe.Timer.delay(function():Void {

                this.pool.query(
                    ticket,
                    query,
                    function(data:DatabaseSuccess<{value:Int}>):Void {},
                    function(error:DatabaseError):Void {
                        resultErrorCode = error.code;
                        assert();
                    }
                );


            }, 20);
        }, 10);

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedErrorCode, resultErrorCode);
            async.done();
        }
    }

    function test_a_long_query_with_timeout_should_fail(async:Async) {
        // ARRANGE
        var resultErrorCode:String;
        var expectedErrorCode:String = 'PROTOCOL_SEQUENCE_TIMEOUT';

        var query:DatabaseRequest<{value:Int}> = {
            query : 'SELECT benchmark(10000000, md5("when will it end?"));',
            timeout : 1
        }
        var assert:()->Void = null;


        // ACT
        this.pool.getTicket(function(ticket:String):Void {
            this.pool.query(
                ticket,
                query,
                function(data:DatabaseSuccess<{value:Int}>):Void {
                    assert();
                },
                function(error:DatabaseError):Void {
                    resultErrorCode = error.code;
                    assert();
                }
            );
        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedErrorCode, resultErrorCode);
            async.done();
        }

    }

    function test_create_three_tickets_and_shoud_be_success(async:Async):Void {
        // ARRANGE
        var totalTicket:Int = 3;

        // ACT
        for (i in 0 ... totalTicket) {
            async.branch(function(a:Async):Void {
                this.pool.getTicket(function(ticket:String):Void {
                    if (this.pool.isOpen(ticket)) {
                        Assert.pass();
                        a.done();
                    }
                });
            });
        }

    }

    function test_create_four_tickets_and_shoud_fail_last_ticket(async:Async):Void {
        // ARRANGE
        var totalTicket:Int = 3;

        // ACT
        async.setTimeout(15000);

        for (i in 0 ... totalTicket) {
            async.branch(function(a:Async):Void {
                this.pool.getTicket(function(ticket:String):Void {
                    if (this.pool.isOpen(ticket)) {
                        Assert.pass();
                        a.done();
                    }
                });
            });
        }

        // LAST TICKET FAILING
        async.branch(function(a:Async):Void {
            this.pool.getTicket(function(ticket:String):Void {
                if (this.pool.isOpen(ticket) == false) {
                    Assert.pass();
                    a.done();
                }
            });
        });

    }

    function test_an_long_query_must_fail_if_it_is_closed_before_return(async:Async):Void {
        // ARRANGE
        var ticketTimeOut:Int = 10;
        var resultErrorCode:String;
        var expectedErrorCode:String = 'ER_CRAPP_CONNECTION_TIMEOUT';
        var query:DatabaseRequest<{value:Int}> = {
            query : 'SELECT benchmark(10000000, md5("when will it end?"));'
        }
        var assert:()->Void = null;

        // ACT
        this.pool.getTicket(function(ticket:String):Void {
            this.pool.query(
                ticket,
                query,
                function(data:DatabaseSuccess<{value:Int}>):Void {
                    assert();
                },
                function(error:DatabaseError):Void {
                    resultErrorCode = error.code;
                    assert();
                }
            );
        }, ticketTimeOut);

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedErrorCode, resultErrorCode);
            async.done();
        }
    }

    function test_connection_is_working_in_transaction_mode(async:Async):Void {
        // ARRANGE
        var resultLength:Int;
        var expectedLength:Int = 0;
        var valueName:String = 'item name';
        var valueUnique:String = StringKit.generateRandomHex(30);

        var queryInsert:DatabaseRequest<Dynamic> = {
            query : 'INSERT INTO tests.my_table (unq, name) VALUES (:unq, :name)',
            data : {
                unq : valueUnique,
                name : valueName
            }
        }
        var querySelect:DatabaseRequest<Dynamic> = {
            query : 'SELECT * FROM tests.my_table WHERE unq = :unq',
            data : {
                unq : valueUnique
            }
        }
        var assert:()->Void = null;
        var fail:(err:DatabaseError)->Void = function(err:DatabaseError):Void {
            Assert.fail(err.message);
            async.done();
        }

        // ACT
        this.pool.getTicket(function(ticket_a:String):Void {
            this.pool.getTicket(function(ticket_b:String):Void {
                this.pool.query(ticket_a, queryInsert, function(result:DatabaseSuccess<Dynamic>):Void {
                    this.pool.query(ticket_b, querySelect, function(result:DatabaseSuccess<Dynamic>):Void {
                        resultLength = result.length;
                        assert();
                    }, fail);
                }, fail);
            });
        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedLength, resultLength);
            async.done();
        }
    }

    function test_transaction_is_commited_after_close_a_ticket(async:Async):Void {
        // ARRANGE
        var doRollback:Bool = false;
        var resultLength:Int;
        var expectedLength:Int = 1;
        var valueName:String = 'item name';
        var valueUnique:String = StringKit.generateRandomHex(30);
        var queryInsert:DatabaseRequest<Dynamic> = {
            query : 'INSERT INTO tests.my_table (unq, name) VALUES (:unq, :name)',
            data : {
                unq : valueUnique,
                name : valueName
            }
        }
        var querySelect:DatabaseRequest<Dynamic> = {
            query : 'SELECT * FROM tests.my_table WHERE unq = :unq',
            data : {
                unq : valueUnique
            }
        }
        var assert:()->Void = null;
        var fail:(err:DatabaseError)->Void = function(err:DatabaseError):Void {
            Assert.fail(err.message);
            async.done();
        }

        // ACT
        this.pool.getTicket(function(ticket_a:String):Void {
            this.pool.getTicket(function(ticket_b:String):Void {
                this.pool.query(ticket_a, queryInsert, function(result:DatabaseSuccess<Dynamic>):Void {

                    this.pool.closeTicket(ticket_a, function():Void {

                        this.pool.query(ticket_b, querySelect, function(result:DatabaseSuccess<Dynamic>):Void {
                            resultLength = result.length;
                            assert();
                        }, fail);

                    }, doRollback);

                }, fail);
            });
        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedLength, resultLength);
            async.done();
        }
    }

    function test_transaction_should_rollback_on_close_ticket_if_parameter_is_set(async:Async):Void {
        // ARRANGE
        var doRollback:Bool = true;
        var resultLength:Int;
        var expectedLength:Int = 0;
        var valueName:String = 'item name';
        var valueUnique:String = StringKit.generateRandomHex(30);
        var queryInsert:DatabaseRequest<Dynamic> = {
            query : 'INSERT INTO tests.my_table (unq, name) VALUES (:unq, :name)',
            data : {
                unq : valueUnique,
                name : valueName
            }
        }
        var querySelect:DatabaseRequest<Dynamic> = {
            query : 'SELECT * FROM tests.my_table WHERE unq = :unq',
            data : {
                unq : valueUnique
            }
        }
        var assert:()->Void = null;
        var fail:(err:DatabaseError)->Void = function(err:DatabaseError):Void {
            Assert.fail(err.message);
            async.done();
        }

        // ACT
        this.pool.getTicket(function(ticket_a:String):Void {
            this.pool.getTicket(function(ticket_b:String):Void {
                this.pool.query(ticket_a, queryInsert, function(result:DatabaseSuccess<Dynamic>):Void {

                    this.pool.closeTicket(ticket_a, function():Void {

                        this.pool.query(ticket_b, querySelect, function(result:DatabaseSuccess<Dynamic>):Void {
                            resultLength = result.length;
                            assert();
                        }, fail);

                    }, doRollback);

                }, fail);
            });
        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedLength, resultLength);
            async.done();
        }
    }

    @:timeout(10000)
    function test_the_same_query_with_active_cache_should_use_cache_data(async:Async):Void {
        // ARRANGE
        var resultErrorCode:String;
        var expectedErrorCode:String = 'PROTOCOL_SEQUENCE_TIMEOUT';
        var ticketTimeOut:Int = 5;
        var query:DatabaseRequest<Dynamic> = {
            query : "SELECT benchmark(1000000, md5('when will it end?'));",
            cache : true,
            cache_timeout : 50,
            timeout : 500
        }
        var assert:()->Void = null;

        // ACT
        this.pool.getTicket(function(ticket:String):Void {

            // LONG QUERY - MUST SUCCESS
            query.timeout = 10000;
            this.pool.query(ticket, query, function(success:DatabaseSuccess<Dynamic>):Void {
                // LONG QUERY WITH CACHE - SUCCESS
                query.timeout = 1;
                this.pool.query(ticket, query, function(success:DatabaseSuccess<Dynamic>):Void {

                    haxe.Timer.delay( // espera o cache espirar
                        function():Void {

                            // LONG QUERY SMALL TIMEOUT WITH DEAD CACHE - MUST FAIL
                            query.timeout = 1; // forca um tempo menor de execucao
                            this.pool.query(ticket, query, function(sucess:DatabaseSuccess<Dynamic>):Void {
                                assert();
                            }, function(err:DatabaseError):Void {
                                resultErrorCode = err.code;
                                assert();
                            });
                        }, 100
                    );
                });
            });
        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedErrorCode, resultErrorCode);
            async.done();
        }
    }

    function test_connection_can_disable_transaction_mode(async:Async):Void {
        // ARRANGE
        var resultLength:Int;
        var expectedLength:Int = 1;
        var autoTransaction:Bool = false;
        var valueName:String = 'item name';
        var valueUnique:String = StringKit.generateRandomHex(30);
        var queryInsert:DatabaseRequest<Dynamic> = {
            query : 'INSERT INTO tests.my_table (unq, name) VALUES (:unq, :name)',
            data : {
                unq : valueUnique,
                name : valueName
            }
        }
        var querySelect:DatabaseRequest<Dynamic> = {
            query : 'SELECT * FROM tests.my_table WHERE unq = :unq',
            data : {
                unq : valueUnique
            }
        }
        var assert:()->Void = null;
        var fail:(err:DatabaseError)->Void = function(err:DatabaseError):Void {
            Assert.fail(err.message);
            async.done();
        }

        // ACT
        this.pool.getTicket(function(ticket_a:String):Void {
            this.pool.getTicket(function(ticket_b:String):Void {
                this.pool.query(ticket_a, queryInsert, function(result:DatabaseSuccess<Dynamic>):Void {
                    this.pool.query(ticket_b, querySelect, function(result:DatabaseSuccess<Dynamic>):Void {
                        resultLength = result.length;
                        assert();
                    }, fail);
                }, fail);
            }, autoTransaction);
        }, autoTransaction);

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedLength, resultLength);
            async.done();
        }
    }

    function test_insert_query_show_set_hascreatedsomething_to_true(async:Async) {
        // ARRANGE
        var resultData:DatabaseSuccess<Dynamic>;
        var expectedHasCreatedSomething:Bool = true;
        var expectedHasUpdatedSomething:Bool = false;

        var assert:()->Void = null;

        var query:DatabaseRequest<Dynamic> = {
            query : 'INSERT INTO tests.my_table (unq, name) VALUES (:unq, :name)',
            data : {
                unq : StringKit.generateRandomHex(30),
                name : 'item name'
            }
        }

        // ACT
        this.pool.getTicket(function(ticket:String):Void {

            this.pool.query(
                ticket,
                query,
                (data:DatabaseSuccess<Dynamic>) -> {
                    resultData = data;
                    assert();
                }
            );

        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedHasCreatedSomething, resultData.hasCreatedSomething);
            Assert.equals(expectedHasUpdatedSomething, resultData.hasUpdatedSomething);
            async.done();
        }
    }

    function test_update_query_show_set_hasupdatedsomething_to_true(async:Async) {
        // ARRANGE
        var resultData:DatabaseSuccess<Dynamic>;
        var expectedHasCreatedSomething:Bool = false;
        var expectedHasUpdatedSomething:Bool = true;

        var assert:()->Void = null;

        var query_insert:DatabaseRequest<Dynamic> = {
            query : 'INSERT INTO tests.my_table (unq, name) VALUES (:unq, :name)',
            data : {
                unq : StringKit.generateRandomHex(30),
                name : 'item name'
            }
        }

        var query_update:DatabaseRequest<Dynamic> = {
            query : 'UPDATE tests.my_table SET name = :name WHERE unq = :unq',
            data : {
                unq : query_insert.data.unq,
                name : 'novo nome'
            }
        }

        // ACT
        this.pool.getTicket(function(ticket:String):Void {

            this.pool.query(
                ticket,
                query_insert,
                (data:DatabaseSuccess<Dynamic>) -> {
                    this.pool.query(
                        ticket,
                        query_update,
                        (data:DatabaseSuccess<Dynamic>) -> {
                            resultData = data;
                            assert();
                        }
                    );
                }
            );

        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedHasUpdatedSomething, resultData.hasUpdatedSomething);
            Assert.equals(expectedHasCreatedSomething, resultData.hasCreatedSomething);
            async.done();
        }
    }

    function test_update_query_with_same_value_shold_not_update_something(async:Async) {
        // ARRANGE
        var resultData:DatabaseSuccess<Dynamic>;
        var expectedHasCreatedSomething:Bool = false;
        var expectedHasUpdatedSomething:Bool = false;
        var expectedHasAffectedSomething:Bool = true;

        var assert:()->Void = null;

        var query_insert:DatabaseRequest<Dynamic> = {
            query : 'INSERT INTO tests.my_table (unq, name) VALUES (:unq, :name)',
            data : {
                unq : StringKit.generateRandomHex(30),
                name : 'item name'
            }
        }

        var query_update:DatabaseRequest<Dynamic> = {
            query : 'UPDATE tests.my_table SET name = :name WHERE unq = :unq',
            data : {
                unq : query_insert.data.unq,
                name : query_insert.data.name
            }
        }

        // ACT
        this.pool.getTicket(function(ticket:String):Void {

            this.pool.query(
                ticket,
                query_insert,
                (data:DatabaseSuccess<Dynamic>) -> {
                    this.pool.query(
                        ticket,
                        query_update,
                        (data:DatabaseSuccess<Dynamic>) -> {
                            resultData = data;
                            assert();
                        }
                    );
                }
            );

        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedHasUpdatedSomething, resultData.hasUpdatedSomething);
            Assert.equals(expectedHasCreatedSomething, resultData.hasCreatedSomething);
            Assert.equals(expectedHasAffectedSomething, resultData.hasAffectedSomething);
            async.done();
        }
    }

    function test_update_invalid_update_should_not_set_update_something(async:Async) {
        // ARRANGE
        var resultData:DatabaseSuccess<Dynamic>;
        var expectedHasCreatedSomething:Bool = false;
        var expectedHasUpdatedSomething:Bool = false;
        var expectedHasAffectedSomething:Bool = false;

        var assert:()->Void = null;

        var query_update:DatabaseRequest<Dynamic> = {
            query : 'UPDATE tests.my_table SET name = "novo nome" WHERE unq = :unq',
            data : {
                unq : 'invalid unq',
                name : 'item name'
            }
        }

        // ACT
        this.pool.getTicket(function(ticket:String):Void {

            this.pool.query(
                ticket,
                query_update,
                (data:DatabaseSuccess<Dynamic>) -> {
                    resultData = data;
                    assert();
                }
            );

        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedHasUpdatedSomething, resultData.hasUpdatedSomething);
            Assert.equals(expectedHasCreatedSomething, resultData.hasCreatedSomething);
            Assert.equals(expectedHasAffectedSomething, resultData.hasAffectedSomething);
            async.done();
        }
    }

    function test_select_query_show_set_hascreatedsomething_to_false(async:Async) {
        // ARRANGE
        var resultData:DatabaseSuccess<Dynamic>;
        var expectedHasCreatedSomething:Bool = false;
        var expectedHasUpdatedSomething:Bool = false;
        var expectedHasAffectedSomething:Bool = false;

        var assert:()->Void = null;

        var query:DatabaseRequest<Dynamic> = {
            query : 'SELECT * FROM tests.my_table LIMIT 1',
            data : {}
        }

        // ACT
        this.pool.getTicket(function(ticket:String):Void {

            this.pool.query(
                ticket,
                query,
                (data:DatabaseSuccess<Dynamic>) -> {
                    resultData = data;
                    assert();
                }
            );

        });

        // ASSERT
        assert = function():Void {
            Assert.equals(expectedHasCreatedSomething, resultData.hasCreatedSomething);
            Assert.equals(expectedHasUpdatedSomething, resultData.hasUpdatedSomething);
            Assert.equals(expectedHasAffectedSomething, resultData.hasAffectedSomething);
            async.done();
        }
    }
}
