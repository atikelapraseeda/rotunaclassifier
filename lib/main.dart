import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rotulaclassifier/services/gemini_classifier.dart';
import 'package:rotulaclassifier/config/api_keys.dart';
import 'package:rotulaclassifier/screens/results_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotula Classifier',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GeminiClassifier _classifier;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeClassifier();
  }

  Future<void> _initializeClassifier() async {
    try {
      _classifier = GeminiClassifier();
      await _classifier.initialize(GEMINI_API_KEY);
      setState(() => _isInitializing = false);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Failed to initialize Gemini: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isInitializing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Initializing classifier...')),
      );
      return;
    }

    try {
      // 🔐 Permissions
      PermissionStatus status;

      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        // Gallery case
        if (Platform.isAndroid) {
          status = await Permission.photos.request();
        } else {
          // ✅ iOS
          status = await Permission.photos.request();
        }
      }

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission denied. Please enable ${source == ImageSource.camera ? 'camera' : 'photo'} access.',
            ),
          ),
        );
        return;
      }

      // 🖼️ Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() => _isLoading = true);
      final imageBytes = await pickedFile.readAsBytes();

      // 🔍 Classify image
      final result = await _classifier.classifyImage(imageBytes);

      // 🔥 Generate heatmap
      final heatmap = await _classifier.generateHeatmapOverlay(
        imageBytes,
        result.plantName ?? 'Plant',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              imageBytes: imageBytes,
              heatmapBytes: heatmap,
              classification: result.plantName ?? 'Unknown',
              confidence: result.confidence,
              isPlant: result.isPlant,
              medicalUses: result.medicalUses,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotula Classifier'),
        centerTitle: true,
        backgroundColor: Colors.black26,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(colors: colors, textTheme: textTheme),
              const SizedBox(height: 24),
              _ActionButtons(
                colors: colors,
                textTheme: textTheme,
                isLoading: _isLoading,
                isInitializing: _isInitializing,
                onPickImage: () => _pickImage(ImageSource.gallery),
                onTakePhoto: () => _pickImage(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ColorScheme colors;
  final TextTheme textTheme;

  const _Header({required this.colors, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Rotula Classifier',
          style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Identify medicinal plants using VIT Model and visualize explainability heatmaps.',
          style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ColorScheme colors;
  final TextTheme textTheme;
  final bool isLoading;
  final bool isInitializing;
  final VoidCallback onPickImage;
  final VoidCallback onTakePhoto;

  const _ActionButtons({
    required this.colors,
    required this.textTheme,
    required this.isLoading,
    required this.isInitializing,
    required this.onPickImage,
    required this.onTakePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isLoading && !isInitializing;

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: isEnabled ? onPickImage : null,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.photo_library_outlined),
          label: Text(
            isInitializing
                ? 'Initializing...'
                : isLoading
                ? 'Classifying...'
                : 'Pick from Gallery',
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 100),
            textStyle: textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isEnabled ? onTakePhoto : null,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.deepOrange,
                  ),
                )
              : const Icon(Icons.photo_camera_outlined),
          label: Text(
            isInitializing
                ? 'Initializing...'
                : isLoading
                ? 'Capturing...'
                : 'Take a Photo',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 100),
            textStyle: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
