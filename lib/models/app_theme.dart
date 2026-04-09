import 'package:equatable/equatable.dart';

class AppThemeState extends Equatable {
  final bool isDarkMode;

  const AppThemeState({required this.isDarkMode});

  @override
  List<Object?> get props => [isDarkMode];
}
