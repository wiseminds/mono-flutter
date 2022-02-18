library mono_flutter;

import 'package:flutter/services.dart';
import 'package:mono_flutter/extensions/num.dart';

export 'mono_web_view.dart';

class MonoFlutter {
  final MethodChannel channel = MethodChannel('mono_flutter');
  launch(String key, [String? reference, String? config]) {
    channel.invokeMethod('setup', {
      'key': key,
      'reference': reference ?? 15.getRandomString,
      'config': config
    });
  }
}
