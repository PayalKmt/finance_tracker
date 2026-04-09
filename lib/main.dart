import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/goal/goal_bloc.dart';
import 'blocs/theme/theme_bloc.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/goal_repository.dart';
import 'screens/home/app_shell.dart';
import 'utils/app_theme.dart' as theme;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => TransactionRepository()),
        RepositoryProvider(create: (_) => GoalRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => TransactionBloc(
              repository: ctx.read<TransactionRepository>(),
            )..add(LoadTransactions()),
          ),
          BlocProvider(
            create: (ctx) => GoalBloc(
              repository: ctx.read<GoalRepository>(),
            )..add(LoadGoals()),
          ),
          BlocProvider(
            create: (_) => ThemeBloc()..add(LoadTheme()),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Finance Companion',
              debugShowCheckedModeBanner: false,
              theme: theme.AppTheme.light,
              darkTheme: theme.AppTheme.dark,
              themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
              home: const AppShell(),
            );
          },
        ),
      ),
    );
  }
}
