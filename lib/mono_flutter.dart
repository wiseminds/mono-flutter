library mono_flutter;

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mono_flutter/extensions/num.dart';
import 'package:mono_flutter/models/models.dart';

import 'mono_web_view.dart';

export 'models/models.dart';
export 'mono_web_view.dart';

class MonoFlutter {
  final MethodChannel channel =
      const MethodChannel('com.wiseminds.mono_flutter');

  /// Launch the mono-connect widget,
  /// [key] - YOUR_PUBLIC_KEY_HERE
  /// [paymentId] - Use this to initiate direct payment
  /// [onSuccess] -  This function is called when a user has successfully onboarded their account. It should take a single String argument containing the token that can be exchanged for an account id.
  /// [onClose] -The optional closure is called when a user has specifically exited the Mono Connect flow (i.e. the widget is not visible to the user). It does not take any arguments.
  /// [onLoad] - This function is invoked the widget has been mounted unto the DOM. You can handle toggling your trigger button within this callback.
  /// [onEvent] - This optional function is called when certain events in the Mono Connect flow have occurred, for example, when the user selected an institution. This enables your application to gain further insight into the Mono Connect onboarding flow. See the data object below for details.
  /// [reference] - This optional string is used as a reference to the current instance of Mono Connect. It will be passed to the data object in all onEvent callbacks. It's recommended to pass a random string.
  /// [config] - This optional configuration object is used as a way to load the Connect Widget directly to an institution login page.
  /// ```{
  ///selectedInstitution: {
  ///  id: "5f2d08c060b92e2888287706", // the id of the institution to load
  ///  auth_method: "internet_banking" // internet_banking or mobile_banking
  ///}
  ///}```
  /// [reAuthCode] code is a mono generated code for the account you want to re-authenticate,
  /// which must be requested by your server and sent to your frontend where you can
  /// pass it to mono connect widget.
  /// Mono connect widget will ask for the required information and re-authenticate the
  /// user's account and notify your server.
  ///  Once the reauthorisation is complete, the mono.events.account_reauthorized event will
  ///  be sent to your webhook, following with mono. events. account_updated once the synced
  ///  data is available.
  /// [paymentMode] set to true if you want to initiate a direct payment
  launch(
    BuildContext context,
    String key, {
    required MonoCustomer customer,
    String scope = "auth",
    String? reference,
    String? reAuthCode,
    ConnectInstitution? selectedInstitution,
    Function()? onLoad,
    Function(String?)? onClosed,
    Function(MonoEvent, MonoEventData)? onEvent,
    Function(String)? onSuccess,
  }) {
    if (kIsWeb) {
      channel.invokeMethod('setup', {
        'key': key,
        'reference': reference ?? 15.getRandomString,
        'data': jsonEncode({'customer': customer.toMap()}),
        'authCode': reAuthCode,
        'scope': scope
      });

      channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onLoad':
            if (onLoad != null) onLoad();
            return true;
          case 'onClose':
            onClosed?.call(null);

            return true;
          case 'onSuccess':
            final args = (jsonDecode(call.arguments.toString())
                    as Map<Object?, Object?>)
                .map<String, Object?>((key, value) => MapEntry('$key', value));

            if (onSuccess != null) {
              if (kDebugMode) {
                print('PRINTING MONO CODE-Success: ${args['code']}');
              }
              onSuccess(args['code'].toString());
            }
            return true;
          case 'onEvent':
            if (onEvent != null) {
              final args = (call.arguments as Map<Object?, Object?>)
                  .map<String, Object?>(
                      (key, value) => MapEntry('$key', value));
              final event =
                  MonoEvent.unknown.fromString(args['eventName'].toString());

              onEvent(event,
                  MonoEventData.fromJson(jsonDecode(args['data'].toString())));
            }
            return true;

          default:
        }
      });
      // return
    } else {
      Navigator.of(context)
          .push(
        CupertinoPageRoute(
          builder: (c) => MonoWebView(
            apiKey: key,
            customer: customer,
            reAuthCode: reAuthCode ?? '',
            onEvent: onEvent,
            onClosed: onClosed,
            onLoad: onLoad,
            scope: "auth",
            selectedInstitution: selectedInstitution,
            onSuccess: onSuccess,
            reference: reference,
          ),
        ),
      ).then((code) {
        if (kDebugMode) {
          print(code);
        }
      });
    }
  }
}
