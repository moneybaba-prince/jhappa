
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class MantraSelectionSheet extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onMantraChanged;

  const MantraSelectionSheet({
    super.key,
    required this.storage,
    required this.onMantraChanged,
  });

  @override
  State<MantraSelectionSheet> createState() =>
      _MantraSelectionSheetState();
}

class _MantraSelectionSheetState
    extends State<MantraSelectionSheet> {
  late String _selectedMantra;
  late int _vowTarget;

  final TextEditingController _customMantraController =
      TextEditingController();

  final List<Map<String, String>> _defaultPresets = [
    {'name': 'राम', 'transliteration': 'Ram'},
    {
      'name': 'ॐ नमः शिवाय',
      'transliteration': 'Om Namah Shivaya',
    },
    {
      'name': 'हरे कृष्णा',
      'transliteration': 'Hare Krishna',
    },
    {
      'name': 'वाहेगुरु',
      'transliteration': 'Waheguru',
    },
    {
      'name': 'ॐ नमो भगवते वासुदेवाय',
      'transliteration': 'Om Namo Bhagavate Vasudevaya',
    },
    {
      'name': 'Just Count',
      'transliteration': 'बिना मंत्र',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedMantra = widget.storage.selectedMantra;
    _vowTarget = widget.storage.vowTargetMalas;
  }

  @override
  void dispose() {
    _customMantraController.dispose();
    super.dispose();
  }

  Future<void> _selectMantra(String mantra) async {
    HapticFeedback.selectionClick();

    setState(() {
      _selectedMantra = mantra;
    });

    await widget.storage.setSelectedMantra(mantra);

    if (!mounted) return;

    widget.onMantraChanged();
  }

  void _addCustomMantraDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Custom Mantra'),
        content: TextField(
          controller: _customMantraController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Gayatri Mantra, Om Mani Padme Hum',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = _customMantraController.text.trim();

              if (text.isEmpty) return;

              await widget.storage.addCustomMantra(text);

              if (!mounted) return;

              await _selectMantra(text);

              if (!mounted) return;

              _customMantraController.clear();

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add & Select'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateVowTarget(int change) async {
    final newTarget = _vowTarget + change;

    if (newTarget < 1) return;

    setState(() {
      _vowTarget = newTarget;
    });

    await widget.storage.setVowTargetMalas(newTarget);

    if (!mounted) return;

    widget.onMantraChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customList = widget.storage.customMantras;

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Mantra & Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Daily Vow Target Adjustment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('Daily Goal Target:'),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _vowTarget > 1
                        ? () => _updateVowTarget(-1)
                        : null,
                  ),
                  Text(
                    '$_vowTarget Malas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _updateVowTarget(1),
                  ),
                ],
              ),
            ],
          ),

          const Divider(),

          Expanded(
            child: ListView(
              children: [
                const Text(
                  'Presets:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                ..._defaultPresets.map((preset) {
                  final name = preset['name']!;
                  final isSelected = _selectedMantra == name;

                  return ListTile(
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(preset['transliteration']!),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () => _selectMantra(name),
                  );
                }),

                if (customList.isNotEmpty) ...[
                  const SizedBox(height: 12),

                  const Text(
                    'Custom Mantras:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ...customList.map((mantra) {
                    final isSelected = _selectedMantra == mantra;

                    return ListTile(
                      title: Text(
                        mantra,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      onTap: () => _selectMantra(mantra),
                    );
                  }),
                ],

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _addCustomMantraDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Custom Mantra'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}