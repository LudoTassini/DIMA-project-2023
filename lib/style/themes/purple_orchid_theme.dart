import 'package:flutter/material.dart';

import '../bloqo_colors.dart';
import 'bloqo_theme.dart';

class PurpleOrchidTheme extends BloqoAppTheme{

  @override
  late BloqoAppThemeType type;
  @override
  late BloqoColors colors;

  PurpleOrchidTheme(){
    type = BloqoAppThemeType.purpleOrchid;
    colors = BloqoColors(
      highContrastColor: const Color(0xFFF7F9F9),
      leadingColor: const Color(0xFF442367),
      inBetweenColor: const Color(0xFF745575),
      trailingColor: const Color(0xFF953A5C),
      inactiveTracker: const Color(0xFFE0E3E7),
      primaryText: const Color(0xFF14181B),
      secondaryText: const Color(0xFF57636C),
      tertiary: const Color(0xFFEE8b60),
      error: const Color(0xFFFA2B36),
      warning: const Color(0xFFD5A203),
      success: const Color(0xFF249689),
      okay: const Color(0xFF29AEDD),
      rate: const Color(0xFFC5A600),
      inactive: const Color(0xFF7E8A92),
      textBlockButton: const Color(0xFF092127),
      multimediaBlockButton: const Color(0xFF3792AF),
      quizBlockButton: const Color(0xFF095A30),
    );
  }

  @override
  ThemeData getThemeData() {

    final TextTheme textTheme = TextTheme(
      displayLarge: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        fontFamily: 'Readex Pro',
      ),
      displayMedium: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        fontFamily: 'Readex Pro',
      ),
      displaySmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'Readex Pro',
      ),
      bodyLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        fontFamily: 'Readex Pro',
      ),
      bodyMedium: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        fontFamily: 'Readex Pro',
      ),
      bodySmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'Readex Pro',
      ),
      labelMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Readex Pro',
        color: colors.leadingColor,
      ),
      titleSmall: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Readex Pro',
      ),
    );

    final FilledButtonThemeData filledButtonThemeData = FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Readex Pro',
          color: colors.highContrastColor,
        ),
        elevation: 3,
        padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        fixedSize: const Size(double.infinity, 50),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      filledButtonTheme: filledButtonThemeData,
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.highContrastColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        headerHelpStyle: const TextStyle(fontSize: 18),
        headerHeadlineStyle: const TextStyle(fontSize: 30),
        dayStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        weekdayStyle: TextStyle(
          fontSize: 22,
          color: colors.trailingColor,
        ),
        yearStyle: const TextStyle(fontSize: 22),
        headerBackgroundColor: colors.leadingColor,
        headerForegroundColor: colors.highContrastColor,
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colors.leadingColor;
            } else {
              return null;
            }
          },
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colors.highContrastColor;
            } else {
              return colors.leadingColor;
            }
          },
        ),
        yearBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colors.leadingColor;
            } else {
              return null;
            }
          },
        ),
        yearForegroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colors.highContrastColor;
            } else {
              return colors.leadingColor;
            }
          },
        ),
        todayBorder: BorderSide.none,
        dividerColor: colors.leadingColor,
        cancelButtonStyle: filledButtonThemeData.style?.copyWith(
          textStyle: WidgetStateProperty.resolveWith((states) => const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
          foregroundColor: WidgetStateProperty.resolveWith((_) => colors.highContrastColor),
          backgroundColor: WidgetStateProperty.resolveWith((_) => colors.error),
          fixedSize: WidgetStateProperty.resolveWith((_) => const Size(double.infinity, double.infinity)),
          padding: WidgetStateProperty.resolveWith((_) => const EdgeInsetsDirectional.fromSTEB(15, 8, 15, 8)),
        ),
        confirmButtonStyle: filledButtonThemeData.style?.copyWith(
          textStyle: WidgetStateProperty.resolveWith((states) => const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
          foregroundColor: WidgetStateProperty.resolveWith((_) => colors.highContrastColor),
          backgroundColor: WidgetStateProperty.resolveWith((_) => colors.leadingColor),
          fixedSize: WidgetStateProperty.resolveWith((_) => const Size(double.infinity, double.infinity)),
          padding: WidgetStateProperty.resolveWith((_) => const EdgeInsetsDirectional.fromSTEB(15, 8, 15, 8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colors.leadingColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: textTheme.labelMedium,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.displaySmall?.copyWith(overflow: TextOverflow.ellipsis),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colors.leadingColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: textTheme.labelMedium,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        menuStyle: MenuStyle(
          surfaceTintColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? TextStyle(
            color: colors.leadingColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          )
              : TextStyle(
            color: colors.highContrastColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: textTheme.displayMedium,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: colors.highContrastColor,
        unselectedLabelColor: colors.highContrastColor,
        labelStyle: textTheme.displayMedium!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: textTheme.displayMedium!.copyWith(
          fontSize: 18,
        ),
        dividerColor: Colors.transparent,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colors.trailingColor,
            width: 3.0,
          ),
        ),
      ),
    );
  }

}

