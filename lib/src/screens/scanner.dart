import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/db.dart';
import '../data/off_api.dart';
import '../models/entries.dart';
import '../theme.dart';
import 'food_detail.dart';

/// Scan a product barcode and look it up locally, then on Open Food Facts.
class BarcodeScannerScreen extends StatefulWidget {
  final Meal meal;

  const BarcodeScannerScreen({super.key, required this.meal});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  /// Camera scanning is only available on mobile (and macOS/web).
  static final bool _cameraSupported =
      kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  final MobileScannerController? _controller = _cameraSupported
      ? MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates)
      : null;
  final _db = AppDatabase.instance;
  final _off = OpenFoodFactsApi();

  bool _busy = false;
  String? _status;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final barcode = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    setState(() {
      _busy = true;
      _status = 'Looking up $barcode ...';
    });

    try {
      var food = await _db.foodByBarcode(barcode);
      if (food == null) {
        final offFood = await _off.byBarcode(barcode);
        if (offFood != null) {
          food = await _db.insertFood(offFood);
        }
      }
      if (!mounted) return;
      if (food == null) {
        setState(() {
          _busy = false;
          _status = 'Product $barcode not found. Try again or add it manually.';
        });
        return;
      }
      final added = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => FoodDetailScreen(food: food!, meal: widget.meal),
        ),
      );
      if (!mounted) return;
      if (added == true) {
        Navigator.pop(context);
      } else {
        setState(() {
          _busy = false;
          _status = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = 'Lookup failed. Check your internet connection.';
        });
      }
    }
  }

  Future<void> _enterManually() async {
    final controller = TextEditingController();
    final barcode = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter barcode'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Barcode number'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Look up'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (barcode != null && barcode.isNotEmpty) {
      await _onDetect(BarcodeCapture(
          barcodes: [Barcode(rawValue: barcode)]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          if (_cameraSupported)
            IconButton(
              tooltip: 'Toggle torch',
              icon: const Icon(Icons.flashlight_on_outlined),
              onPressed: () => _controller?.toggleTorch(),
            ),
          IconButton(
            tooltip: 'Enter barcode manually',
            icon: const Icon(Icons.keyboard),
            onPressed: _enterManually,
          ),
        ],
      ),
      body: _cameraSupported ? _cameraView() : _manualOnlyView(),
    );
  }

  /// Fallback for desktop platforms without camera scanning support.
  Widget _manualOnlyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Camera scanning is not available on this platform.\n'
              'Type the barcode number instead - the product will be\n'
              'looked up on Open Food Facts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.keyboard),
              label: const Text('Enter Barcode'),
              onPressed: _enterManually,
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
            if (_status != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(_status!, textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cameraView() {
    return Stack(
        children: [
          MobileScanner(controller: _controller!, onDetect: _onDetect),
          // Scan frame overlay.
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (_busy)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (_status != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(_status!, textAlign: TextAlign.center),
                ),
              ),
            ),
        ],
    );
  }
}
