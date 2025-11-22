import 'package:flutter/material.dart';
import 'package:qlmoney/data/theme_change.dart';

/// Global theme notifier used across the app to toggle light/dark mode.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Initialize from existing ThemeChange if present and keep in sync.
void initThemeManager() {
	// set initial value from existing ThemeChange
	themeNotifier.value = themeChange.themeMode;

	// listen for changes on the existing ThemeChange and update the ValueNotifier
	themeChange.addListener(() {
		themeNotifier.value = themeChange.themeMode;
	});
}
