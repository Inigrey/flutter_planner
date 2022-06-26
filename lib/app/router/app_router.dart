import 'package:activities_api/activities_api.dart';
import 'package:activities_repository/activities_repository.dart';
import 'package:authentication_api/authentication_api.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_planner/activity/activity.dart';
import 'package:flutter_planner/app/router/app_routes.dart';
import 'package:flutter_planner/authentication/authentication.dart';
import 'package:flutter_planner/home/home.dart';
import 'package:flutter_planner/routine/routine.dart';
import 'package:flutter_planner/sign_in/sign_in.dart';
import 'package:flutter_planner/sign_up/sign_up.dart';
import 'package:go_router/go_router.dart';
import 'package:routines_api/routines_api.dart';
import 'package:routines_repository/routines_repository.dart';

abstract class AppRouter {
  static GoRouter router({
    required AuthenticationBloc authenticationBloc,
    String? initialLocation,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        // '/'
        GoRoute(
          path: '/',
          redirect: (state) => '/home/planner',
        ),
        // signUp
        GoRoute(
          path: '/sign-up',
          name: AppRoutes.signUp,
          builder: (context, state) => BlocProvider(
            create: (context) => SignUpBloc(
              authenticationRepository:
                  context.read<AuthenticationRepository>(),
            ),
            child: const SignUpPage(),
          ),
        ),
        // signIn
        GoRoute(
          path: '/sign-in',
          name: AppRoutes.signIn,
          builder: (context, state) => BlocProvider(
            create: (context) => SignInBloc(
              authenticationRepository:
                  context.read<AuthenticationRepository>(),
            ),
            child: const SignInPage(),
          ),
        ),
        // home
        GoRoute(
          path: '/home/:page',
          name: AppRoutes.home,
          builder: (context, state) {
            var index = 0;
            switch (state.params['page']) {
              case 'planner':
                index = 0;
                break;
              case 'schedule':
                index = 1;
                break;
            }
            return HomePage(homeViewKey: state.pageKey, index: index);
          },
          routes: [
            // activity
            GoRoute(
              path: 'activity',
              name: AppRoutes.activity,
              builder: (context, state) => BlocProvider(
                create: (context) => ActivityBloc(
                  activitiesRepository: context.read<ActivitiesRepository>(),
                  initialActivity: state.extra! as Activity,
                ),
                child: const ActivityPage(),
              ),
            ),
            // routine
            GoRoute(
              path: 'routine',
              name: AppRoutes.routine,
              builder: (context, state) => BlocProvider(
                create: (context) => RoutineBloc(
                  routinesRepository: context.read<RoutinesRepository>(),
                  initialRoutine: state.extra! as Routine,
                ),
                child: const RoutinePage(
                  isPage: true,
                ),
              ),
            ),
          ],
        ),
      ],
      refreshListenable: GoRouterRefreshStream(authenticationBloc.stream),
      redirect: (state) {
        final isSignIn = state.location == '/sign-in';
        final isRegistering = state.location == '/sign-up';
        final isAuthenticated = authenticationBloc.state.status ==
            AuthenticationStatus.authenticated;

        if (isAuthenticated && (isSignIn || isRegistering)) {
          return '/home/planner';
        }

        if (!isAuthenticated && !isSignIn && !isRegistering) return '/sign-in';

        return null;
      },
    );
  }
}