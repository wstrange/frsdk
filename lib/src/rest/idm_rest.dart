import 'package:dio/dio.dart';
import 'package:forgerock_lib/forgerock_lib.dart';
import 'rest_client.dart';
import 'am_rest.dart';

// A Client that makes IDM REST calls
// See https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#appendix-rest
class IDMRest extends RESTClient {
  final AMRest _amRest;
  String _accessToken;

  IDMRest(PlatformConfig c, this._amRest) : super(c) ;

  // Get a bearer token for accessing the /openidm admin ui
  // We need to authenticate as amadmin to AM first
  Future<String> getBearerToken() async {
    _accessToken = await _amRest.authCodeFlow(
        redirectUrl: config.idmClientRedirectUrl,
        client_id: config.idmAdminOAuth2ClientId,
        scopes: config.idmScopes);

    // set the dio base options for the bearer token
    // this wil add the bearer token to all future requests.
    dio.options.headers['Authorization'] = 'Bearer $_accessToken';
    return _accessToken;
  }

  // Discussion with Jake: Any oauth2 client can be used. Doesnt matter
  // What matters is the Subject (sub:) in the token. Must be mapped to an admin
  // user (in IDM - authentication.json / access.json)
  //
  // Get an access token for the idm API. As a side effect of this call
  // we add the access token to future REST requests.
  // NOT USED RIGHT NOW. We use amadmin to get a token
//  Future<String> _getAccessToken() async {
//    _accessToken =
//        await _amRest.getOAuth2Token(_adminClientId, _adminClientPassword);
//    dio.options.headers = {'Authorization': 'Bearer $_accessToken'};
//    return _accessToken;
//  }

  // Create a user - return the id
  Future<String> createUser(String id) async {
    var r = await dio.post('${config.idmUrl}/managed/user?_action=create',
        data: _userTemplate(id));
    if (r.statusCode == 201) {
      return r.data['_id'];
    } else {
      throw Exception('Cant create user ${r.statusCode} ${r.statusMessage}');
    }
  }

  Options ifMatch = Options(headers: {'if-match': '*'});

  Future<String> deleteUser(String id) async {
    var r =
        await dio.delete('${config.idmUrl}/managed/user/$id', options: ifMatch);
    return r.statusMessage;
  }

  // Look up the user and return the _id
  Future<String> queryUser(String userName) async {
    var q = {'userName': userName, '_queryFilter': 'userName eq "$userName"'};
    var r = await dio.get('${config.idmUrl}/managed/user', queryParameters: q);
    var payload = r.data;
    // extract the uuid
    if( payload == null || payload['resultCount'] == 0 ) {
      return null;
    }
    return payload['result'].first['_id'];
  }

  Future<String> modifyUser(String id) async {
    var p = [
      {'operation': 'replace', 'field': '/sn', 'value': 'Updated-SN'}
    ];
    var r = await dio.patch('${config.idmUrl}/managed/user/$id',
        options: ifMatch, data: p);
    return r.statusMessage;
  }

  Map<String, String> _userTemplate(String id) => {
        'userName': '$id',
        'givenName': '$id',
        'sn': '$id',
        'mail': '$id@test.com',
        'password': 'TestPassword123^(',
      };
}
