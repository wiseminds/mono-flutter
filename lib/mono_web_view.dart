import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mono_flutter/extensions/map.dart';
import 'package:mono_flutter/extensions/num.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'models/mono_event.dart';
import 'models/mono_event_data.dart';
import 'mono_html.dart';

class MonoWebView extends StatefulWidget {
  /// Public API key gotten from your mono dashboard
  final String apiKey, reAuthCode;

  final String? reference;

  /// a function called when transaction succeeds
  final Function(String code)? onSuccess;

  /// a function called when user clicks the close button on mono's page
  final Function()? onClosed;

  /// a function called when the mono widget loads
  final Function()? onLoad;

  /// An overlay widget to display over webview if page fails to load
  final Widget? error;

  final Function(MonoEvent event, MonoEventData data)? onEvent;

  final Map<String, dynamic>? config;

  const MonoWebView(
      {Key? key,
      required this.apiKey,
      this.error,
      this.onEvent,
      this.onSuccess,
      this.onClosed,
      this.onLoad,
      this.reference,
      this.config,
      this.reAuthCode = ''})
      : super(key: key);

  @override
  MonoWebViewState createState() => MonoWebViewState();
}

class MonoWebViewState extends State<MonoWebView> {
  late WebViewController _webViewController;

  // final url = 'https://connect.withmono.com/?key=';
  bool isLoading = false;
  bool hasError = false;

  late String contentBase64;

  // await controller.loadUrl('data:text/html;base64,$contentBase64');

  @override
  void initState() {
    contentBase64 = base64Encode(const Utf8Encoder().convert(MonoHtml.build(
        widget.apiKey,
        widget.reference ?? 15.getRandomString,
        widget.config,
        widget.reAuthCode)));
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (String finishedUrl) {
            isLoading = false;
            setState(() {});
          },
          onWebResourceError: (WebResourceError error) {
            isLoading = false;
            setState(() {
              hasError = true;
            });
          }
        ),
      )
    // javascript channel for events sent by mono
      ..addJavaScriptChannel('MonoClientInterface',
          onMessageReceived: (JavaScriptMessage message) {
        if (kDebugMode) print('MonoClientInterface, ${message.message}');
        var res = json.decode(message.message);
        if (kDebugMode) {
          print('MonoClientInterface, ${(res as Map<String, dynamic>)}');
        }
        handleResponse(res as Map<String, dynamic>);
      })
      ..loadRequest(Uri.parse('data:text/html;base64,$contentBase64'));

    _webViewController = controller;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.onClosed != null) widget.onClosed!();
        return true;
      },
      child: Material(
        child: GestureDetector(
            onTap: () {
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            },
            child: SafeArea(
              child: Stack(children: [
                Container(
                  // margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent)),
                  child: WebViewWidget(
                      controller: _webViewController,
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>{}..add(
                              Factory<TapGestureRecognizer>(
                                  () => TapGestureRecognizer()
                                    ..onTapDown = (tap) {
                                      SystemChannels.textInput.invokeMethod(
                                          'TextInput.hide'); //This will hide keyboard on tapdown
                                    }))),
                ),
                if (isLoading)
                  const Center(child: CupertinoActivityIndicator()),
                if (hasError) widget.error ?? _error
              ]),
            )),
      ),
    );
  }

  /// A default overlay widget to display over webview if page fails to load
  Widget get _error => Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: const Text('Reload'),
                onPressed: () {
                  _webViewController.reload();
                }),
          ),
          const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Sorry An error occurred could not connect with Mono',
                  textAlign: TextAlign.center)),
        ],
      ));

  /// parse event from javascript channel
  void handleResponse(Map<String, dynamic>? body) {
    String? key = body!['type'];
    if (key != null) {
      switch (key) {
        // case 'mono.connect.widget.account_linked':
        case 'mono.modal.linked':
          var response = body['response'];
          if (response == null) return;
          var code = response['code'];
          if (widget.onSuccess != null) widget.onSuccess!(code);
          if (mounted) Navigator.of(context).pop(code);
          break;
        // case 'mono.connect.widget.closed':
        case 'mono.modal.closed':
          if (widget.onClosed != null) widget.onClosed!();
          if (mounted) Navigator.of(context).pop();
          break;
        case 'mono.modal.onLoad':
          if (mounted && widget.onLoad != null) widget.onLoad!();
          break;

        default:
          final event = MonoEvent.unknown.fromString(key.split('.').last);
          if (widget.onEvent != null) {
            widget.onEvent!(event, MonoEventData.fromJson(body.getKey('data')));
          }
          break;
      }
    }
  }
}
