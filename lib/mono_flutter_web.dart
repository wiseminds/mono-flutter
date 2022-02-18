import 'dart:async';

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:js';
import 'dart:js_util';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:mono_flutter/mono.dart';

/// A web implementation of the MonoFlutter plugin.
class MonoFlutterWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'mono_flutter',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = MonoFlutterWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'setup':
        final onLoad = () {
          print('MonoFlutterWeb: loaded');
        };
        final onClose = () {
          print('MonoFlutterWeb: onClose: ');
        };
        final onEvent = (eventName, data) {
          print(
              'MonoFlutterWeb: onEvent: $eventName, :${data.runtimeType} $data');
        };
        final onSuccess = (data) {
          print('MonoFlutterWeb: onSuccess:${data.runtimeType} $data');
        };

        setProperty(html.window, 'onLoad', allowInterop(onLoad));
        setProperty(html.window, 'onClose', allowInterop(onClose));
        setProperty(html.window, 'onEvent', allowInterop(onEvent));
        setProperty(html.window, 'onSuccess', allowInterop(onSuccess));

        return setupMonoConnect(call.arguments['key'] as String,
            call.arguments['reference'] as String?, call.arguments['config'] as String?);
      case 'open':
        return open();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'mono_flutter for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Returns a [String] containing the version of the platform.
  Future<String> getPlatformVersion() {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }
}
