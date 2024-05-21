package acerola.request;

import haxe.ds.StringMap;

// TIP : Use /my/route/[id:Int]/[name:String]
abstract AcerolaPath(String) from String to String {
    
    public var cleanPath(get, never):String;
    public var types(get, never):StringMap<String>;

    public function parse(values:Dynamic):String {
        var route:String = this;

        var typesData:StringMap<String> = types;
        var result:String = route;


        for (key in typesData.keys()) {
            var valueType:String = typesData.get(key);
            var valueParsed:String = '';

            if (Reflect.hasField(values, key)) {
                var valueData:String = Std.string(Reflect.field(values, key));
                valueParsed = StringTools.urlEncode(valueData);
            }

            result = result.split('[${key}:${valueType}]').join(valueParsed);
        }

        return result;
        
    }

    private function get_cleanPath():String {
        var r:EReg = ~/\[(\w+):(Int|String)\]/;

        var route:String = this;
        var result:String = route;

        while (r.match(route)) {
            result = result.split(r.matched(0)).join(':' + r.matched(1));
            route = r.matchedRight();
        }

        return result;
    }
    
    private function get_types():StringMap<String> {
        var r:EReg = ~/\[(\w+):(Int|String)\]/;
        var route:String = this;
        var result:StringMap<String> = new StringMap<String>();

        while (r.match(route)) {
            result.set(r.matched(1), r.matched(2));
            route = r.matchedRight();
        }

        return result;
    }
}