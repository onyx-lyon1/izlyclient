import 'dart:convert';
import 'dart:typed_data';

import 'package:requests/requests.dart';

class IzlyClient {
  static const String _baseUrl = 'https://mon-espace.izly.fr/Home';

  final String _username;
  final String _password;
  bool _isLogged = false;

  IzlyClient(this._username, this._password);

  bool get isLogged => _isLogged;

  Future<void> login() async {
    var r = await Requests.get("$_baseUrl/Logon");
    List<String> content = r
        .content()
        .split("\n")
        .firstWhere((element) => element.contains("__RequestVerificationToken"))
        .split('"');
    int index = content.indexOf(" value=");
    String __RequestVerificationToken = content[index + 1];
    r = await Requests.post(
      '$_baseUrl/Logon',
      body: {
        'Username': _username,
        'Password': _password,
        'ReturnUrl': '/',
        "__RequestVerificationToken": __RequestVerificationToken,
      },
    );
    if (r.statusCode != 302) {
      throw Exception("Login failed");
    }
    _isLogged = true;
  }

  Future<void> logout() async {
    var r = await Requests.get("$_baseUrl/Logout");
    if (r.statusCode != 200) {
      throw Exception("Logout failed");
    }
    _isLogged = false;
  }

  Future<List<Uint8List>> getNQRCode(int n) async {
    assert(_isLogged);
    assert(n < 4);
    var r = await Requests.post("$_baseUrl/CreateQrCodeImg", body: {
      'nbrOfQrCode': n.toString(),
    });
    List<Uint8List> result = [];
    for (var i in jsonDecode(r.body)) {
      result.add(base64Decode(i['Src'].split("base64,").last));
    }
    return result;
  }
}
