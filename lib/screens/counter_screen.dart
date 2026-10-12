import 'dart:io';

import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../widgets/background_color_picker.dart';
import 'mantra_selection_sheet.dart';
import 'history_screen.dart';
import 'onboarding_screen.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key, required this.storage});

  final StorageService storage;

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  bool _saving = false;

  bool get _isHindi => widget.storage.selectedLanguage == 'hi';
  int get _bead => widget.storage.currentBead;
  int get _mala => widget.storage.completedMalas + 1;
  double get _progress => (_bead % 108) / 108;

  Future<void> _countBead() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final nextBead = _bead + 1;
      final newCompletedMalas = nextBead ~/ 108;
      final newTodayBeads = await widget.storage.getTodayTotalBeads() + 1;

      await widget.storage.saveCountState(
        currentBead: nextBead,
        completedMalas: newCompletedMalas,
        todayTotalBeads: newTodayBeads,
        totalCount: widget.storage.totalCount + 1,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _undo() async {
    if (_saving || _bead == 0) return;
    setState(() => _saving = true);
    try {
      final nextBead = _bead - 1;
      final newCompletedMalas = nextBead ~/ 108;
      final todayBeads = await widget.storage.getTodayTotalBeads();
      final newTodayBeads = (todayBeads - 1).clamp(0, todayBeads).toInt();

      await widget.storage.saveCountState(
        currentBead: nextBead,
        completedMalas: newCompletedMalas,
        todayTotalBeads: newTodayBeads,
        totalCount: (widget.storage.totalCount - 1)
            .clamp(0, widget.storage.totalCount)
            .toInt(),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _toggleDarkChanting(bool enabled) async {
    await widget.storage.setDarkChantingMode(enabled);
    setState(() {});
  }

  void _goToSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(storage: widget.storage),
      ),
    );
  }

  void _openMantraSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MantraSelectionSheet(
        storage: widget.storage,
        onMantraChanged: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkChanting = widget.storage.isDarkChantingMode;
    final background =
        darkChanting ? Color(widget.storage.backgroundColorValue) : null;
    final backgroundImagePath =
        darkChanting ? widget.storage.backgroundImagePath : null;
    final accent = darkChanting
        ? const Color(0xFFFFB74D)
        : Theme.of(context).colorScheme.primary;
    final foreground = darkChanting ? Colors.white : null;

    final currentMantra = widget.storage.selectedMantra;

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
            foregroundColor: foreground,
            leading: IconButton(
              key: const ValueKey('back-to-setup-button'),
              tooltip: _isHindi ? 'वापस जाएँ' : 'Back to setup',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _goToSetup,
            ),
            title: Text(
              currentMantra.isEmpty ? 'Jaapa' : currentMantra,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              IconButton(
                key: const ValueKey('daily-history-button'),
                tooltip: _isHindi ? 'दैनिक इतिहास' : 'Daily history',
                icon: const Icon(Icons.history_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryScreen(storage: widget.storage),
                    ),
                  );
                },
              ),
              IconButton(
                key: const ValueKey('choose-background-color-button'),
                tooltip: _isHindi
                    ? 'पृष्ठभूमि चुनें'
                    : 'Choose background',
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => BackgroundColorPicker.show(
                  context: context,
                  storage: widget.storage,
                  onChanged: () => setState(() {}),
                ),
              ),
              IconButton(
                tooltip: _isHindi ? 'मंत्र चुनें' : 'Select Mantra',
                icon: const Icon(Icons.queue_music_rounded),
                onPressed: _openMantraSelection,
              ),
              IconButton(
                tooltip: _isHindi ? 'ध्यान मोड' : 'Chanting dark mode',
                onPressed: () => _toggleDarkChanting(!darkChanting),
                icon: Icon(
                  darkChanting
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: _isHindi
                        ? 'मंत्र गिनने के लिए टैप करें'
                        : 'Tap to count a bead',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _countBead,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isHindi ? 'वर्तमान माला' : 'CURRENT MALA',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color:
                                            foreground?.withValues(alpha: 0.7),
                                        letterSpacing: 1.5,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${_bead % 108}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        color: accent,
                                        fontSize: 92,
                                        fontWeight: FontWeight.w700,
                                        height: 1,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isHindi
                                      ? '108 में से · माला $_mala'
                                      : 'of 108 · Mala $_mala',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: foreground),
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: 190,
                                  height: 190,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox.expand(
                                        child: CircularProgressIndicator(
                                          value: _progress,
                                          strokeWidth: 9,
                                          strokeCap: StrokeCap.round,
                                          backgroundColor: darkChanting
                                              ? Colors.white12
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                          color: accent,
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${widget.storage.todayTotalBeads}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: foreground,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            _isHindi
                                                ? 'आज के मनके'
                                                : "TODAY'S BEADS",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(color: foreground),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _isHindi
                                      ? 'गिनने के लिए कहीं भी टैप करें'
                                      : 'Tap anywhere to count',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: foreground),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: OutlinedButton.icon(
                    onPressed: _saving || _bead == 0 ? null : _undo,
                    icon: const Icon(Icons.undo_rounded),
                    label:
                        Text(_isHindi ? 'पिछली गिनती हटाएँ' : 'Undo last bead'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: foreground,
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: darkChanting ? Colors.white38 : accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
