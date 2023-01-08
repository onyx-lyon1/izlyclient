# a izly client written in dart
This package allows you to login and fetch payments qrcodes from izly (https://izly.fr/).

## Example
```dart
  // Create a new IzlyClient instance
  IzlyClient izlyClient = IzlyClient("username", "password");
  //connect to izly
  await izlyClient.login();
  //get 3 QRCode
  List<Uint8List> qrCodes = await izlyClient.getNQRCode(3);
  //save the QRCode
  for (int i = 0; i < qrCodes.length; i++) {
    await File("qrCode$i.png").writeAsBytes(qrCodes[i]);
  }
```
