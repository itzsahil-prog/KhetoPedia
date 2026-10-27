import 'package:flutter/material.dart';

import '../../../core/localization/localization.dart';
import '../../../shared/widgets/widgets.dart';

/// Screen for submitting soil test results.
class SoilTestFormScreen extends StatefulWidget {
  const SoilTestFormScreen({super.key});

  @override
  State<SoilTestFormScreen> createState() => _SoilTestFormScreenState();
}

class _SoilTestFormScreenState extends State<SoilTestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phController = TextEditingController();
  final _moistureController = TextEditingController();
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();

  @override
  void dispose() {
    _phController.dispose();
    _moistureController.dispose();
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.soilNewTest),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              controller: _phController,
              label: l.soilPH,
              prefixIcon: Icons.science_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hint: '0.0 - 14.0',
              semanticLabel: l.soilPH,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _moistureController,
              label: l.soilMoisture,
              prefixIcon: Icons.water_drop_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hint: '0 - 100%',
              semanticLabel: l.soilMoisture,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nitrogenController,
              label: l.soilNitrogen,
              prefixIcon: Icons.opacity,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              semanticLabel: l.soilNitrogen,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phosphorusController,
              label: l.soilPhosphorus,
              prefixIcon: Icons.opacity,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              semanticLabel: l.soilPhosphorus,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _potassiumController,
              label: l.soilPotassium,
              prefixIcon: Icons.opacity,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              semanticLabel: l.soilPotassium,
            ),
            const SizedBox(height: 32),
            AppButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Soil test submitted successfully')),
                  );
                  Navigator.pop(context);
                }
              },
              label: l.save,
              icon: Icons.check,
            ),
          ],
        ),
      ),
    );
  }
}
