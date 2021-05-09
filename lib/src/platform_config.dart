
/// Holds the platform configuration for a target system
class PlatformConfig {
  String _fqdn;
  String _amadminPassword;
  PlatformConfig(this._fqdn,this._amadminPassword);

  String get amadminPassword => _amadminPassword;

  PlatformConfig.fromJson(Map json) {
    _fqdn = json['fqdn'];
    _amadminPassword = json['amadminPassword'];
  }

  String get idmUrl => 'https://$_fqdn/openidm';
  String get amUrl => 'https://$_fqdn/am';
  String get platformUrl => 'https://$_fqdn/platform';

  // These are fixed right now, but we could make them configurable in
  // the future;

  // The OAuth2 client to authenticate as
  final String idmAdminOAuth2ClientId  = 'idm-admin-ui';

  String get idmClientRedirectUrl => 'https://$_fqdn/admin/appAuthHelperRedirect.html';
  // THe scopes needed to use the /openidm admin REST endpoint
  final List<String> idmScopes = ['openid','fr:idm:*'];
}