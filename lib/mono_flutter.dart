library mono_flutter;

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mono_flutter/extensions/num.dart';

import 'models/mono_event.dart';
import 'models/mono_event_data.dart';
import 'mono_web_view.dart';

export 'mono_web_view.dart';

class MonoFlutter {
  final MethodChannel channel = MethodChannel('com.wiseminds.mono_flutter');
  launch(BuildContext context, String key,
      {String? reference,
      String? config,
      String? authCode,
      Function()? onLoad,
      Function()? onClosed,
      Function(MonoEvent, MonoEventData)? onEvent,
      Function(dynamic)? onSuccess}) {
    if (kIsWeb) {
      channel.invokeMethod('setup', {
        'key': key,
        'reference': reference ?? 15.getRandomString,
        'config': config,
        'authCode': authCode
      });

      channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onLoad':
            if (onLoad != null) onLoad();
            return true;
          case 'onClose':
            if (onClosed != null) onClosed();
            return true;
          case 'onSuccess':
            if (onSuccess != null) onSuccess(call.arguments['data']);
            return true;
          case 'onEvent':
            if (onEvent != null) {
              print(call.arguments);
              print(call.arguments.runtimeType);
              final args = (call.arguments as Map<Object?, Object?>)
                  .map<String, Object?>(
                      (key, value) => MapEntry('$key', value));
              // onEvent(call.arguments['eventName'], call.arguments['data']);
              final event =
                  MonoEvent.unknown.fromString(args['eventName'].toString());

              onEvent(event,
                  MonoEventData.fromJson(jsonDecode(args['data'].toString())));
            }
            return true;

          default:
        }
      });
    } else {
      Navigator.of(context)
          .push(CupertinoPageRoute(
              builder: (c) => MonoWebView(
                    apiKey: 'test_pk_qtys19MqGkmrkGk9RDjc',
                    config: {
                      "selectedInstitution": {
                        "id": "5f2d08bf60b92e2888287703",
                        "auth_method": "internet_banking"
                      }
                    },
                    authCode: authCode,
                    onEvent: (event, data) {
                      print('event: $event, data: $data');
                    },
                    onClosed: () {
                      print('Modal closed');
                    },
                    onLoad: () {
                      print('Mono loaded successfully');
                    },
                    onSuccess: (code) {
                      print('Mono Success $code');
                    },
                  )))
          .then((code) => print(code));
    }
  }
}
