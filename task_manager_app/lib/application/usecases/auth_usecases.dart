import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;
  LoginUseCase(this.repository);
  Future<User> execute(String email, String password) =>
      repository.login(email, password);
}

class RegisterUseCase {
  final IAuthRepository repository;
  RegisterUseCase(this.repository);
  Future<User> execute(String nombre, String email, String password) =>
      repository.register(nombre, email, password);
}

class LogoutUseCase {
  final IAuthRepository repository;
  LogoutUseCase(this.repository);
  Future<void> execute() => repository.logout();
}

class CheckAuthUseCase {
  final IAuthRepository repository;
  CheckAuthUseCase(this.repository);
  Future<User?> execute() => repository.getCurrentUser();
}

class GetTokenUseCase {
  final IAuthRepository repository;
  GetTokenUseCase(this.repository);
  Future<String?> execute() => repository.getToken();
}
