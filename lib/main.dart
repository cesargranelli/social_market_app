import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // O projeto Firebase exige atestação App Check (Identity Toolkit com
  // enforcement): sem um token válido, TODO login retorna 401
  // "Firebase App Check token is invalid".
  // Em debug usamos o provider de debug — o token impresso no console deve
  // ser registrado em Firebase Console > App Check > Apps > Gerenciar tokens
  // de depuração (ver docs/e2e-checklist.md).
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
  );

  runApp(const ProviderScope(child: SocialMarketApp()));
}
