import '../networking/dio_factory.dart';
import 'auth_gateway.dart';

/// Gives the API client the Supabase session's access token.
class GatewayTokens implements AccessTokenSource {
  GatewayTokens(this._gateway);

  final AuthGateway _gateway;

  @override
  String? get current => _gateway.accessToken;

  @override
  Future<String?> refresh() => _gateway.refreshSession();
}
