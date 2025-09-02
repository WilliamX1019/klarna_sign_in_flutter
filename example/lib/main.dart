import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klarna_sign_in_flutter/klarna_sign_in_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _token;
  String? _error;

  @override
  void initState() {
    super.initState();
    KlarnaSignInPlatform.events().listen((e) {
      final action = e.action;
      final params = e.params;

      if (action == 'KlarnaSignInToken' && Platform.isAndroid) {
        if (params != null && params['KlarnaSignInToken'] != null) {
          final tokenData = params['KlarnaSignInToken'];
          final idToken = tokenData['idToken'];
          final accessToken = tokenData['accessToken'];
          print("✅ idToken: $idToken, accessToken: $accessToken");
        } else {
          print("⚠️ klarnaToken event received but tokenData is null");
        }
      }
      if (action == 'klarnaToken' && Platform.isIOS) {
        if (params != null && params['klarnaToken'] != null) {
          final tokenData = params['klarnaToken'];
          final idToken = tokenData['idToken'];
          final accessToken = tokenData['accessToken'];
          print("✅ idToken: $idToken, accessToken: $accessToken");
        } else {
          print("⚠️ klarnaToken event received but tokenData is null");
        }
      }
      
       else if (action == 'ERROR') {
        final message = params?['message'] ?? "Unknown error";
        print("❌ Klarna error: $message");
      } else {
        print("ℹ️ Other event: $action, params: $params");
      }
    });
  }

  Future<void> _init() async {
    //<data android:scheme="com.unice.lqhair" android:host="klarnaLogin"/>
    await KlarnaSignInPlatform.initialize(
      returnUrl: 'com.unice.longqihair://klarnaLogin',
      environment: 'playground',
      region: 'EU',
      theme: 'auto',
      verboseLogging: true,
    );
  }

  Future<void> _signIn() async {
    await KlarnaSignInPlatform.signIn(
      clientId:
          'klarna_test_client_dk4tcW85NzAlcHhER3MxVXhnNGxaQkR0WVMtdzFIdEwsMjI2ZDJhZGEtMzU3ZC00OWE0LWI2NGItODJmN2FmMDEyMGNlLDEsYmdrYUVpYWgrU014a2pBMlVsaFdvWTEzZExHRTRCSXA0THVDVVY5YlM5QT0',
      scope: 'openid offline_access profile:email',
      market: 'NA',
      locale: 'en-NA',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in with Klarna Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(onPressed: _init, child: const Text('Initialize')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Sign in with Klarna"),
            ),
            const SizedBox(height: 24),
            if (_token != null) Text('Token: $_token'),
            if (_error != null) Text('Error: $_error'),
          ],
        ),
      ),
    );
  }
}
