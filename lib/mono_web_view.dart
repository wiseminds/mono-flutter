import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MonoWebView extends StatefulWidget {
  /// Public API key gotten from your mono dashboard
  final String apiKey;

  /// a function called when transaction succeeds
  final Function(String code) onSuccess;

  /// a function called when user clicks the close buton on mono's page
  final Function onClosed;

  /// An overlay widget to display over webview if page fails to load
  final Widget error;

  const MonoWebView(
      {Key key,
      @required this.apiKey,
      this.error,
      this.onSuccess,
      this.onClosed})
      : assert(apiKey != null, 'API key cannot be null'),
        super(key: key);

  @override
  _MonoWebViewState createState() => _MonoWebViewState();
}

class _MonoWebViewState extends State<MonoWebView> {
  WebViewController _webViewController;
  final url = 'https://connect.withmono.com/?key=';
  bool isLoading = false;
  bool hasError = false;

  String contentBase64;

  // await controller.loadUrl('data:text/html;base64,$contentBase64');

  @override
  void initState() {
    contentBase64 =
        base64Encode(const Utf8Encoder().convert(_buildHtml(widget.apiKey)));
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.onClosed != null) widget.onClosed();
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
            child: RaisedButton(
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
  void handleResponse(Map<String, dynamic> body) {
    String key = body['type'];
    if (body != null && key != null) {
      switch (key) {
        case 'mono.connect.widget.account_linked':
        case 'mono.modal.linked':
          var response = body['response'];
          if (response == null) return;
          var code = response['code'];
          if (widget.onSuccess != null) widget.onSuccess(code);
          if (mounted) Navigator.of(context).pop(code);
          break;
        case 'mono.connect.widget.closed':
        case 'mono.modal.closed':
          if (widget.onClosed != null) widget.onClosed();
          if (mounted) Navigator.of(context).pop();
          break;
        default:
      }
    }
  }

  /// build Mono html page
  String _buildHtml(String key) => ''' <!DOCTYPE html>
            <html lang="en">
                <head>
                  <meta charset="UTF-8">
                  <meta http-equiv="X-UA-Compatible" content="ie=edge">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Mono Connect</title>
                </head>
                <body onload="setupMonoConnect()" style="background-color:#fff;height:100vh;overflow: scroll;">
                  <script src="https://connect.withmono.com/connect.js"></script>
                  <script type="text/javascript">
                    window.onload = setupMonoConnect;
                    function setupMonoConnect() {
                      const options = {
                        onSuccess: function(data) {
                          const response = {"type":"mono.modal.linked", response: {...data}}
                          MonoClientInterface.postMessage(JSON.stringify(response))
                        },
                        onClose: function() {
                          const response = {type: 'mono.modal.closed', }
                          MonoClientInterface.postMessage(JSON.stringify(response))
                        }
                      };
                      const MonoConnect = new Connect("$key", options);
                      MonoConnect.setup();
                      MonoConnect.open()
                    }
                  </script>
                </body>
            </html>''';
}
