import 'dart:convert';

class MonoHtml {
  static build(
    String key,
    String reference,
    String scope, [
    Map<String, dynamic>? data,
    String? authCode,

    // bool paymentScope = false
  ]) =>
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
          const configJson = JSON.parse(`${jsonEncode({...?data})}`)
          
          const options = {
             key: "$key",
             reference: "$reference",
             scope: "$scope" , 
           
             onSuccess:  (data) => {
              const response = {"type":"mono.modal.linked", response: {...data}}
              MonoClientInterface.postMessage(JSON.stringify(response))
             },
             onEvent: (eventName, data) => {
             const response = { type: 'onEvent', eventName, data }
              MonoClientInterface.postMessage(JSON.stringify(response))
              },
             onClose: (data) => {
              const response = {type: 'mono.modal.closed', response: {...data}}
              MonoClientInterface.postMessage(JSON.stringify(response))
             },
              onLoad: ()=> {
              const response = {type: 'mono.modal.onLoad', }
              MonoClientInterface.postMessage(JSON.stringify(response))
            }
          };

           
          const MonoConnect = new Connect(options);
       
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
}
