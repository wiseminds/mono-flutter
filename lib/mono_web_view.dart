import 'dart:convert';
import 'dart:io';

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
  final String apiKey;

  final String? reference, reAuthCode;

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
      this.config, this.authCode})
      : super(key: key);

  @override
  _MonoWebViewState createState() => _MonoWebViewState();
}

class _MonoWebViewState extends State<MonoWebView> {
  late WebViewController _webViewController;
  final url = 'https://connect.withmono.com/?key=';
  bool isLoading = false;
  bool hasError = false;

  late String contentBase64;

  // await controller.loadUrl('data:text/html;base64,$contentBase64');

  @override
  void initState() {
    contentBase64 = base64Encode(const Utf8Encoder().convert(MonoHtml.build(
        widget.apiKey, widget.reference ?? 15.getRandomString, widget.config, widget.authCode)));
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
              WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus();
            },
            child: SafeArea(
              child: Stack(children: [
                Container(
                  // margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent)),
                  child: WebView(
                    initialUrl:
                        'data:text/html;base64,$contentBase64', // ??url + widget.apiKey,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      // if (!_controller.isCompleted)
                      //   _controller.complete(webViewController);
                      _webViewController = webViewController;
                    },
                    onPageStarted: (String url) {
                      // hasFoward = await _webViewController?.canGoForward();
                      setState(() {
                        isLoading = true;
                        hasError = false;
                      });
                    },
                    javascriptChannels: <JavascriptChannel>[
                      _monoJavascriptChannel(context),
                    ].toSet(),
                    gestureRecognizers: Set()
                      ..add(Factory<TapGestureRecognizer>(
                          () => TapGestureRecognizer()
                            ..onTapDown = (tap) {
                              SystemChannels.textInput.invokeMethod(
                                  'TextInput.hide'); //This will hide keyboard ontapdown
                            })),
                    debuggingEnabled: kDebugMode,
                    onWebResourceError: (err) async {
                      print(err);
                      isLoading = false;
                      setState(() {
                        hasError = true;
                      });
                    },
                    onPageFinished: (String url) async {
                      isLoading = false;
                      setState(() {});
                      // _webViewController.evaluateJavascript(
                      //     'MonoClientInterface.postMessage("reyfhgjgf");123;');
                    },
                  ),
                ),
                if (isLoading)
                  Center(
                    child: CupertinoActivityIndicator(),
                  ),
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
                child: Text('Reload'),
                onPressed: () {
                  _webViewController.reload();
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Sorry An error occured could not connect with Mono',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ));

  /// javascript channel for events sent by mono
  JavascriptChannel _monoJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        // name: 'top',
        name: 'MonoClientInterface',
        onMessageReceived: (JavascriptMessage message) {
          if (kDebugMode) print('MonoClientInterface, ${message.message}');
          var res = json.decode(message.message);
          if (kDebugMode)
            print('MonoClientInterface, ${(res as Map<String, dynamic>)}');
          handleResponse(res as Map<String, dynamic>);
        });
  }

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
          print('onEvent');

          final event = MonoEvent.unknown.fromString(key.split('.').last);
          if (widget.onEvent != null)
            widget.onEvent!(event, MonoEventData.fromJson(body.getKey('data')));
          break;
      }
    }
  }
}
