# mono_flutter


[![pub package](https://img.shields.io/badge/Pub-0.0.1-green.svg)](https://pub.dartlang.org/packages/mono_flutter)

A Flutter plugin integrating the official android and ios SDK for Mono (financial data Platform) (https://mono.co/)

<p align="center">
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot.jpeg" alt="Screenshot" height="300" />
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot2.jpeg" alt="Screenshot" height="300" />
</p>

<p align="center">
  <img src="https://github.com/wiseminds/mono-flutter/raw/web/web-screenshot1.png" alt="Web Screenshot" height="300" />
  
</p><p align="center">
  <img src="https://github.com/wiseminds/mono-flutter/raw/web/web-screenshot2.png" alt="Web Screenshot" height="300" />
  
</p>


## Usage

Import `package:mono_flutter/mono_flutter.dart` and use the methods in `MonoFlutter` class.


for web support ass the following to index.html :

 ``` HTML 

 <script src="https://connect.withmono.com/connect.js"></script>
  <script>
    function setupMonoConnect(key, reference, config) {
      const options = {
        key,
         reference,
        onSuccess: onSuccess,
        onEvent: onEvent,
        onClose: onClose,
        onLoad: onLoad
      };
      const MonoConnect = new Connect(options);
      const configJson = JSON.parse(config ?? `{}`);

      MonoConnect.setup(configJson);
      MonoConnect.open()
    }
  </script>

 ```

Example:
```dart
import 'package:mono_flutter/mono_flutter.dart';

void main() async {
    runApp(App());
}

class App extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return  Center(
          child: RaisedButton(
        child: Text('launch mono'),
        onPressed: () {
           if (kIsWeb){
            return MonoFlutter().launch(
                'API_KEY',
                '',
                jsonEncode({
                  "selectedInstitution": {
                    "id": "5f2d08bf60b92e2888287703",
                    "auth_method": "internet_banking"
                  }
                }));}
                Navigator.of(context)
            .push(CupertinoPageRoute(
                builder: (c) => MonoWebView(
                      apiKey: 'API_KEY',
                      onClosed: () {
                        print('Modal closed');
                      },
                      onSuccess: (code) {
                        print('Mono Success $code');
                      },
                    )))
            .then((code) => print(code));
            },
      ));
    }
}

```

checkout the example project for full implementation