import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const List<String> khmerConsonants = [
  'ក', 'ខ', 'គ', 'ឃ', 'ង',
  'ច', 'ឆ', 'ជ', 'ឈ', 'ញ',
  'ដ', 'ឋ', 'ឌ', 'ឍ', 'ណ',
  'ត', 'ថ', 'ទ', 'ធ', 'ន',
  'ប', 'ផ', 'ព', 'ភ', 'ម',
  'យ', 'រ', 'ល', 'វ', 'ស',
  'ហ', 'ឡ', 'អ'
];

const List<String> khmerNumbers = [
  '០', '១', '២', '៣', '៤', '៥', '៦', '៧', '៨', '៩'
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kltcoublznjaiwtbkrnl.supabase.co',
    publishableKey: 'sb_publishable_oWEpL_ZN-mLnIeErrc4KxQ_-ksN4_1A',
  );

  runApp(const KhmerHandwritingApp());
}

class KhmerHandwritingApp extends StatelessWidget {
  const KhmerHandwritingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khmer Handwriting Collector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const RegistrationScreen(),
    );
  }
}

// ============================================================================
// 1. REGISTRATION SCREEN
// ============================================================================
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;

  static const List<String> _genderOptions = ['Male', 'Female'];

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  /// Generates a random 6-digit Session ID (e.g., '948210') using `dart:math`.
  String _generateShortSessionId() {
    final Random random = Random();
    final int sixDigitNumber = 100000 + random.nextInt(900000);
    return sixDigitNumber.toString();
  }

  void _startDrawing() {
    if (_formKey.currentState?.validate() ?? false) {
      final int age = int.parse(_ageController.text.trim());
      final String gender = _selectedGender!;
      final String sessionId = _generateShortSessionId();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HandwritingCollectorScreen(
            age: age,
            gender: gender,
            sessionId: sessionId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Khmer Handwriting Data Collector'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.draw_outlined,
                    size: 56,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Participant Info',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enter your age and gender before starting the handwriting session.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  // Age Input (1 to 100)
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Age (1 - 100)',
                      hintText: 'e.g. 19',
                      prefixIcon: const Icon(Icons.cake_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your age';
                      }
                      final int? age = int.tryParse(value.trim());
                      if (age == null || age < 1 || age > 100) {
                        return 'Please enter a valid age between 1 and 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Gender Dropdown (Male, Female, Other)
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _genderOptions
                        .map(
                          (gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Start Drawing Button
                  FilledButton.icon(
                    onPressed: _startDrawing,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'Start Drawing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. HANDWRITING COLLECTOR SCREEN
// ============================================================================
class HandwritingCollectorScreen extends StatefulWidget {
  final int age;
  final String gender;
  final String sessionId;

  const HandwritingCollectorScreen({
    super.key,
    required this.age,
    required this.gender,
    required this.sessionId,
  });

  @override
  State<HandwritingCollectorScreen> createState() =>
      _HandwritingCollectorScreenState();
}

class _HandwritingCollectorScreenState
    extends State<HandwritingCollectorScreen> {
  static const double _strokeWidth = 10.0;
  static const String _bucketName = 'handwriting-images';

  late final List<String> _allCharacters;
  int _currentIndex = 0;
  bool _isUploading = false;

  // Tracks the live size of the handwriting box so export matches the canvas
  Size _canvasSize = const Size(500, 500);

  // Stores completed strokes; each stroke is a list of Offset points.
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  @override
  void initState() {
    super.initState();
    // Merge consonants (33) and numbers (10) -> 43 total characters
    _allCharacters = [...khmerConsonants, ...khmerNumbers];
  }

  bool get _isFinished => _currentIndex >= _allCharacters.length;

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isUploading) return;
    final Offset point = _clampToCanvas(details.localPosition);
    setState(() {
      _currentStroke = [point];
      _strokes.add(_currentStroke);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isUploading) return;
    final Offset point = _clampToCanvas(details.localPosition);
    setState(() {
      _currentStroke.add(point);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isUploading) return;
    setState(() {
      _currentStroke = [];
    });
  }

  Offset _clampToCanvas(Offset point) {
    return Offset(
      point.dx.clamp(0.0, _canvasSize.width),
      point.dy.clamp(0.0, _canvasSize.height),
    );
  }

  Future<void> _saveAndNext() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw the character before saving.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 1. Convert canvas drawing to PNG bytes with solid white background
      final Uint8List pngBytes = await _exportCanvasToPng();

      // 2. Build filename: [gender]_[age]_[shortID]_[index].png
      //    Example output: male_19_948210_00.png
      final String genderFormatted = widget.gender.toLowerCase();
      final String formattedIndex = _currentIndex.toString().padLeft(2, '0');
      final String fileName =
          '${genderFormatted}_${widget.age}_${widget.sessionId}_$formattedIndex.png';

      // 3. Upload binary PNG directly to Supabase Storage bucket 'handwriting-images'
      await Supabase.instance.client.storage.from(_bucketName).uploadBinary(
            fileName,
            pngBytes,
            fileOptions: const FileOptions(
              contentType: 'image/png',
              upsert: false,
            ),
          );

      // 4. Clear canvas and advance to the next character
      if (mounted) {
        setState(() {
          _strokes.clear();
          _currentStroke = [];
          _currentIndex++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// Renders the strokes onto an offscreen canvas with a solid white background
  /// and encodes the result as a PNG [Uint8List].
  Future<Uint8List> _exportCanvasToPng() async {
    final double width = _canvasSize.width > 0 ? _canvasSize.width : 500;
    final double height = _canvasSize.height > 0 ? _canvasSize.height : 500;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width, height),
    );

    // 1. Fill solid white background (prevents transparent background in ML training data)
    final Paint bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      bgPaint,
    );

    // 2. Draw user strokes in solid black
    _renderStrokes(canvas, _strokes);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to encode canvas to PNG.');
    }

    return byteData.buffer.asUint8List();
  }

  static void _renderStrokes(Canvas canvas, List<List<Offset>> strokes) {
    final Paint strokePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(
          stroke.first,
          _strokeWidth / 2,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.fill,
        );
      } else {
        final Path path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length - 1; i++) {
          final Offset p0 = stroke[i];
          final Offset p1 = stroke[i + 1];
          final Offset midPoint = Offset(
            (p0.dx + p1.dx) / 2,
            (p0.dy + p1.dy) / 2,
          );
          path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
        }
        path.lineTo(stroke.last.dx, stroke.last.dy);
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  void _restartSession() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const RegistrationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Khmer Handwriting Data Collector'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: _isFinished
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildEndScreen(),
                ),
              )
            : _buildCollectorContent(),
      ),
    );
  }

  Widget _buildCollectorContent() {
    final int total = _allCharacters.length;
    final String currentChar = _allCharacters[_currentIndex];
    final double progress = (_currentIndex + 1) / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          // ================= TOP SECTION: Progress, Character & Buttons =================
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Character ${_currentIndex + 1} of $total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                    ),
                    Text(
                      'ID: ${widget.sessionId} • ${widget.gender} (${widget.age}) | ${(progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),

                // Prompt & Character Display
                const Text(
                  'Please draw this character below:',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  child: Text(
                    currentChar,
                    style: const TextStyle(
                      fontSize: 68,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Top Action Buttons: Clear & Save & Next
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUploading ? null : _clearCanvas,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Clear'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isUploading ? null : _saveAndNext,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined),
                        label: Text(_isUploading ? 'Saving...' : 'Save & Next'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ================= CENTER-TO-BOTTOM SECTION: Large Handwriting Box =================
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final Size availableSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    if (_canvasSize != availableSize &&
                        availableSize.width > 0 &&
                        availableSize.height > 0) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _canvasSize != availableSize) {
                          setState(() {
                            _canvasSize = availableSize;
                          });
                        }
                      });
                    }

                    return Container(
                      width: availableSize.width,
                      height: availableSize.height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.indigo.shade200,
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: CustomPaint(
                            size: availableSize,
                            painter: _HandwritingPainter(strokes: _strokes),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Thank you for contributing!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Session ID: ${widget.sessionId}\nYou have completed all ${_allCharacters.length} Khmer characters and numerals.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _restartSession,
            icon: const Icon(Icons.replay),
            label: const Text('Start New Session'),
          ),
        ],
      ),
    );
  }
}

class _HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _HandwritingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw solid white background
    final Paint bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw smooth black strokes
    _HandwritingCollectorScreenState._renderStrokes(canvas, strokes);
  }

  @override
  bool shouldRepaint(covariant _HandwritingPainter oldDelegate) => true;
}
