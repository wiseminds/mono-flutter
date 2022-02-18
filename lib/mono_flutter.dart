library mono_flutter;

import 'package:flutter/services.dart';

export 'mono_web_view.dart';

class MonoFlutter {
  final MethodChannel channel = MethodChannel('mono_flutter');
  launch() {
    channel.invokeMethod('setup');
  }
}
