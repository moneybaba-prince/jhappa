import 'dart:io';

import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../widgets/background_color_picker.dart';
import 'counter_screen.dart';

class _MantraPreset {
  const _MantraPreset(this.text, this.labelHi, this.labelEn);

  final String text;
  final String labelHi;
  final String labelEn;
}

const _mantras = <_MantraPreset>[
  _MantraPreset('ॐ नमः शिवाय', 'शिव मंत्र', 'Shiva mantra'),
  _MantraPreset('हरे कृष्ण हरे कृष्ण, कृष्ण कृष्ण हरे हरे',
      'हरे कृष्ण महामंत्र', 'Hare Krishna mantra'),
  _MantraPreset('श्री राम जय राम जय जय राम', 'राम मंत्र', 'Rama mantra'),
  _MantraPreset('ॐ', 'ॐ', 'Om'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.storage});

  final StorageService storage;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late String _language;
  late int _selectedMantra;
  bool _starting = false;

  bool get _isHindi => _language == 'hi';

  @override
  void initState() {
    super.initState();
    _language = widget.storage.selectedLanguage;
    final savedMantra = widget.storage.selectedMantra;
    _selectedMantra = _mantras.indexWhere(
      (preset) => preset.text == savedMantra,
    );
    if (_selectedMantra < 0) _selectedMantra = 0;
  }

  Future<void> _startCounting() async {
    if (_starting) return;
    setState(() => _starting = true);

    await widget.storage.completeOnboarding(
      language: _language,
      mantra: _mantras[_selectedMantra].text,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CounterScreen(storage: widget.storage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = Color(widget.storage.backgroundColorValue);
    final backgroundImagePath = widget.storage.backgroundImagePath;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (backgroundImagePath != null) ...[
          Image.file(File(backgroundImagePath), fit: BoxFit.cover),
          const ColoredBox(color: Color(0x66000000)),
        ],
        Scaffold(
          backgroundColor:
              backgroundImagePath == null ? background : Colors.transparent,
          appBar: AppBar(
            backgroundColor:
                backgroundImagePath == null ? background : Colors.transparent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                key: const ValueKey('choose-background-color-button'),
                tooltip: 'Choose background',
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => BackgroundColorPicker.show(
                  context: context,
                  storage: widget.storage,
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
                  children: [
                    Icon(Icons.spa_rounded, size: 58, color: colors.primary),
                    const SizedBox(height: 20),
                    Text(
                      'जापा में आपका स्वागत है\nWelcome to Jaapa',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                    ),
                    const SizedBox(height: 28),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'hi', label: Text('हिन्दी')),
                        ButtonSegment(value: 'en', label: Text('English')),
                      ],
                      selected: {_language},
                      onSelectionChanged: (selection) {
                        setState(() => _language = selection.first);
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _isHindi ? 'अपना मंत्र चुनें' : 'Choose your mantra',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    RadioGroup<int>(
                      groupValue: _selectedMantra,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMantra = value);
                        }
                      },
                      child: Column(
                        children: [
                          for (var index = 0; index < _mantras.length; index++)
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: RadioListTile<int>(
                                value: index,
                                title: Text(
                                  _mantras[index].text,
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                subtitle: Text(
                                  _isHindi
                                      ? _mantras[index].labelHi
                                      : _mantras[index].labelEn,
                                ),
                                activeColor: colors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      key: const ValueKey('start-counting-button'),
                      onPressed: _starting ? null : _startCounting,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        _starting
                            ? (_isHindi
                                ? 'कृपया प्रतीक्षा करें…'
                                : 'Please wait…')
                            : (_isHindi ? 'शुरू करें' : 'Start counting'),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        textStyle: const TextStyle(fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
