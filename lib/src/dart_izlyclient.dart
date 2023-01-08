import 'dart:convert';
import 'dart:typed_data';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'package:requests/requests.dart';

class IzlyClient {
  static const String _baseUrl = 'https://mon-espace.izly.fr';

  final String _username;
  final String _password;
  bool _isLogged = false;

  IzlyClient(this._username, this._password);

  bool get isLogged => _isLogged;

  Future<void> login() async {
    var r = await Requests.get("$_baseUrl/Home/Logon");
    List<String> content = r
        .content()
        .split("\n")
        .firstWhere((element) => element.contains("__RequestVerificationToken"))
        .split('"');
    int index = content.indexOf(" value=");
    // ignore: no_leading_underscores_for_local_identifiers, non_constant_identifier_names
    String __RequestVerificationToken = content[index + 1];
    r = await Requests.post(
      '$_baseUrl/Home/Logon',
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
    var r = await Requests.get("$_baseUrl/Home/Logout");
    if (r.statusCode != 200) {
      throw Exception("Logout failed");
    }
    _isLogged = false;
  }

  Future<double> getBalance() async {
    assert(_isLogged);
    var r = await Requests.get("$_baseUrl/");
    if (r.statusCode != 200) {
      throw Exception("GetBalance failed");
    }
    if (r.content().isEmpty) {
      throw Exception("GetBalance failed");
    }
    Document document = parse(r.content());
    //select the value in the p with id balance
    String balance =
        document.getElementById("balance")!.innerHtml.split("<sup>").first;
    return double.parse(balance.replaceAll(",", "."));
  }

  Future<List<Uint8List>> getNQRCode(int n) async {
    assert(_isLogged);
    assert(n < 4);
    var r = await Requests.post("$_baseUrl/Home/CreateQrCodeImg", body: {
      'nbrOfQrCode': n.toString(),
    });
    List<Uint8List> result = [];
    for (var i in jsonDecode(r.body)) {
      result.add(base64Decode(i['Src'].split("base64,").last));
    }
    return result;
  }

  Future<String> getTransferPaymentUrl(double amount) async {
    assert(_isLogged);
    var r = await Requests.post(
        "$_baseUrl/Home/PaymentInitiationRequest?amount=${amount.toStringAsFixed(2)}");
    if (r.statusCode != 200) {
      throw Exception("Payment failed");
    }
    return jsonDecode(r.content())["url"];
  }

  Future<bool> rechargeWithCB(double amount) async {
    //TODO: implement secure payment redirection following
    assert(amount >= 10.0);
    var r = await Requests.get("$_baseUrl/Home/Recharge");
    if (r.statusCode != 200) {
      throw Exception("Recharge failed");
    }
    Document document = parse(r.content());
    final String cbName = document
        .getElementsByClassName("customSelect wLarg form-control")
        .first
        .children
        .first
        .innerHtml;
    final String cbId = document
        .getElementsByClassName("customSelect wLarg form-control")
        .first
        .children
        .first
        .attributes['value']!;
    r = await Requests.post("$_baseUrl/Home/RechargeConfirm", body: {
      'dataToSend':
          '{"Amount":"${amount.toStringAsFixed(2)}","Code":"$_password","Senders":[{"ID":"$cbId","Name":"$cbName","Amount":"${amount.toStringAsFixed(2)}"}]}',
      'operation': '',
      'engagementId': '',
    });
    if (r.statusCode != 200) {
      throw Exception("Recharge failed");
    }

    return true;
  }

  Future<bool> rechargeViaSomeoneElse(
      double amount, String email, String message) async {
    assert(_isLogged);
    assert(amount >= 10.0);
    var r = await Requests.post("$_baseUrl/PayInRequest/PayInRequestConfirm",
        body: {
          "Email": email,
          "AmountPad.AmountSelectedValue": "",
          "Message": message,
          "PadAmount": "0",
          "Amount": amount.toStringAsFixed(2),
        });
    if (r.statusCode != 200) {
      throw Exception("Recharge failed");
    }
    return true;
  }
}
