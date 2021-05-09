import 'dart:io';

import 'package:forgerock_lib/forgerock_lib.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() async {
  var config = loadYaml(File('config.yaml').readAsStringSync()) as Map;
  var platformConfig = PlatformConfig.fromJson(config);

  test('Get Admin tokens', () async {
    var am = AMRest(platformConfig);
    var cookie = await am.authenticateAsAdmin();
    expect(cookie, isNotNull);
    expect(cookie.length > 15, isTrue);

    var idm = IDMRest(platformConfig, am);

    // get an IDM admin token
    var bearer = await idm.getBearerToken();
    expect(bearer, isNotNull);
  });
}
