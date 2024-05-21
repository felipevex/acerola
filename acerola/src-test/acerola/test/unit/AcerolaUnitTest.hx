package acerola.test.unit;

import acerola.test.unit.path.AcerolaPathTest;
import acerola.test.unit.database.DatabasePoolTest;
import utest.ui.Report;
import utest.Runner;

class AcerolaUnitTest {
    
    static public function main() {

        var runner = new Runner();

        runner.addCase(new AcerolaPathTest());
        runner.addCase(new DatabasePoolTest());
        
        Report.create(runner);
        runner.run();
        
    }

}