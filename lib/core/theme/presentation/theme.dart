import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff0059b5),
      surfaceTint: Color(0xff005cbb),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff0071e3),
      onPrimaryContainer: Color(0xfffcfbff),
      secondary: Color(0xff030304),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff1d1d1f),
      onSecondaryContainer: Color(0xff868587),
      tertiary: Color(0xff5b5c60),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff747479),
      onTertiaryContainer: Color(0xfffefcff),
      error: Color(0xffb2000e),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffdc191d),
      onErrorContainer: Color(0xfffff1ef),
      surface: Color(0xfffcf8f8),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff44474a),
      outline: Color(0xff75777a),
      outlineVariant: Color(0xffc5c6c9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffabc7ff),
      primaryFixed: Color(0xffd7e2ff),
      onPrimaryFixed: Color(0xff001b3f),
      primaryFixedDim: Color(0xffabc7ff),
      onPrimaryFixedVariant: Color(0xff00458f),
      secondaryFixed: Color(0xffe4e2e4),
      onSecondaryFixed: Color(0xff1b1b1d),
      secondaryFixedDim: Color(0xffc8c6c8),
      onSecondaryFixedVariant: Color(0xff474649),
      tertiaryFixed: Color(0xffe3e2e7),
      onTertiaryFixed: Color(0xff1a1b1f),
      tertiaryFixedDim: Color(0xffc7c6cb),
      onTertiaryFixedVariant: Color(0xff46464b),
      surfaceDim: Color(0xffddd9d9),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e7),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003570),
      surfaceTint: Color(0xff005cbb),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff006ad6),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff030304),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff1d1d1f),
      onSecondaryContainer: Color(0xffaaa8aa),
      tertiary: Color(0xff35363a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6c6d71),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffd8151b),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f8),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff343639),
      outline: Color(0xff505355),
      outlineVariant: Color(0xff6b6d70),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffabc7ff),
      primaryFixed: Color(0xff006ad6),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0053a9),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6e6c6f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff555457),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6c6d71),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff545459),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xffebe7e7),
      surfaceContainerHigh: Color(0xffdfdcdc),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff002b5e),
      surfaceTint: Color(0xff005cbb),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004794),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff030304),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff1d1d1f),
      onSecondaryContainer: Color(0xffd4d1d4),
      tertiary: Color(0xff2b2c30),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff48494d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2a2c2f),
      outlineVariant: Color(0xff47494c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffabc7ff),
      primaryFixed: Color(0xff004794),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00316a),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff49494b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff333234),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff48494d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff313237),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b8),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color(0xffd7d4d3),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffabc7ff),
      surfaceTint: Color(0xffabc7ff),
      onPrimary: Color(0xff002f66),
      primaryContainer: Color(0xff0071e3),
      onPrimaryContainer: Color(0xfffcfbff),
      secondary: Color(0xffc8c6c8),
      onSecondary: Color(0xff303032),
      secondaryContainer: Color(0xff1d1d1f),
      onSecondaryContainer: Color(0xff868587),
      tertiary: Color(0xffc7c6cb),
      onTertiary: Color(0xff2f3034),
      tertiaryContainer: Color(0xff909095),
      onTertiaryContainer: Color(0xff1e1f23),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xffdc191d),
      onErrorContainer: Color(0xfffff1ef),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc5c6c9),
      outline: Color(0xff8f9194),
      outlineVariant: Color(0xff44474a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff005cbb),
      primaryFixed: Color(0xffd7e2ff),
      onPrimaryFixed: Color(0xff001b3f),
      primaryFixedDim: Color(0xffabc7ff),
      onPrimaryFixedVariant: Color(0xff00458f),
      secondaryFixed: Color(0xffe4e2e4),
      onSecondaryFixed: Color(0xff1b1b1d),
      secondaryFixedDim: Color(0xffc8c6c8),
      onSecondaryFixedVariant: Color(0xff474649),
      tertiaryFixed: Color(0xffe3e2e7),
      onTertiaryFixed: Color(0xff1a1b1f),
      tertiaryFixedDim: Color(0xffc7c6cb),
      onTertiaryFixedVariant: Color(0xff46464b),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2a2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcddcff),
      surfaceTint: Color(0xffabc7ff),
      onPrimary: Color(0xff002552),
      primaryContainer: Color(0xff438fff),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffdedbde),
      onSecondary: Color(0xff252527),
      secondaryContainer: Color(0xff929092),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffdddce1),
      onTertiary: Color(0xff24252a),
      tertiaryContainer: Color(0xff909095),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdbdcdf),
      outline: Color(0xffb0b2b5),
      outlineVariant: Color(0xff8e9093),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff004691),
      primaryFixed: Color(0xffd7e2ff),
      onPrimaryFixed: Color(0xff00102c),
      primaryFixedDim: Color(0xffabc7ff),
      onPrimaryFixedVariant: Color(0xff003570),
      secondaryFixed: Color(0xffe4e2e4),
      onSecondaryFixed: Color(0xff111113),
      secondaryFixedDim: Color(0xffc8c6c8),
      onSecondaryFixedVariant: Color(0xff363638),
      tertiaryFixed: Color(0xffe3e2e7),
      onTertiaryFixed: Color(0xff101115),
      tertiaryFixedDim: Color(0xffc7c6cb),
      onTertiaryFixedVariant: Color(0xff35363a),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282828),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffebf0ff),
      surfaceTint: Color(0xffabc7ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa5c3ff),
      onPrimaryContainer: Color(0xff000b21),
      secondary: Color(0xfff2eff2),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc4c2c4),
      onSecondaryContainer: Color(0xff0b0b0d),
      tertiary: Color(0xfff0eff5),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffc3c2c7),
      onTertiaryContainer: Color(0xff0a0b0f),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeff0f3),
      outlineVariant: Color(0xffc1c3c6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff004691),
      primaryFixed: Color(0xffd7e2ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffabc7ff),
      onPrimaryFixedVariant: Color(0xff00102c),
      secondaryFixed: Color(0xffe4e2e4),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc8c6c8),
      onSecondaryFixedVariant: Color(0xff111113),
      tertiaryFixed: Color(0xffe3e2e7),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffc7c6cb),
      onTertiaryFixedVariant: Color(0xff101115),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff515050),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff474646),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    final isLight = colorScheme.brightness == Brightness.light;

    // Drei abgestufte Flächen, damit Karten sichtbar über dem Hintergrund
    // „schweben" und gefüllte Felder sich wiederum von der Karte abheben.
    // Im Hellmodus sind Karten heller als der Grund (weiß auf hellgrau),
    // im Dunkelmodus heller als der dunkle Grund — in beiden Fällen ein Schritt
    // Kontrast, ohne grell zu wirken.
    final scaffoldBg = isLight
        ? colorScheme.surfaceContainerLow
        : colorScheme.surface;
    final cardColor = isLight
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerHigh;
    final fieldFill = isLight
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHighest;

    // Etwas kräftigere Überschriften für klare Hierarchie (App- und
    // Sektionstitel), Fließtext bleibt unverändert.
    final baseText = textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    final styledText = baseText.copyWith(
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );

    const radius = 12.0;
    OutlineInputBorder fieldBorder(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: styledText,
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: colorScheme.surface,
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // Karten mit feinem Rahmen, weichem Schatten und größerem Radius, damit
      // jede Sektion als eigenständige Fläche lesbar ist statt mit dem
      // Hintergrund zu verschwimmen.
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isLight ? 1 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: styledText.titleLarge,
        // Feine Trennlinie zum Inhalt, ersetzt den fehlenden Schatten.
        shape: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: styledText.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      // Gefüllte, kompakte Eingabefelder mit ruhigem Rahmen. Der Rahmen wird
      // erst beim Fokus kräftig (primär), Fehler bleiben immer rot (s. u.).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: fieldBorder(colorScheme.outlineVariant),
        enabledBorder: fieldBorder(colorScheme.outlineVariant),
        focusedBorder: fieldBorder(colorScheme.primary, width: 2),
        // Material-3-Standard färbt den Rahmen eines fehlerhaften Outline-Felds
        // beim Hovern mit `onErrorContainer` ein — im Light-Theme nahezu weiß,
        // sodass das Feld mit dem Hintergrund verschmilzt. Mit explizitem
        // error-/focusedError-Border bleibt der Rahmen im Fehlerzustand immer rot.
        errorBorder: fieldBorder(colorScheme.error),
        focusedErrorBorder: fieldBorder(colorScheme.error, width: 2),
      ),
    );
  }

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
