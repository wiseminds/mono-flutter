@JS()
library mono;

import 'package:js/js.dart';

// invokes Mono.setup(data)`.
@JS('MonoConnect.setup')
external void setup(Object obj);

@JS('MonoConnect.open')
external void open();


@JS('setupMonoConnect')
external void setupMonoConnect(String key, String reference);