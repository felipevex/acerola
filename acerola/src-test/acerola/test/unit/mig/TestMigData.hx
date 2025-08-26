package acerola.test.unit.mig;

import acerola.mig.MigHelper;
import acerola.mig.enums.MigCommandType;
import utest.Assert;
import acerola.mig.data.MigCommandData;
import utest.Test;

class TestMigData extends Test {

    function test_running_without_params() {
        // ARRANGE
        var value_cwd:String = Sys.getCwd();

        var input:Array<String> = ["mig", value_cwd];

        var result:MigCommandData;
        var expected_cur_path:String = value_cwd;
        var expected_mig_command:String = "mig";
        var expected_command:MigCommandType = HELP;

        // ACT
        var mig:MigHelper = new MigHelper();
        result = mig.getData(input);

        // ASSERT
        Assert.equals(expected_cur_path, result.cur_path);
        Assert.equals(expected_mig_command, result.mig_command);
        Assert.equals(expected_command, result.command);
    }

    function test_running_help_command() {
        // ARRANGE
        var value_cwd:String = Sys.getCwd();

        var input:Array<String> = ["mig", 'help', value_cwd];

        var result:MigCommandData;
        var expected_cur_path:String = value_cwd;
        var expected_mig_command:String = "mig";
        var expected_command:MigCommandType = HELP;

        // ACT
        var mig:MigHelper = new MigHelper();
        result = mig.getData(input);

        // ASSERT
        Assert.equals(expected_cur_path, result.cur_path);
        Assert.equals(expected_mig_command, result.mig_command);
        Assert.equals(expected_command, result.command);
    }


}