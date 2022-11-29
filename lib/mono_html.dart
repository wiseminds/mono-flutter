import 'dart:convert';

class MonoHtml {
  static build(String key, String reference,
          [Map<String, dynamic>? config, String? authCode]) =>
      '''<!DOCTYPE html>
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
             key: "$key",
             reference: "$reference",
            onSuccess:  (data) => {
              const response = {"type":"mono.modal.linked", response: {...data}}
              MonoClientInterface.postMessage(JSON.stringify(response))
            },
             onEvent: (eventName, data) => {
             const response = { type: 'onEvent', eventName, data }
              MonoClientInterface.postMessage(JSON.stringify(response))
            },
            onClose: ()=> {
              const response = {type: 'mono.modal.closed', }
              MonoClientInterface.postMessage(JSON.stringify(response))
            },
              onLoad: ()=> {
              const response = {type: 'mono.modal.onLoad', }
              MonoClientInterface.postMessage(JSON.stringify(response))
            }
          };
          const MonoConnect = new Connect(options);
          const configJson = JSON.parse(`${jsonEncode(config ?? {})}`)
          const authCode = "$authCode";

          MonoConnect.setup(configJson);

          if(authCode && String(authCode).length > 2) { 
            MonoConnect.reauthorise(authCode);
          }

          MonoConnect.open()
        }
      </script>
    </body>
</html>''';

  /// Raw mono html formation
  static String buildPaymentView(
    String? key,
    String? paymentId, [
    Map<String, dynamic>? config,
    String reference = '',
    String? authCode,
  ]) =>
      '''
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mono Connect</title>
</head>

<body onload="setupMonoConnect()" style="border-radius: 20px; background-color:#fff;height:100vh;overflow: hidden; ">
    <script src="https://connect.withmono.com/connect.js"></script>
    <script type="text/javascript">
        window.onload = setupMonoConnect;
        function setupMonoConnect() {
            var connect = new Connect({
                key: "$key",
                scope: "payments",
                reference: `$reference`.length > 0 ? `$reference` : null,
                data: {
                    payment_id: "$paymentId",
                },
                onSuccess: (code) =>
                    sendMessage({ type: "onSuccess", data: code}),
                onLoad: () => sendMessage({ type: "onLoad" }),
                onClose: () => sendMessage({ type: "onClose" }),
                onEvent: (eventName, data) =>
                  sendMessage({
                    type: "onEvent",
                    eventName: eventName,
                    data: { ...data },
                  }),
            });
            

          const configJson = JSON.parse(`${jsonEncode(config ?? {})}`)
          const authCode = "$authCode";
          
          connect.setup(configJson);

          if(authCode && String(authCode).length > 2) { 
            connect.reauthorise(authCode);
          }
            
            connect.open()
            function sendMessage(message) {
              if (window.MonoClientInterface && window.MonoClientInterface.postMessage) {
                  MonoClientInterface.postMessage(JSON.stringify(message));
              }
          } 
        }
    </script>
</body>

</html>
''';
}
