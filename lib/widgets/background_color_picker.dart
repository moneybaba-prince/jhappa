import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/storage_service.dart';

class _BackgroundColorPreset {
  const _BackgroundColorPreset(this.name, this.value);

  final String name;
  final int value;
}

const _backgroundColors = [
  _BackgroundColorPreset('Black', 0xFF0D0D0D),
  _BackgroundColorPreset('Charcoal', 0xFF202124),
  _BackgroundColorPreset('Midnight blue', 0xFF142238),
  _BackgroundColorPreset('Forest green', 0xFF173126),
  _BackgroundColorPreset('Deep teal', 0xFF153235),
  _BackgroundColorPreset('Plum', 0xFF302039),
  _BackgroundColorPreset('Burgundy', 0xFF351D25),
  _BackgroundColorPreset('Saffron', 0xFFFF9933),
  _BackgroundColorPreset('Red', 0xFFC62828),
];

class BackgroundColorPicker {
  static Future<void> _pickImage({
    required BuildContext context,
    required StorageService storage,
    required VoidCallback onChanged,
  }) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final destination = File(
        '${directory.path}${Platform.pathSeparator}jaapa_background_image',
      );
      await destination.writeAsBytes(await image.readAsBytes(), flush: true);
      await storage.setBackgroundImagePath(destination.path);

      if (!context.mounted) return;
      onChanged();
      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not set background image: $error')),
      );
    }
  }

  static Future<void> show({
    required BuildContext context,
    required StorageService storage,
    required VoidCallback onChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Text(
                  'Choose background',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      key: const ValueKey('choose-background-image'),
                      leading: const Icon(Icons.image_outlined),
                      title: const Text('Choose image from device'),
                      onTap: () => _pickImage(
                        context: sheetContext,
                        storage: storage,
                        onChanged: onChanged,
                      ),
                    ),
                    if (storage.backgroundImagePath != null)
                      ListTile(
                        key: const ValueKey('remove-background-image'),
                        leading: const Icon(Icons.hide_image_outlined),
                        title: const Text('Use background color instead'),
                        onTap: () async {
                          await storage.setBackgroundImagePath(null);
                          if (!sheetContext.mounted) return;
                          onChanged();
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    for (final preset in _backgroundColors)
                      ListTile(
                        key: ValueKey('background-color-${preset.name}'),
                        leading: CircleAvatar(
                          backgroundColor: Color(preset.value),
                          child: storage.backgroundColorValue == preset.value
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                        title: Text(preset.name),
                        selected: storage.backgroundColorValue == preset.value,
                        onTap: () async {
                          await storage.setBackgroundColorValue(preset.value);
                          if (!sheetContext.mounted) return;
                          onChanged();
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
