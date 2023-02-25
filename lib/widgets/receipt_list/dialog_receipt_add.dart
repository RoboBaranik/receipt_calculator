import 'package:flutter/material.dart';
import 'package:receipt_calculator/routes.dart';

class DialogReceiptAdd extends StatelessWidget {
  const DialogReceiptAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              width: double.infinity,
              child: const Text(
                'Add new receipt',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            ElevatedButton.icon(
                onPressed: () => {},
                icon: const Icon(Icons.qr_code),
                label: const Text('Scan QR code')),
            OutlinedButton.icon(
                onPressed: () => Navigator.popAndPushNamed(
                    context, Routes.receiptCreateManual),
                icon: const Icon(Icons.create),
                label: const Text('Fill manually')),
          ],
        ),
      ),
    );
  }
}