import 'package:get_it/get_it.dart';
import 'package:rick_and_morty_app/app/theme/theme_controller.dart';

final sl = GetIt.instance;

void setUpLocator() {
  sl.registerLazySingleton<ThemeController>(() => ThemeController());
}
