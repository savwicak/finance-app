import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/controllers/auth_controller.dart';

// Penyambung sederhana tanpa paket tambahan, cukup untuk tahap tes.
// Nanti bisa diganti Provider, Riverpod, atau GetX.
final authRepository = AuthRepository(AuthRemoteDatasource());
final authController = AuthController(authRepository);
