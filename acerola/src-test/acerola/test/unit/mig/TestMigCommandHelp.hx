package acerola.test.unit.mig;

import acerola.mig.command.MigCommandHelp;
import utest.Assert;
import utest.Test;

class TestMigCommandHelp extends Test {

    function test_running_help_command() {
        // ARRANGE
        var value_params:Array<String> = [];
        var value_cwd:String = Sys.getCwd();

        // ACT
        var command:MigCommandHelp = new MigCommandHelp(value_cwd, value_params);
        command.run();

        // ASSERT
        Assert.pass();
    }

    function test_running_help_command_should_not_accept_params() {
        // ARRANGE
        var value_params:Array<String> = ['something'];
        var value_cwd:String = Sys.getCwd();

        // ACT
        var command:MigCommandHelp = new MigCommandHelp(value_cwd, value_params);

        // ASSERT
        Assert.raises(command.run);
    }


}