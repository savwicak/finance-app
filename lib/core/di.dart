import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository.dart';
import '../presentation/controllers/auth_controller.dart';

// Penyambung sederhana tanpa paket tambahan, cukup untuk tahap tes.
// Nanti bisa diganti Provider, Riverpod, atau GetX.
final authRepository = AuthRepository(AuthRemoteDatasource());
final authController = AuthController(authRepository);
