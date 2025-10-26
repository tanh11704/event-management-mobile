abstract class AuthRepository {
  Future<void> login({required String email, required String password});
}
