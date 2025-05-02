// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'firebase_options.dart';
import 'social_market_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await availableCameras();
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }
  runApp(MultiProvider(providers: providersRemote, child: SocialMarketApp()));
}

void _logError(String code, String? message) {
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}
