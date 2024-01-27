import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noteapp/cubit/auth/auth_cubit.dart';
import 'package:noteapp/cubit/auth/auth_repository.dart';
import 'package:noteapp/cubit/dashboard/dashboard_cubit.dart';
import 'package:noteapp/cubit/dashboard/dashboard_repository.dart';
import 'package:noteapp/cubit/folders_bloc/folders_cubit.dart';
import 'package:noteapp/cubit/folders_bloc/folders_repository.dart';
import 'package:noteapp/cubit/get_started_cubit.dart';
import 'package:noteapp/cubit/notes_bloc/notes_cubit.dart';
import 'package:noteapp/cubit/notes_bloc/notes_repository.dart';
import 'package:noteapp/cubit/page_cubit.dart';
import 'package:noteapp/pages/auth/login_page.dart';
import 'package:noteapp/pages/auth/register_page.dart';
import 'package:noteapp/pages/edit_note_page.dart';
import 'package:noteapp/pages/folder_page.dart';
import 'package:noteapp/pages/home_page.dart';
import 'package:noteapp/pages/settings_page.dart';
import 'package:noteapp/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noteapp/pages/get_started_page.dart';
import 'package:noteapp/utils/routes.dart';
import 'package:relative_time/relative_time.dart';
import 'firebase_options.dart';

void main() {
  runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    runApp(const MyApp());
  });
}

final navigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: Routes.splash,
  observers: [GoRouterObserver()],
  routes: <RouteBase>[
    GoRoute(
      path: Routes.splash,
      builder: (BuildContext context, GoRouterState state) => const SplashPage(),
    ),
    GoRoute(
      path: Routes.home,
      pageBuilder: (context, state) => CustomTransitionPage(
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: const HomePage(),
      ),
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
    ),
    GoRoute(
      path: Routes.login,
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.register,
      builder: (BuildContext context, GoRouterState state) => const RegisterPage(),
    ),
    GoRoute(
      path: "${Routes.editNote}/:id",
      builder: (BuildContext context, GoRouterState state) => EditNote(state.pathParameters["id"]!),
    ),
    GoRoute(
      path: "${Routes.folder}/:id",
      builder: (BuildContext context, GoRouterState state) => FolderPage(state.pathParameters["id"]!),
    ),
    GoRoute(
      path: Routes.starter,
      builder: (BuildContext context, GoRouterState state) => const GetStartedPage(),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
    ),
  ],
);
late NotesCubit notesCubit;
late DashboardCubit dashboardCubit;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(repository: AuthRepository())),
        BlocProvider(create: (context) => NotesCubit(repository: NotesRepository())),
        BlocProvider(create: (context) => PageCubit()),
        BlocProvider(create: (context) => GetStartedCubit()),
        BlocProvider(create: (context) => FoldersCubit(repository: FoldersRepository())),
        BlocProvider(create: (context) => DashboardCubit(repository: DashboardRepository())),
      ],
      child: MaterialApp.router(
        builder: (context, child) {
          notesCubit = BlocProvider.of<NotesCubit>(context);
          dashboardCubit = BlocProvider.of<DashboardCubit>(context);
          return child!;
        },
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          RelativeTimeLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}

class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // print('MyTest didPush: $route');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    if (route.settings.name == "${Routes.editNote}/:id") {
      await notesCubit.deleteEmptyNotes();
      await dashboardCubit.updateDashboard();
      // print((route.settings.arguments as Map)["id"] ?? "");
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // print('MyTest didRemove: $route');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    // print('MyTest didReplace: $newRoute');
  }
}
