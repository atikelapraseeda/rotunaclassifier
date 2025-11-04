import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini-powered medicinal plant classifier
class GeminiClassifier {
  late GenerativeModel _model;
  bool _isInitialized = false;

  /// Initialize Gemini model with API key
  Future<void> initialize(String apiKey) async {
    try {
      _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
      _isInitialized = true;
      print('✅ Gemini classifier initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Gemini classifier: $e');
      rethrow;
    }
  }

  /// Classify an image and get medicinal plant information
  Future<ClassificationResult> classifyImage(Uint8List imageBytes) async {
    if (!_isInitialized) {
      throw Exception(
        'Classifier not initialized. Call initialize(apiKey) first.',
      );
    }

    try {
      final prompt = '''
You are a plant identification AI expert specializing in medicinal herbs,
including rare species like Rotula aquatica, Ocimum tenuiflorum (Tulsi),
and other Ayurvedic plants.

Analyze the image carefully.

INSTRUCTIONS:
1. If the image clearly does NOT contain a plant (e.g., it's an animal, person, or object),
   respond ONLY with: "UNKNOWN_OBJECT"
2. If it IS a plant, respond ONLY with a valid JSON object in this exact format:
{
  "isPlant": true,
  "plantName": "Common name of the plant",
  "scientificName": "Scientific name (if known)",
  "confidence": 0.0 to 1.0,
  "medicalUses": ["use1", "use2", "use3"]
}
3. If unsure but it looks like a plant, still provide your best possible guess.

DO NOT include markdown, explanations, or any text outside of the JSON or "UNKNOWN_OBJECT".
Examples:
- UNKNOWN_OBJECT
- {"isPlant": true, "plantName": "Rotula aquatica", "scientificName": "Rotula aquatica Lour.", "confidence": 0.88, "medicalUses": ["kidney stone treatment", "anti-inflammatory", "diuretic"]}
''';

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ]);

      final text = response.text?.trim() ?? '';

      if (text.isEmpty) throw Exception('Empty response from Gemini');

      // Case 1: Unknown object
      if (text == 'UNKNOWN_OBJECT') {
        return ClassificationResult(
          label: 'unknown',
          confidence: 0.95,
          isPlant: false,
          medicalUses: [],
        );
      }

      // Case 2: JSON response
      return _parseJsonResponse(text);
    } catch (e) {
      print('❌ Error during classification: $e');
      rethrow;
    }
  }

  /// Parse JSON response (handles minor markdown formatting)
  ClassificationResult _parseJsonResponse(String jsonString) {
    try {
      String cleanJson = jsonString;

      if (jsonString.contains('```json')) {
        cleanJson = jsonString.split('```json')[1].split('```')[0].trim();
      } else if (jsonString.contains('```')) {
        cleanJson = jsonString.split('```')[1].split('```')[0].trim();
      }

      final Map<String, dynamic> jsonMap = json.decode(cleanJson);

      final bool isPlant = jsonMap['isPlant'] as bool? ?? true;
      final String plantName =
          jsonMap['plantName'] as String? ?? 'Unknown Plant';
      final double confidence =
          (jsonMap['confidence'] as num?)?.toDouble() ?? 0.85;
      final List<String> uses =
          (jsonMap['medicalUses'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      return ClassificationResult(
        label: plantName.toLowerCase().replaceAll(' ', '_'),
        confidence: confidence,
        isPlant: isPlant,
        plantName: plantName,
        medicalUses: uses,
      );
    } catch (e) {
      print('❌ JSON parsing error: $e');
      print('Raw response: $jsonString');
      throw Exception('Failed to parse Gemini response');
    }
  }

  /// Generate heatmap overlay highlighting important regions
  Future<Uint8List?> generateHeatmapOverlay(
    Uint8List imageBytes,
    String plantName,
  ) async {
    if (!_isInitialized) throw Exception('Classifier not initialized');

    try {
      final explainPrompt =
          '''
You are an explainability AI.
Highlight the regions in this plant image that were most relevant
for identifying it as "$plantName".
Return only the modified image with a semi-transparent red/orange overlay.
No text, labels, or borders — just the image.
''';

      final response = await _model.generateContent([
        Content.multi([
          TextPart(explainPrompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      // Extract binary image data from response
      final imagePart = response.candidates.firstOrNull?.content.parts
          .whereType<DataPart>()
          .firstOrNull;

      if (imagePart != null) {
        return imagePart.bytes;
      }

      print('⚠️ No image data found in heatmap response');
      return null;
    } catch (e) {
      print('❌ Heatmap generation failed: $e');
      return null;
    }
  }
}

/// Model output data class
class ClassificationResult {
  final String label;
  final double confidence;
  final bool isPlant;
  final String? plantName;
  final List<String> medicalUses;

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.isPlant,
    this.plantName,
    required this.medicalUses,
  });

  @override
  String toString() =>
      'ClassificationResult(label: $label, isPlant: $isPlant, plantName: $plantName, uses: $medicalUses, confidence: $confidence)';
}
