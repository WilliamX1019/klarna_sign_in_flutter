import 'package:flutter_test/flutter_test.dart';
import 'package:klarna_sign_in_flutter/klarna_sign_in_flutter.dart';
import 'package:klarna_sign_in_flutter/klarna_sign_in_flutter_platform_interface.dart';
import 'package:klarna_sign_in_flutter/klarna_sign_in_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockKlarnaSignInFlutterPlatform
    with MockPlatformInterfaceMixin
    implements KlarnaSignInFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final KlarnaSignInFlutterPlatform initialPlatform = KlarnaSignInFlutterPlatform.instance;

  test('$MethodChannelKlarnaSignInFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelKlarnaSignInFlutter>());
  });

  test('getPlatformVersion', () async {
    KlarnaSignInFlutter klarnaSignInFlutterPlugin = KlarnaSignInFlutter();
    MockKlarnaSignInFlutterPlatform fakePlatform = MockKlarnaSignInFlutterPlatform();
    KlarnaSignInFlutterPlatform.instance = fakePlatform;

    expect(await klarnaSignInFlutterPlugin.getPlatformVersion(), '42');
  });
}
