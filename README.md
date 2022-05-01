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

## Preview
you can checkout a web preview here https://wiseminds.github.io/mono-flutter

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
      // MonoConnect.open()
       if(authCode && String(authCode).length > 0) {
        MonoConnect.reauthorise(authCode);
      }
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


###Reauthorization
Passing the [authCode] to the launch command
This package will automatically call [connect.reauthorise(authCode)]
```
  connect.reauthorise(authCode);
```

Reauth code is a mono generated code for the account you want to re-authenticate,
which must be requested by your server and sent to your frontend where you can
pass it to mono connect widget.
Mono connect widget will ask for the required information and re-authenticate the
user's account and notify your server.
Once the reauthorisation is complete, the mono.events.account_reauthorized event will
be sent to your webhook, following with mono. events. account_updated once the synced
data is available.

