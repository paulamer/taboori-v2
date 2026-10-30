import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local_datasource.dart';

/// Simple Mode — designed for elderly users and people with limited smartphone
/// experience. Provides larger text, bigger buttons, simpler navigation,
/// and reduced visual clutter.

// Provider for Simple Mode state
final simpleModeProvider =
    StateNotifierProvider<SimpleModeNotifier, bool>((ref) {
  return SimpleModeNotifier();
});

class SimpleModeNotifier extends StateNotifier<bool> {
  SimpleModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final ds = LocalDataSource();
    state = ds.isSimpleMode();
  }

  Future<void> toggle() async {
    state = !state;
    final ds = LocalDataSource();
    await ds.saveSimpleMode(state);
  }
}

/// Mixin/extension for widgets to adapt to Simple Mode
extension SimpleModeContext on BuildContext {
  /// Whether Simple Mode is currently active
  bool get isSimpleMode {
    final container = ProviderScope.containerOf(this, listen: false);
    return container.read(simpleModeProvider);
  }
}

/// Theme adjustments for Simple Mode
class SimpleModeTheme {
  static ThemeData apply(ThemeData base, bool isSimple) {
    if (!isSimple) return base;

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontSizeFactor: 1.3, // 30% larger text
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontSize: 18),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      iconTheme: const IconThemeData(size: 32),
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: const TextStyle(fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        minVerticalPadding: 16,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        selectedIconTheme: const IconThemeData(size: 32),
        unselectedIconTheme: const IconThemeData(size: 28),
      ),
    );
  }
}

/// A large, elderly-friendly action button with icon and label
/// Used in Simple Mode instead of small icon buttons
class SimpleActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const SimpleActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: buttonColor.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: buttonColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: buttonColor),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_rounded, // RTL — arrow points left
                  color: buttonColor.withAlpha(120),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple Mode toggle widget for settings
class SimpleModeToggle extends ConsumerWidget {
  const SimpleModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSimple = ref.watch(simpleModeProvider);

    return SwitchListTile(
      title: const Text(
        'الوضع المبسّط',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text(
        'نص أكبر وأزرار أوضح — مناسب لكبار السن',
        style: TextStyle(fontSize: 14),
      ),
      secondary: Icon(
        Icons.accessibility_new_rounded,
        size: 32,
        color: isSimple ? Colors.teal : Colors.grey,
      ),
      value: isSimple,
      onChanged: (_) => ref.read(simpleModeProvider.notifier).toggle(),
    );
  }
}
