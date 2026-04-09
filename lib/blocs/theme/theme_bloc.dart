import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(isDark: false)) {
    on<ToggleTheme>(_onToggle);
    on<LoadTheme>(_onLoad);
  }

  Future<void> _onLoad(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    emit(ThemeState(isDark: isDark));
  }

  Future<void> _onToggle(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newValue = !state.isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', newValue);
    emit(ThemeState(isDark: newValue));
  }
}
