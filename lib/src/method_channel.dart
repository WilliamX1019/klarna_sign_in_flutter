import 'dart:async';
import 'package:flutter/services.dart';
import 'events.dart';

class KlarnaSignInPlatform {
  static const MethodChannel _methods = MethodChannel('klarna_signin/methods');
  static const EventChannel _events = EventChannel('klarna_signin/events');

  static Stream<KlarnaEvent>? _eventStream;

  static Future<void> initialize({
    required String returnUrl,
    String? environment,
    String? region,
    String? theme,
    bool? verboseLogging,
  }) async {
    await _methods.invokeMethod('initialize', {
      'returnUrl': returnUrl,
      'environment': environment,
      'region': region,
      'theme': theme,
      'verboseLogging': verboseLogging,
    });
  }

  static Future<void> signIn({
    required String clientId,
    required String scope,
    required String market,
    String? locale,
  }) async {
    await _methods.invokeMethod('signIn', {
      'clientId': clientId,
      'scope': scope,
      'market': market,
      'locale': locale,
    });
  }

  static Stream<KlarnaEvent> events() {
    _eventStream ??= _events.receiveBroadcastStream().map((e) {
      print('获取到的回调结果 = $e');
      
      return KlarnaEvent.fromMap(e);
    });
    return _eventStream!;
  }
}
