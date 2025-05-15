
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/task_bloc.dart';

import 'blocs/theme_bloc.dart';

import 'screens/task_list_screen.dart';

import 'theme/app_themes.dart';

import 'repostories/task_repsoitory.dart';

void main() async {

// Ensure Flutter binding is initialized

  WidgetsFlutterBinding.ensureInitialized();

// Create instances

  final taskRepository = TaskRepository();

  final themeBloc = ThemeBloc();

  runApp(MyApp(

    taskRepository: taskRepository,

    themeBloc: themeBloc,

  ));

}

class MyApp extends StatelessWidget {

  final TaskRepository taskRepository;

  final ThemeBloc themeBloc;

  const MyApp({

    Key? key,

    required this.taskRepository,

    required this.themeBloc,

  }) : super(key: key);

  @override

  Widget build(BuildContext context) {

    return MultiRepositoryProvider(

      providers: [

        RepositoryProvider.value(value: taskRepository),

      ],

      child: MultiBlocProvider(

        providers: [

          BlocProvider(

            create: (context) => TaskBloc(

              RepositoryProvider.of<TaskRepository>(context),

            ),

          ),

          BlocProvider.value(value: themeBloc),

        ],

        child: BlocBuilder<ThemeBloc, ThemeState>(

          builder: (context, themeState) {

            return MaterialApp(

              title: 'Task Manager',

              debugShowCheckedModeBanner: false,

              theme: AppThemes.lightTheme,

              darkTheme: AppThemes.darkTheme,

              themeMode: themeState.themeMode,

              home: const TaskListScreen(),

            );

          },

        ),

      ),

    );

  }

}
