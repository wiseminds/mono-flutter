library mono_flutter;

import 'dart:convert';
// import 'dart:js' as js;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mono_flutter/mono_flutter_web.dart';
import 'package:mono_flutter/mono_web_view.dart';


export 'mono_web_view.dart';
// export 'mono_flutter_web.dart';

class MonoFlutter {
  static const url = 'https://connect.withmono.com/?key=';

  static const key = Key('mono_flutter');

  static Widget buildPage(BuildContext context, String apiKey) {
    if (kIsWeb) {
      String  contentBase64 =
        base64Encode(const Utf8Encoder().convert(_buildHtml(apiKey)));
    String src = 'data:text/html;base64,$contentBase64';
      MonoFlutterWeb.setup(src, key);
      return AbsorbPointer(
          child: RepaintBoundary(
        child: HtmlElementView(
          key: key,
          viewType: src,
        ),
      ));
    } else
      return MonoWebView(apiKey: apiKey);
  }

  static String _buildHtml(String key) => ''' <!DOCTYPE html>
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
                          console.log(response)
                          MonoClientInterface.postMessage(JSON.stringify(response))
                        },
                        onClose: function() {
                          const response = {type: 'mono.modal.closed', }
                          console.log(response)
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
