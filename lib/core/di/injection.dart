import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/todo/data/datasources/local_data_source.dart';
import '../../features/todo/data/datasources/remote_data_source.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/presentation/bloc/todo_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<GoogleSignIn>(GoogleSignIn());

  getIt.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(firestore: getIt()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth: getIt(), googleSignIn: getIt()),
  );
  getIt.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      localDataSource: getIt(),
      remoteDataSource: getIt(),
      authRepository: getIt(),
    ),
  );

  getIt.registerFactory(
    () => AuthBloc(authRepository: getIt(), todoRepository: getIt()),
  );
  getIt.registerFactory(
    () => TodoBloc(todoRepository: getIt(), authRepository: getIt()),
  );
}
