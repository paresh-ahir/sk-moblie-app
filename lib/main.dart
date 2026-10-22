import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/theme/app_theme.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SalesKidoApp());
}

class SalesKidoApp extends StatefulWidget {
  const SalesKidoApp({super.key});

  @override
  State<SalesKidoApp> createState() => _SalesKidoAppState();
}

class _SalesKidoAppState extends State<SalesKidoApp> {
  late final AuthProvider _auth = AuthProvider();
  late final GoRouter _router = createRouter(_auth);

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
      ],
      child: MaterialApp.router(
        title: 'SalesKido',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
