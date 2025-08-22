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
      switch (e.action) {
        case 'TOKEN':
          setState(() { _token = e.params?['klarnaToken'] as String?; });
          break;
        case 'USER_CANCELLED':
          setState(() { _error = 'User cancelled'; });
          break;
        case 'ERROR':
          setState(() { _error = e.params?['message'] as String? ?? 'Unknown error'; });
          break;
        default:
          debugPrint('Event: ${e.action}, params: ${e.params}');
      }
    });
  }

  Future<void> _init() async {
    //<data android:scheme="com.unice.lqhair" android:host="klarnaLogin"/>
    await KlarnaSignInPlatform.initialize(
      returnUrl: 'com.unice.lqhair://klarnaLogin',
      environment: 'playground',
      region: 'EU',
      theme: 'auto',
      verboseLogging: true,
    );
  }

  Future<void> _signIn() async {
    await KlarnaSignInPlatform.signIn(
      clientId: 'YOUR_CLIENT_ID',
      scope: 'openid offline_access profile:email',
      market: 'SE',
      locale: 'en-SE',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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