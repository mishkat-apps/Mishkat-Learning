@JS()
library razorpay_js;

import 'package:js/js.dart';

@JS('Razorpay')
class RazorpayJS {
  external RazorpayJS(dynamic options);
  external void open();
  external void on(String event, Function callback);
}
