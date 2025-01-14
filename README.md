# mono_flutter

[![pub package](https://img.shields.io/badge/Pub-1.0.0-green.svg)](https://pub.dartlang.org/packages/mono_flutter)

A Flutter plugin integrating the official android and ios SDK for Mono (financial data Platform) (https://withmono.com/)

Mono Connect.js is a quick and secure way to link bank accounts to Mono from within your app. Mono Connect is a drop-in framework that handles connecting a financial institution to your app (credential validation, multi-factor authentication, error handling, etc). It works on mobile and web.

For accessing customer accounts and interacting with Mono's API (Identity, Transactions, Income, DirectPay) use the server-side Mono API. For complete information about Mono Connect, head to the docs. https://docs.withmono.com/docs/ .

### Getting Started

- Register on the [Mono](https://app.withmono.com/dashboard) website and get your public and secret keys.
- Setup a server to [exchange tokens](https://docs.withmono.com/reference/authentication-endpoint) to access user financial data with your Mono secret key.

### iOS

- Add the key `Privacy - Camera Usage Description` and a usage description to your `Info.plist`.

If editing `Info.plist` as text, add:

```xml
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
<key>NSMicrophoneUsageDescription</key>
<string>your usage description here</string>
```

### Android

State the camera permission in your `android/app/src/main/AndroidManifest.xml` file.

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

### How to upgrade to the Mono Widget 2.0

If you already use Mono Connect or DirectPay, you will need to upgrade your widget to version 2 to get access to these new features. To upgrade to v2, take the following steps:

[Log in](https://app.withmono.com/dashboard) to your Mono dashboard

Visit [Preferences](https://app.withmono.com/settings/business/preferences) in the Settings section, toggle on the new version of the Mono widget, and confirm the switch.

If you would like to use the new widget and Mono's open banking APIs to build innovative solutions for your customers, you can get [started by creating a Mono account here](https://app.withmono.com).

##### screenshots

<p align="center">
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot/screenshot.png" alt="Screenshot" height="300" />
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot/screenshot2.png" alt="Screenshot" height="300" />
   <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot/screenshot3.png" alt="Screenshot" height="300" />
    <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot/screenshot4.png" alt="Screenshot" height="300" />
</p>

<p align="center">
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot/web-screenshot1.png" alt="Web Screenshot" height="300" />

</p><p align="center">
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot/web-screenshot2.png" alt="Web Screenshot" height="300" />

</p>
<p align="center">
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot/web-screenshot4.png" alt="Web Screenshot" height="300" />

</p>
<p align="center">
  <img src="https://github.com/wiseminds/mono-flutter/raw/main/screenshot/web-screenshot5.png" alt="Web Screenshot" height="300" />

</p>

## Preview

you can checkout a web preview here https://wiseminds.github.io/mono-flutter

## Usage

Import `package:mono_flutter/mono_flutter.dart` and use the methods in `MonoFlutter` class.

For web support add the following to index.html :

```HTML
<script src="https://connect.withmono.com/connect.js"></script>
 <script>
   function setupMonoConnect(key, reference, data, authCode, scope) {
     const configJson = JSON.parse(data ?? `{}`);
     const options = {
       key,
       reference,
       scope, 
       onSuccess: onSuccess,
       onEvent: onEvent,
       onClose: onClose,
       onLoad: onLoad
     };
     
     const MonoConnect = new Connect(options);

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
              scope: "auth", // NEWLY INTRODUCED 
              data:  // NEWLY INTRODUCED
                jsonEncode({
                "customer": {
                "name": "Samuel Olamide", // REQUIRED
                "email": "samuel@neem.com", // REQUIRED
                "identity": {
                  "type": "bvn",
                  "number": "2323233239",
                }
              }
              }),
              customer: MonoCustomer(
                  newCustomer: MonoNewCustomerModel(
                  name: "Samuel Olamide", // REQUIRED
                  email: "samuel@neem.com", // REQUIRED
                  identity: MonoNewCustomerIdentity(
                    type: "bvn",
                    number: "2323233239",
                  ),
                ),
                existingCustomer: MonoExistingCustomerModel(
                  id: "6759f68cb587236111eac1d4", // REQUIRED
                ),
              ),
              selectedInstitution: ConnectInstitution(
                id: "5f2d08be60b92e2888287702",
                authMethod: ConnectAuthMethod.mobileBanking,
              ),
              onEvent: (event, data) {
                print('event: $event, data: $data');
              },
              onClosed: (code) {
                print('Modal closed, $code');
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

// FOR NEW CUSTOMERS
```dart
newCustomer: MonoNewCustomerModel(
    name: "Samuel Olamide", // REQUIRED
    email: "samuel@neem.com", // REQUIRED
    identity: MonoNewCustomerIdentity(
    type: "bvn",
    number: "2323233239",
)
```
---

// FOR RETURNING CUSTOMERS
```dart
MonoExistingCustomerModel(
    id: "6759f68cb587236111eac1d4", // REQUIRED
)
```

Checkout the example project for full implementation

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
be sent to your webhook, following with mono.events.account_updated once the synced
data is available.

### Customizations

For a custom page or with a dialog, use the [MonoFlutterWebView] widget, but this is not supported on the web.

```dart
 showDialog(
      context: context,
      builder: (c) => MonoWebView(
        key: "YOUR_APPS_PUBLIC_KEY_HERE",
        scope: "auth", // NEWLY INTRODUCED 
        customer: MonoCustomer(
            newCustomer: MonoNewCustomerModel(
            name: "Samuel Olamide", // REQUIRED
            email: "samuel@neem.com", // REQUIRED
            identity: MonoNewCustomerIdentity(
              type: "bvn",
              number: "2323233239",
            ),
          ),
          existingCustomer: MonoExistingCustomerModel(
            id: "6759f68cb587236111eac1d4", // REQUIRED
          ),
        ),
        selectedInstitution: ConnectInstitution(
          id: "5f2d08be60b92e2888287702",
          authMethod: ConnectAuthMethod.mobileBanking,
        ),
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
      ),
    );
```
