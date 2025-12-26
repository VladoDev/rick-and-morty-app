import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/app/app.dart';
import 'package:rick_and_morty_app/app/di/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUpLocator();
  runApp(const App());
}
