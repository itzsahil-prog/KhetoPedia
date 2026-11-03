import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/localization/localization.dart';
import '../../shared/widgets/widgets.dart';
import 'crop_scanner/application/crop_scanner_provider.dart';
import 'crop_scanner/domain/crop_scan.dart';
import 'crop_scanner/presentation/scan_result_screen.dart';
import 'crop_scanner/presentation/scan_history_screen.dart';

/// Crop scanner feature screen.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _imagePicker = ImagePicker();
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    // Request permission
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;
    
    final status = await permission.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).scanPermissionDenied)),
        );
      }
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isAnalyzing = true);

      final bytes = await pickedFile.readAsBytes();
      final filename = pickedFile.name;

      final result = await ref.read(cropScannerProvider.notifier).analyzeCrop(
        imageBytes: bytes,
        filename: filename,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultScreen(scan: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).scanError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (_isAnalyzing) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l.scanAnalyzing,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.scanTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l.scanHistory,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.center_focus_strong_outlined,
                size: 120,
                color: Theme.of(context).colorScheme.primary.withAlpha(128),
              ),
              const SizedBox(height: 32),
              Text(
                l.scanTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                l.scanInstructions,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              AppButton(
                onPressed: () => _pickImage(ImageSource.camera),
                label: l.scanTakePhoto,
                icon: Icons.camera_alt,
              ),
              const SizedBox(height: 16),
              AppButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                label: l.scanUploadPhoto,
                icon: Icons.photo_library,
                variant: AppButtonVariant.outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

