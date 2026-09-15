import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ThemeSwitcherApp());
}

/// Design tokens that complement Material's built-in [ColorScheme].
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.panel,
    required this.panelForeground,
  });

  final Color success;
  final Color panel;
  final Color panelForeground;

  @override
  AppColors copyWith({Color? success, Color? panel, Color? panelForeground}) {
    return AppColors(
      success: success ?? this.success,
      panel: panel ?? this.panel,
      panelForeground: panelForeground ?? this.panelForeground,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      panelForeground: Color.lerp(panelForeground, other.panelForeground, t)!,
    );
  }
}

class ThemeSwitcherApp extends StatefulWidget {
  const ThemeSwitcherApp({super.key});

  @override
  State<ThemeSwitcherApp> createState() => _ThemeSwitcherAppState();
}

class _ThemeSwitcherAppState extends State<ThemeSwitcherApp> {
  static const _themePreferenceKey = 'themeMode';
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  /// Restores the mode the user selected on a previous app launch.
  Future<void> _loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final savedMode = preferences.getString(_themePreferenceKey);
    if (!mounted || savedMode == null) {
      return;
    }

    setState(() {
      _themeMode = savedMode == ThemeMode.dark.name
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  /// Updates the UI immediately, then saves the choice for the next launch.
  void _changeTheme(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }

    setState(() {
      _themeMode = mode;
    });
    _saveThemeMode(mode);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themePreferenceKey, mode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Theme Studio',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
      // AnimatedTheme cross-fades every descendant that reads Theme.of(context).
      builder: (context, child) => AnimatedTheme(
        data: Theme.of(context),
        duration: const Duration(milliseconds: 500),
        child: child ?? const SizedBox.shrink(),
      ),
      home: ThemeHome(themeMode: _themeMode, onThemeChanged: _changeTheme),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
      ),
      extensions: [
        AppColors(
          success: isDark ? Colors.greenAccent.shade200 : Colors.green.shade700,
          // Matches the assignment's required gray-to-white panel transition.
          panel: isDark ? Colors.white : Colors.grey,
          panelForeground: Colors.black87,
        ),
      ],
    );
  }
}

class ThemeHome extends StatelessWidget {
  const ThemeHome({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.extension<AppColors>()!;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Studio')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mobile App Development Testing',
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // AnimatedContainer provides the required 500ms local transition.
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 280,
                height: 280,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appColors.panel,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDark ? Icons.nightlight_round : Icons.wb_sunny,
                        color: colors.primary,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isDark ? 'Dark mode active' : 'Light mode active',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: appColors.panelForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Icon(Icons.check_circle, color: appColors.success),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('Choose the theme', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
                  const SizedBox(width: 12),
                  Switch(
                    value: isDark,
                    onChanged: (isDark) => onThemeChanged(
                      isDark ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),
                ],
              ),
              Text(
                'Your selection is saved for the next launch.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
