import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/api/api_client.dart';
import 'core/services/offline_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize offline sync service
  await offlineSyncService.init();

  // Initialize secure storage
  const storage = FlutterSecureStorage();

  // Initialize API client
  final apiClient = ApiClient(storage);

  runApp(
    BlocProvider(
      create: (context) => AuthBloc(apiClient: apiClient, storage: storage),
      child: const AILifeManagerApp(),
    ),
  );
}
