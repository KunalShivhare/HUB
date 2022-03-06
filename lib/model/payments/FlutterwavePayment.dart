import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../util.dart';
import '../localSettings.dart';
import '../model.dart';

//   static const String NGN = "NGN";
//   static const String KES = "KES";
//   static const String RWF = "RWF";
//   static const String UGX = "UGX";
//   static const String ZMW = "ZMW";
//   static const String GHS = "GHS";
//   static const String XAF = "XAF";
//   static const String XOF = "XOF";

class FlutterwavePayment extends StatefulWidget {
  final Function(String) onFinish;

  FlutterwavePayment({required this.onFinish,});

  @override
  State<StatefulWidget> createState() {
    return FlutterwavePaymentState();
  }
}

class FlutterwavePaymentState extends State<FlutterwavePayment> {

  String returnURL = 'https://cancel.flutterwave-example.com';
  String cancelURL = 'cancel.example.com';
  late MainModel _mainModel;
  late WebViewController _con;
  var _ref = "";

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _ref = DateTime.now().millisecondsSinceEpoch.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Center(child: Text("Flutterwave Payment")),
        ),
        body: WebView(
          initialUrl: "",
          onWebViewCreated: (WebViewController webViewController) {
            _con = webViewController;
            _loadHTML();
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            dprint("navigationDelegate ${request.url}");
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);
              if (uri.queryParameters['status'] == "successful"){
                widget.onFinish(_ref);
                Navigator.of(context).pop();
              } else
                Navigator.of(context).pop();
            }
            if (request.url.contains(cancelURL))
              Navigator.of(context).pop();
            return NavigationDecision.navigate;
          },
        ),
      );
    }

  _loadHTML() async {
    _con.loadUrl(Uri.dataFromString(_makeText(),
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  String _makeText(){
    var code = _mainModel.localAppSettings.code;
    // var returnURL = _mainModel.currentBase + "flutterwave_success?booking=${mainModel.lastBooking}";
    code = "NGN";
    var amount = (localSettings.getTotal(_mainModel)).toStringAsFixed(_mainModel.localAppSettings.digitsAfterComma);
    // var razorpayName = mainModel.localAppSettings.razorpayName;
    var desc = getTextByLocale(localSettings.price.name);
    var userName = _mainModel.userAccount.getCurrentAddress().name;
    var userEmail = _mainModel.userEmail;
    var userPhone = _mainModel.userAccount.getCurrentAddress().phone;
    // var userAddress = mainModel.userAccount.getCurrentAddress().name;

    // print("key=$key code=$code amount=$amount razorpayName=$razorpayName");
    // print("desc=$desc userName=$userName userEmail=$userEmail userPhone=$userPhone userAddress=$userAddress");


    return '''<!DOCTYPE html>
      <html>
      <meta name="viewport" content="width=device-width">
      <head><title>RazorPay Web Payment</title></head>
      <body>
      <script src="https://checkout.flutterwave.com/v3.js"></script>
      <script>
      const queryString = window.location.search;
      console.log(queryString);
      
      FlutterwaveCheckout({
      public_key: "${_mainModel.localAppSettings.flutterWavePublicKey}",
      tx_ref: "$_ref",
      amount: $amount,
      currency: "$code",
      country: "US",
      payment_options: " ",
      redirect_url: // specified redirect URL
        "$returnURL",
      meta: {
        consumer_id: 23,
        consumer_mac: "92a3-912ba-1192a",
      },
      customer: {
        email: "$userEmail",
        phone_number: "$userPhone",
        name: "$userName",
      },
      callback: function (data) {
        console.log(data);
      },
      onclose: function() {
        window.parent.postMessage("MODAL_CLOSED","*");   //3
      },
      customizations: {
        title: "My store",
        description: "$desc",
        logo: "",
      },
    });
 
</script>
</body>
</html>
        ''';
  }

}
