@JS()
library mono;

// import 'dart:_interceptors';
// import 'dart:js' as djs;

import 'package:js/js_util.dart' as js;

import 'package:js/js.dart';

// invokes Mono.setup(data)`.
@JS('MonoConnect.setup')
external void setup(Object obj);

@JS('MonoConnect.open')
external void open();

@JS('MonoConnect.reauthorise')
external void reauthorise(String code);

@JS('setupMonoConnect')
external void setupMonoConnect(String key, [String? reference, String? config, String? authCode]);

dynamic _nested(dynamic val) {
  if (val.runtimeType.toString()  == 'LegacyJavaScriptObject') {
    return jsToMap(val);
  }
  return val;
}

/// A workaround to converting an object from JS to a Dart Map.
Map jsToMap(jsObject) {
  return Map.fromIterable(_getKeysOfObject(jsObject), value: (key) {
    // print(
    //     '${(jsObject is djs.JsObject)}, $key, ${jsObject.runtimeType} ${_nested(jsObject)}');
    return _nested(js.getProperty(jsObject, key));
  });
}

// Both of these interfaces exist to call `Object.keys` from Dart.
//
// But you don't use them directly. Just see `jsToMap`.
@JS('Object.keys')
external List<String> _getKeysOfObject(jsObject);

// dynamic jsToMap2(thing) {
//   if (thing is djs.JsArray) {
//     List res = [];
//     djs.JsArray a = thing;
//     a.forEach((otherthing) {
//       res.add(jsToMap(otherthing));
//     });
//     return res;
//   } else if (thing is djs.JsObject) {
//     Map res = Map();
//     djs.JsObject o = thing;
//     Iterable<String> k = _getKeysOfObject([o]);
//     k.forEach((String k) {
//       res[k] = jsToMap(o[k]);
//     });
//     return res;
//   } else {
//     return thing;
//   }
// }
