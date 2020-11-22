# mono_flutter


[![pub package](https://img.shields.io/badge/Pub-0.0.1-green.svg)](https://pub.dartlang.org/packages/mono_flutter)

A Flutter plugin integrating the official android and ios SDK for Mono (financial data Platform) (https://mono.co/)

<p align="center">
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot.jpeg" alt="Screenshot" height="300" />
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot2.jpeg" alt="Screenshot" height="300" />
</p>


## Usage

Import `package:mono_flutter/mono_flutter.dart` and use the methods in `MonoFlutter` class.



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
        onPressed: () => Navigator.of(context)
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
            .then((code) => print(code)),
      ));
    }
}

```

checkout the example project for full implementation