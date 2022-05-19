import 'dart:async';
import 'dart:convert';

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
      'com.wiseminds.mono_flutter',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = MonoFlutterWeb();
    channel.setMethodCallHandler(
        (call) => pluginInstance.handleMethodCall(call, channel));
    // channel.invokeMethod('onLoad', {});
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(
      MethodCall call, MethodChannel channel) async {
    // final MethodChannel channel = MethodChannel('com.wiseminds.mono_flutter', );
    switch (call.method) {
      case 'setup':
        onLoad() {
          // print('MonoFlutterWeb: loaded');
          channel.invokeMethod('onLoad', {});
        }
        onClose() {
          // print('MonoFlutterWeb: onClose: ');
          channel.invokeMethod('onClose', {});
        }
        onEvent(eventName, data) {
          // print(
          //     'MonoFlutterWeb: onEvent: $eventName,${eventName.runtimeType} :${data.runtimeType} $data, ${jsToMap(data)}');
          channel.invokeMethod('onEvent',
              {'eventName': eventName, 'data': jsonEncode(jsToMap(data))});
        }
        onSuccess(data) {
          // print('MonoFlutterWeb: onSuccess:${data.runtimeType} $data');
          channel.invokeMethod('onSuccess', jsonEncode(jsToMap(data)));
        }

        setProperty(html.window, 'onLoad', allowInterop(onLoad));
        setProperty(html.window, 'onClose', allowInterop(onClose));
        setProperty(html.window, 'onEvent', allowInterop(onEvent));
        setProperty(html.window, 'onSuccess', allowInterop(onSuccess));

        setupMonoConnect(
            call.arguments['key'] as String,
            call.arguments['reference'] as String?,
            call.arguments['config'] as String?,
            call.arguments['authCode'] as String?);
        // try {
        //   var authCode =  call.arguments['authCode'] as String?;
        //  if(authCode != null && authCode.isNotEmpty) {
        //    reauthorise(authCode);
        //  }
        // } catch (e) {
        //   print('MonoFlutterWeb: onLoad: $e');
        // }
        return;
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
