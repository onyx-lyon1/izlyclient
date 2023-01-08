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

  test("get balance", () async {
    await izlyClient.login();
    expect(izlyClient.isLogged, true);
    var balance = await izlyClient.getBalance();
    expect(balance, isNotNull);
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

  test("rechager with transfer", () async {
    await izlyClient.login();
    expect(izlyClient.isLogged, true);
    String rechargement = await izlyClient.getTransferPaymentUrl(10.0);
    expect(rechargement, isNotNull);
    await izlyClient.logout();
    expect(izlyClient.isLogged, false);
  });

  test("rechager with credit card", () async {
    await izlyClient.login();
    expect(izlyClient.isLogged, true);
    bool rechargement = await izlyClient.rechargeWithCB(10.0);
    expect(rechargement, true);
    await izlyClient.logout();
    expect(izlyClient.isLogged, false);
  });

  test("recharge via someone else", () async {
    await izlyClient.login();
    expect(izlyClient.isLogged, true);
    bool rechargement = await izlyClient.rechargeViaSomeoneElse(
        10.0, env['IZLY_USERNAME'] ?? "", "un petit message");
    expect(rechargement, true);
    await izlyClient.logout();
    expect(izlyClient.isLogged, false);
  });
}
