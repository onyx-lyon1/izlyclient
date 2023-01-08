// ignore_for_file: unused_local_variable

import 'package:dart_izlyclient/dart_izlyclient.dart';
import 'dart:typed_data';
import 'dart:io';

void main() async {
  // Create a new IzlyClient instance
  IzlyClient izlyClient = IzlyClient("username", "password");
  //connect to izly
  await izlyClient.login();
  //get the balance
  double balance = await izlyClient.getBalance();
  //get 3 QRCode
  List<Uint8List> qrCodes = await izlyClient.getNQRCode(3);
  //save the QRCode
  for (int i = 0; i < qrCodes.length; i++) {
    await File("qrCode$i.png").writeAsBytes(qrCodes[i]);
  }
  //get the url to recharge with a account transfer
  String url = await izlyClient.getTransferPaymentUrl(10.0);
  //recharge with a credit card
  bool result = await izlyClient.rechargeWithCB(10.0);
  //recharge via someone else
  bool result2 =
      await izlyClient.rechargeViaSomeoneElse(10.0, "email", "message");
}
