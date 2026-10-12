import 'dart:io';

import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.storage});

  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    final isHindi = storage.selectedLanguage == 'hi';
    final background = Color(storage.backgroundColorValue);
    final history = storage.dailyCountHistory;
    final backgroundImagePath = storage.backgroundImagePath;
    final dates = history.keys.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final yesterdayKey = _dateKey(today.subtract(const Duration(days: 1)));

    String dateLabel(String dateKey) {
      if (dateKey == todayKey) return isHindi ? 'आज' : 'Today';
      if (dateKey == yesterdayKey) return isHindi ? 'कल' : 'Yesterday';
      return MaterialLocalizations.of(context).formatMediumDate(
        DateTime.parse(dateKey),
      );
    }

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
        title: Text(isHindi ? 'दैनिक इतिहास' : 'Daily history'),
      ),
      body: dates.isEmpty
          ? Center(
              child: Text(
                isHindi
                    ? 'अभी तक कोई गिनती का इतिहास नहीं है।'
                    : 'No counting history yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dates.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final date = dates[index];
                final count = history[date]!;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today_rounded),
                    title: Text(dateLabel(date)),
                    subtitle: Text(
                      isHindi
                          ? 'आज गिने गए मनके'
                          : 'Beads counted that day',
                    ),
                    trailing: Text(
                      '$count',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                );
              },
            ),
        ),
      ],
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
