import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:rick_and_morty_app/app/di/search_characters_locator.dart';
import 'package:rick_and_morty_app/app/theme/theme_controller.dart';
import 'package:rick_and_morty_app/core/network/dio_provider.dart';

final sl = GetIt.instance;

void setUpLocator() {
  sl.registerLazySingleton<ThemeController>(() => ThemeController());

  sl.registerLazySingleton<Dio>(() => createDio());

  registerSearchCharacters(sl);
}
