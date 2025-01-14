import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mono_flutter/extensions/map.dart';
import 'package:mono_flutter/models/models.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

const String urlScheme = 'https';
const String connectHost = 'connect.mono.co';
const String version = '2023-12-14';
const darkMode =
    'document.head.appendChild(document.createElement("style")).innerHTML="html { filter: invert(.95) hue-rotate(180deg) }"';

class MonoWebView extends StatefulWidget {
  /// Public API key gotten from your mono dashboard
  final String apiKey, reAuthCode;

  final String? reference;

  /// The customer objects expects the following keys based on the following conditions:
  /// New Customers: For new customers, the customer object expects the user’s name, email and identity
  /// Existing Customers: For existing customers, the customer object expects only the customer ID.
  final MonoCustomer customer;

  /// a function called when transaction succeeds
  final Function(String code)? onSuccess;

  /// a function called when user clicks the close button on mono's page
  final Function(String? code)? onClosed;

  /// a function called when the mono widget loads
  final Function()? onLoad;

  /// An overlay widget to display over webview if page fails to load
  final Widget? error;

  final String? paymentUrl;

  /// set to true if you want to initiate a direct payment
  final String scope;

  final Function(MonoEvent event, MonoEventData data)? onEvent;

  /// Allows an optional selected institution to be passed.
  final ConnectInstitution? selectedInstitution;

  const MonoWebView({
    super.key,
    required this.apiKey,
    required this.customer,
    this.error,
    this.onEvent,
    this.onSuccess,
    this.onClosed,
    this.onLoad,
    this.paymentUrl,
    this.reference,
    this.selectedInstitution,
    this.reAuthCode = '',
    this.scope = "auth",
  });

  @override
  MonoWebViewState createState() => MonoWebViewState();
}

class MonoWebViewState extends State<MonoWebView> {
  late WebViewController _webViewController;

  ValueNotifier<bool> isLoading = ValueNotifier(true);
  ValueNotifier<bool> hasError = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
          )
        : const PlatformWebViewControllerCreationParams();

    _webViewController = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) => request.grant(),
    );

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'MonoClientInterface',
        onMessageReceived: _monoJavascriptChannel,
      )
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {
          setState(() {
            isLoading.value = true;
            hasError.value = false;
          });
        },
        onPageFinished: (String url) {
          setState(() {
            isLoading.value = false;
          });
          if (Theme.of(context).brightness == Brightness.dark) {
            _webViewController.runJavaScript(darkMode);
          }
        },
        onWebResourceError: (WebResourceError error) {
          setState(() {
            isLoading.value = false;
            hasError.value = true;
          });
        },
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ));

    confirmPermissionsAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Material(
        child: GestureDetector(
          onTap: () {
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          },
          child: SafeArea(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: WebViewWidget(
                    controller: _webViewController,
                    gestureRecognizers:
                        <Factory<OneSequenceGestureRecognizer>>{}..add(
                            Factory<TapGestureRecognizer>(
                              () => TapGestureRecognizer()
                                ..onTapDown = (tap) {
                                  SystemChannels.textInput.invokeMethod(
                                    'TextInput.hide',
                                  ); //This will hide keyboard on tapdown
                                },
                            ),
                          ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isLoading,
                  builder: (context, value, child) {
                    if (value) {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                    return const SizedBox();
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: hasError,
                  builder: (context, value, child) {
                    if (value) {
                      return widget.error ?? _error;
                    }
                    return const SizedBox();
                  },
                )
              ],
            ),
          ),
        ),
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

  Future<void> confirmPermissionsAndLoad() async {
    bool isCameraGranted;

    if (!kIsWeb) {
      // Request camera permission
      final cameraStatus = await Permission.camera.status;
      isCameraGranted = cameraStatus.isGranted;
    } else {
      isCameraGranted = true;
    }

    if (!isCameraGranted) {
      // final result =
      await Permission.camera.request();
    }

    // if (result == PermissionStatus.granted) {
    await loadRequest();

    // }
  }

  Future<void> loadRequest() {
    final customerJson = {'customer': widget.customer.toMap()};
    final data = json.encode(customerJson);

    String? extraData;
    if (widget.selectedInstitution != null) {
      extraData = widget.selectedInstitution!.toJson();
    }

    final queryParameters = {
      'key': widget.apiKey,
      'version': version,
      'scope': widget.scope,
      'data': data,
      'reauth_token': widget.reAuthCode,
      if (widget.reference != null) 'reference': widget.reference,
      if (extraData != null) 'selectedInstitution': extraData,
    };

    final uri = Uri(
      scheme: urlScheme,
      host: connectHost,
      queryParameters: queryParameters,
    );

    return _webViewController.loadRequest(uri);
  }

  /// javascript channel for events sent by mono
  void _monoJavascriptChannel(JavaScriptMessage message) {
    if (kDebugMode) print('MonoClientInterface, ${message.message}');
    var res = json.decode(message.message);
    if (kDebugMode) {
      print('MonoClientInterface, ${(res as Map<String, dynamic>)}');
    }
    handleResponse(res as Map<String, dynamic>);
  }

  /// parse event from javascript channel
  void handleResponse(Map<String, dynamic>? body) {
    String? key = body!['type'];
    if (key != null) {
      switch (key) {
        case "mono.connect.widget.account_linked":
          var response = body['response'];
          if (response == null) return;
          var code = response['code'];
          if (widget.onSuccess != null) widget.onSuccess!(code);
          if (mounted) Navigator.of(context).pop(code);
          break;
        case 'mono.connect.widget.closed':
          String? code;
          try {
            code = body['data']['code'];
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
          if (code != null) widget.onSuccess?.call(code);

          widget.onClosed?.call(code);
          if (mounted) Navigator.of(context).pop(code);
          break;
        case 'mono.connect.widget_opened':
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
