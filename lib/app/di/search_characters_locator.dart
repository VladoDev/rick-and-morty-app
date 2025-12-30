import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:rick_and_morty_app/features/search_characters/data/datasources/remote/characters_remote_datasource.dart';
import 'package:rick_and_morty_app/features/search_characters/data/repositories/character_repository_impl.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/usecases/search_characters_usecase.dart';
import 'package:rick_and_morty_app/features/search_characters/presentation/controllers/character_details_controller.dart';

void registerSearchCharacters(GetIt sl) {
  sl.registerLazySingleton(() => CharactersRemoteDatasource(sl<Dio>()));
  sl.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(sl<CharactersRemoteDatasource>()),
  );
  sl.registerLazySingleton<SearchCharactersUsecase>(
    () => SearchCharactersUsecase(sl<CharacterRepository>()),
  );
  sl.registerFactory<CharacterDetailsController>(
    () => CharacterDetailsController(),
  );
}
