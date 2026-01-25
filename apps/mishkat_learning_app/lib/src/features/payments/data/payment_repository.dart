import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
import 'razorpay_js.dart' if (dart.library.io) 'razorpay_web_stub.dart';

class PaymentRepository {
  final FirebaseFunctions _functions;
  final Razorpay _razorpay = Razorpay();

  PaymentRepository(this._functions);

  void init({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onFailure,
    required void Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;

    if (!kIsWeb) {
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }
  }

  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
  }

  Future<String> createOrder({
    required double amount,
    required String currency,
    required String courseId,
  }) async {
    try {
      final result = await _functions.httpsCallable('createRazorpayOrder').call({
        'amount': amount,
        'currency': currency,
        'courseId': courseId,
      });
      return result.data['orderId'] as String;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  void openCheckout({
    required String orderId,
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
  }) {
    final keyId = dotenv.env['RAZORPAY_KEY_ID'] ?? '';
    
    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // amount in paise
      'name': 'Mishkat Learning',
      'order_id': orderId,
      'description': description,
      'timeout': 300, // in seconds
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    if (kIsWeb) {
      try {
        final jsOptions = js_util.jsify(options);
        
        js_util.setProperty(jsOptions, 'handler', js_util.allowInterop((response) {
          final paymentId = js_util.getProperty(response, 'razorpay_payment_id');
          final orderId = js_util.getProperty(response, 'razorpay_order_id');
          final signature = js_util.getProperty(response, 'razorpay_signature');
          
          if (_onSuccess != null) {
            _onSuccess!(PaymentSuccessResponse.fromMap({
              'razorpay_payment_id': paymentId,
              'razorpay_order_id': orderId,
              'razorpay_signature': signature,
            }));
          }
        }));

        final modal = js_util.jsify({
          'ondismiss': js_util.allowInterop(() {
            if (_onFailure != null) {
              _onFailure!(PaymentFailureResponse.fromMap({
                'code': 2,
                'message': 'Payment cancelled by user',
              }));
            }
          })
        });
        js_util.setProperty(jsOptions, 'modal', modal);

        final razorpayJS = RazorpayJS(jsOptions);
        razorpayJS.open();
      } catch (e) {
        print('Error opening Razorpay JS: $e');
      }
    } else {
      try {
        _razorpay.open(options);
      } catch (e) {
        print('Error opening checkout: $e');
      }
    }
  }

  // Store callbacks for web
  void Function(PaymentSuccessResponse)? _onSuccess;
  void Function(PaymentFailureResponse)? _onFailure;
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(FirebaseFunctions.instanceFor(region: 'us-central1'));
});

final userPaymentsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('payments')
      .where('uid', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});
