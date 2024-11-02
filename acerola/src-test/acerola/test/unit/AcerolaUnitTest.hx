package acerola.test.unit;

import acerola.test.unit.database.Database9PoolTest;
import acerola.test.unit.behavior.TestAcerolaBehavior;
import acerola.test.unit.path.AcerolaPathTest;
import acerola.test.unit.token.TestAcerolaToken;
import acerola.test.unit.request.TestAcerolaRequest;
import acerola.test.unit.database.DatabasePoolTest;
import utest.ui.Report;
import utest.Runner;

class AcerolaUnitTest {
    
    static public function main() {

        var runner = new Runner();

        runner.addCase(new AcerolaPathTest());
        runner.addCase(new TestAcerolaToken());
        runner.addCase(new TestAcerolaBehavior());
        runner.addCase(new TestAcerolaRequest());
        runner.addCase(new DatabasePoolTest());
        runner.addCase(new Database9PoolTest());
        
        Report.create(runner);
        runner.run();
        
    }

}