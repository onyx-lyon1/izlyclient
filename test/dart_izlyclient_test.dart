import 'package:dart_izlyclient/dart_izlyclient.dart';
import 'package:test/test.dart';
import 'package:dotenv/dotenv.dart';

void main() {
  late IzlyClient izlyClient;
  DotEnv env = DotEnv(includePlatformEnvironment: true);

  setUp(() {
    env.load();
    izlyClient =
        IzlyClient(env['IZLY_USERNAME'] ?? "", env['IZLY_PASSWORD'] ?? "");
  });

  test('Login-lougout test', () async {
    await izlyClient.login();
    expect(izlyClient.isLogged, true);
    await izlyClient.logout();
    expect(izlyClient.isLogged, false);
  });

  test('Get QRCode test', () async {
    await izlyClient.login();
    expect(izlyClient.isLogged, true);
    var qrCode = await izlyClient.getNQRCode(3);
    expect(qrCode, isNotNull);
    await izlyClient.logout();
    expect(izlyClient.isLogged, false);
  });
}
