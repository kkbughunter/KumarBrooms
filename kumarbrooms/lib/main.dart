import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/api/api_client.dart';
import 'features/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = await ApiClient.create();
  final authService = AuthService(apiClient);
  await authService.restoreSession();
  runApp(KumarBroomsApp(authService: authService));
}
