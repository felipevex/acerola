package acerola.mig.command;

import acerola.mig.data.MigData;
import haxe.Json;
import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import helper.kits.StringKit;

using acerola.terminal.Terminal;

class MigCommand {

    public var path:String;
    public var params:Array<String>;

    public function new(path:String, params:Array<String>) {
        this.path = path;
        this.params = params;
    }

    public function validatePath():Void {
        var path:String = this.params.length == 0 ? '' : this.params[0];

        if (StringKit.isEmpty(path)) throw 'Path cannot be empty';

        var fullPath:String = Path.join([this.path, path]);

        if (!FileSystem.exists(fullPath)) throw 'Path ${path} does not exist';
        if (!FileSystem.isDirectory(fullPath)) throw 'Path ${path} is not a directory';
    }

    public function validateData():Void {

    }

    public function run():Void {
        throw "Override run() in subclass";
    }


    private function printStep(step:String):Void {
        '   - ${step}... '.print(YELLOW, false);
    }

    private function checkHasError(error:String):Void {
        'Error'.print(RED);
        throw error;
    }

    private function checkSuccess():Void {
        'DONE'.print(GREEN);
    }

    private function getFullPath():String {
        this.validatePath();
        var curPath:String = this.path;
        return Path.join([curPath, this.getLocalPath()]);
    }

    private function getLocalPath():String {
        this.validatePath();
        var curPath:String = this.params[0];
        return curPath;
    }

    private function createMigrationUpFile(file:String):Void {
        var fullPath:String = this.getFullPath();

        var path:String = Path.join([fullPath, file + '-UP.sql']);
        File.saveContent(path, '-- Migration Step UP\n\n');
    }

    private function createMigrationDownFile(file:String):Void {
        var fullPath:String = this.getFullPath();

        var path:String = Path.join([fullPath, file + '-DOWN.sql']);
        File.saveContent(path, '-- Migration Step DOWN\n\n');
    }

    private function createNewMigStepKey():String {
        var result:String = 'mig_';
        var migDate:String = DateTools.format(Date.now(), '%Y%m%d%H%M%S');
        var migRandom:String = StringTools.lpad(Std.string(Math.floor(Math.random() * 1000)), '0', 3);

        return result + migDate + migRandom;
    }

    private function createMigRunnerFile(data:MigData):Void {
        var fullPath:String = this.getFullPath();
        var migFile:String = 'migration.json';

        var migFileData:String = haxe.Json.stringify(data, '    ');
        File.saveContent(Path.join([fullPath, migFile]), migFileData);

    }

    private function loadStepData(step:MigStepData):String {
        var fullPath:String = this.getFullPath();
        var sqlFile:String = step.file + '-UP.sql';

        var sqlFilePath:String = Path.join([fullPath, sqlFile]);

        if (!FileSystem.exists(sqlFilePath)) {
            throw 'SQL file ${sqlFile} does not exist';
        }

        var content:String = File.getContent(Path.join([fullPath, sqlFile]));
        return content;
    }


    private function stepValidationMigrationFile():MigData {
        this.printStep('Loading migration file');

        var path:String = this.getFullPath();
        var migFile:String = 'migration.json';
        var migFilePath:String = Path.join([path, migFile]);

        if (!FileSystem.exists(migFilePath) || FileSystem.isDirectory(migFilePath)) {
            this.checkHasError('Migration file ${migFile} does not exist');
        }

        var data:MigData = null;

        try {
            var migFileContent:String = File.getContent(migFilePath);
            data = Json.parse(migFileContent);

            var validator:MigDataValidator = new MigDataValidator();
            validator.validate(data);
        } catch (e:Dynamic) {
            this.checkHasError('Migration file ${migFile} is not valid: ${Std.string(e)}');
        }

        this.checkSuccess();

        return data;
    }
}