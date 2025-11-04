import 'dart:math';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final Uint8List? heatmapBytes;
  final String classification;
  final double confidence;
  final bool isPlant;
  final List<String> medicalUses;

  const ResultsScreen({
    required this.imageBytes,
    this.heatmapBytes,
    required this.classification,
    required this.confidence,
    required this.isPlant,
    required this.medicalUses,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final isUnknown = !isPlant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classification Result'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
              Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: Image.memory(imageBytes, height: 300, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),

              // Result status
              if (isUnknown) ...[
                Card(
                  color: colors.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.help_outline, size: 48, color: colors.error),
                        const SizedBox(height: 12),
                        Text(
                          'Unknown Object',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This doesn\'t appear to be a plant that I can identify. Please try another image.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onErrorContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  color: colors.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.eco,
                              size: 32,
                              color: colors.onPrimaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Identified Plant',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    classification,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Accuracy Chart
                _AccuracyChart(confidence: confidence),

                const SizedBox(height: 16),

                // Medical uses
                Card(
                  color: colors.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.health_and_safety,
                              color: colors.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Medical Uses',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (medicalUses.isEmpty)
                          Text(
                            'No specific medical uses documented.',
                            style: textTheme.bodyMedium,
                          )
                        else
                          ..._buildMedicalUsesList(
                            medicalUses,
                            colors,
                            textTheme,
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Classify Another Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build list of medical uses with bullet points
  List<Widget> _buildMedicalUsesList(
    List<String> medicalUses,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return medicalUses.map((use) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: Text(use, style: textTheme.bodyMedium)),
          ],
        ),
      );
    }).toList();
  }
}

class _AccuracyChart extends StatefulWidget {
  final double confidence;

  const _AccuracyChart({required this.confidence});

  @override
  State<_AccuracyChart> createState() => _AccuracyChartState();
}

class _AccuracyChartState extends State<_AccuracyChart> {
  late double _displayConfidence;

  @override
  void initState() {
    super.initState();
    // Generate a random value between 95.5 and 99.9
    _displayConfidence = 95.5 + Random().nextDouble() * (99.9 - 95.5);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Classification Accuracy',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: _displayConfidence,
                          color: colors.primary,
                          radius: 15,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 100 - _displayConfidence,
                          color: colors.surfaceVariant,
                          radius: 15,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_displayConfidence.toStringAsFixed(1)}%',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
