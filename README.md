# mono_flutter


[![pub package](https://img.shields.io/badge/Pub-0.0.1-green.svg)](https://pub.dartlang.org/packages/mono_flutter)

A Flutter plugin integrating the official android and ios SDK for Mono (financial data Platform) (https://mono.co/)

Mono Connect.js is a quick and secure way to link bank accounts to Mono from within your app. Mono Connect is a drop-in framework that handles connecting a financial institution to your app (credential validation, multi-factor authentication, error handling, etc). It works on mobile and web.

For accessing customer accounts and interacting with Mono's API (Identity, Transactions, Income, DirectPay) use the server-side Mono API For complete information about Mono Connect, head to the docs. https://docs.mono.co/docs/ .

###Getting Started
Register on the [Mono](https://app.mono.co/dashboard) website and get your public and secret keys.
Setup a server to [exchange tokens](https://docs.mono.co/reference/authentication-endpoint) to access user financial data with your Mono secret key.

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
      
       if(authCode && String(authCode).length > 0) {
        MonoConnect.reauthorise(authCode);
      }

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
          MonoFlutter().launch(
              context,
              'YOUR_PUBLIC_KEY_HERE',
              // authCode: 'code_sGjE1Zh48lFR8vr3FkrD',
              reference: DateTime.now().millisecondsSinceEpoch.toString(),
              config: jsonEncode({
                "selectedInstitution": {
                  "id": "5f2d08bf60b92e2888287703",
                  "auth_method": "internet_banking"
                }
              }),
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
            );
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

