// Theme Settings Detail Screen
import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  bool _isDarkMode = false;
  Color _selectedColor = Colors.blue;

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSection(
              title: 'Darstellungsmodus',
              child: Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Dunkler Modus'),
                  subtitle: const Text('Dunkles Farbschema verwenden'),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    // TODO: Implement theme change logic
                    // You might want to use a state management solution
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Akzentfarbe',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _colorOptions.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                        // TODO: Implement color change logic
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: context.colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 28,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
