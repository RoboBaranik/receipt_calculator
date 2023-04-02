import 'dart:developer';
import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:receipt_calculator/data/receipt_item.dart';
import 'package:receipt_calculator/pages/receipt_summary_page.dart';
import 'package:receipt_calculator/routes.dart';

class ReceiptScannerPage extends StatefulWidget {
  static const route = '/scanner';
  const ReceiptScannerPage({super.key});

  @override
  State<ReceiptScannerPage> createState() => _ReceiptScannerPageState();
}

class _ReceiptScannerPageState extends State<ReceiptScannerPage> {
  Barcode? result;
  QRViewController? controller;
  String lastCode = '';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text('${result!.code}')
                  else
                    const Text('Scan the QR code on the receipt'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return snapshot.data != null && snapshot.data!
                                  ? const Icon(Icons.flash_on)
                                  : const Icon(Icons.flash_off);
                            },
                          ),
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: OutlinedButton(
                          onPressed: () {
                            result = null;
                            lastCode = '';
                            setState(() {});
                          },
                          child: const Text('Reset',
                              style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: result == null
                              ? null
                              : () {
                                  var receipt =
                                      convert.jsonDecode(getMockResponse())
                                          as Map<String, dynamic>;
                                  Navigator.pushNamed(
                                          context, ReceiptSummaryPage.route,
                                          arguments: Receipt.fromJson(receipt))
                                      .then((value) {
                                    debugPrint('QR return $value');
                                    Navigator.pop(context, value);
                                  });
                                },
                          child: const Text('Confirm',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated:
          _onQRViewCreated, //(controller) => _onQRViewCreated(controller, context),
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      formatsAllowed: const [BarcodeFormat.qrcode],
    );
  }

  void _onQRViewCreated(QRViewController controller /* , BuildContext bc */) {
    debugPrint('QR view created');
    setState(() {
      this.controller = controller;
      debugPrint('QR controller created');
      // controller.resumeCamera();
    });
    debugPrint('QR listener');
    controller.scannedDataStream.listen((scanData) {
      debugPrint('QR Data.... ${DateTime.now()}');
      if (scanData.code == null ||
          scanData.code!.trim().isEmpty ||
          lastCode.compareTo(scanData.code!) == 0) {
        debugPrint('QRcode empty or same, not updating: ${scanData.code}');
        return;
      }
      if (!RegExp(r'^[A-Z]-[A-Z0-9]{32}$').hasMatch(scanData.code!)) {
        debugPrint('QRcode invalid, not updating: ${scanData.code}');
        return;
      }
      debugPrint('QRcode 1: ${scanData.code}');
      setState(() {
        result = scanData;
        lastCode = scanData.code!;
      });

      // debugPrint(convert.jsonEncode({'receiptId': lastCode}));
      // post(Uri.https('ekasa.financnasprava.sk', '/mdu/api/v1/opd/receipt/find'),
      //         body: convert.jsonEncode({'receiptId': lastCode}),
      //         headers: {'Content-Type': 'application/json'})
      //     .then((receiptResponse) {
      // debugPrint('Status code: ${receiptResponse.statusCode}');
      var receipt =
          convert.jsonDecode(getMockResponse()) as Map<String, dynamic>;
      log(receipt.toString());
      // debugPrint(receipt.toString());
      // controller.dispose();
      // setState(() {
      // lastCode = '';
      // });
      // Navigator.pushReplacementNamed(bc, ReceiptSummaryPage.route,
      //     arguments: Receipt.fromJson(receipt));
      // }, onError: (err) => debugPrint(err.toString()));

      // setState(() {
      //   debugPrint('QR code 2: ${scanData.code}');
      //   result = scanData;
      // });
    } /* , onError: (object, stacktrace) {
      debugPrint('ERROR');
      debugPrint(object);
      debugPrint(stacktrace);
    }, onDone: () {
      debugPrint('DONE');
    } */
        );
    debugPrint('QR listener created');
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    debugPrint('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  String getMockResponse() {
    return '{  "returnValue": 0,  "receipt": {    "receiptId": "O-845A79A29D1D4B639A79A29D1D1B63A9",    "ico": "36183181",    "cashRegisterCode": "88820200447960099",    "issueDate": "12.03.2023 20:35:16",    "createDate": "12.03.2023 20:35:16",    "customerId": null,    "dic": "2020044796",    "icDph": "SK2020044796",    "invoiceNumber": null,    "okp": "f1760a46-e53abe3f-a40958f2-98121978-54e02bf1",    "paragon": false,    "paragonNumber": null,    "pkp": "h0x4l/DjFgST0KBgo3kaF3Ka6xqM9dRfLzhUpIX+yM/3Botgyam5dntFj3Vu9UNFcGk/14G1Bypig9WxIfP9MhsS4DpIVQcHdAVUvZLD9B0t/39jdYIoDA8M+psULQUfGod2kg3r2axDc5sGd0+eXoPz9bODXtzQWKTpxVN1Rbi19uhgWM6b2XRerCjjfFG6Ph5LPuWEe+XZ208qdcEyYPVxH+1Ah4uxeH5qWUYq/dZtTD3jmB/4AsfmQo1erbyfGWGzYfr8Rc7WYYA0a43Ekyywz+Rw8e7boJ6F9c2dppNBrhnOhwYkOOxGulTGM4qekE5chXfA7hVnEdRzLC9slw==",    "receiptNumber": 10846,    "type": "PD",    "taxBaseBasic": 1.07,    "taxBaseReduced": 0.8,    "totalPrice": 1.9,    "freeTaxAmount": -0.28,    "vatAmountBasic": 0.22,    "vatAmountReduced": 0.08,    "vatRateBasic": 20,    "vatRateReduced": 10,    "items": [      {        "name": "ROŽOK 50g VAMEX bez É-čiek",        "itemType": "K",        "quantity": 7,        "vatRate": 10,        "price": 0.28      },      {        "name": "MAKOVKA 80g GORON",        "itemType": "K",        "quantity": 3,        "vatRate": 20,        "price": 0.45      },      {        "name": "LUPAČKA 80g GORON",        "itemType": "K",        "quantity": 3,        "vatRate": 20,        "price": 0.45      },      {        "name": "ARAŠIDY SOLENÉ LÚPANÉ PRAŽENÉ 100g FRESH",        "itemType": "K",        "quantity": 1,        "vatRate": 20,        "price": 0.39      },      {        "name": "Výplata -záloh.obal PET",        "itemType": "Z",        "quantity": 1,        "vatRate": 0,        "price": -0.15      },      {        "name": "VRATNÉ OBALY",        "itemType": "Z",        "quantity": 1,        "vatRate": 0,        "price": -0.13      },      {        "name": "CHLIEB GAZDOVSKÝ 900g VAMEX",        "itemType": "K",        "quantity": 1,        "vatRate": 10,        "price": 0.6      }    ],    "organization": {      "buildingNumber": null,      "country": "Slovensko",      "dic": "2020044796",      "icDph": "SK2020044796",      "ico": "36183181",      "municipality": "Košice - mestská časť Sever",      "name": "LABAŠ s.r.o.",      "postalCode": "04001",      "propertyRegistrationNumber": "1",      "streetName": "Textilná",      "vatPayer": true    },    "unit": {      "cashRegisterCode": "88820200447960099",      "buildingNumber": null,      "country": "Slovensko",      "municipality": "Košice",      "postalCode": "04001",      "propertyRegistrationNumber": "29",      "streetName": "Kuzmányho",      "name": null,      "unitType": "STANDARD"    },    "exemption": false  },  "searchIdentification": {    "createDate": 1679220472963,    "bucket": 0,    "internalReceiptId": "O-845A79A29D1D4B639A79A29D1D1B63A9",    "searchUuid": "e969e790-c63d-11ed-975c-b934f1a96192"  }}';
  }
}
