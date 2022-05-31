// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:activities_repository/activities_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_planner/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routines_repository/routines_repository.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockActivitiesRepository extends Mock implements ActivitiesRepository {}

class MockRoutinesRepository extends Mock implements RoutinesRepository {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    AuthenticationRepository? authenticationRepository,
    ActivitiesRepository? activitiesRepository,
    RoutinesRepository? routinesRepository,
  }) {
    return pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) =>
                authenticationRepository ?? MockAuthenticationRepository(),
          ),
          RepositoryProvider(
            create: (context) =>
                activitiesRepository ?? MockActivitiesRepository(),
          ),
          RepositoryProvider(
            create: (context) => routinesRepository ?? MockRoutinesRepository(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
  }

  Future<void> pumpRouterApp(
    Widget widget, {
    AuthenticationRepository? authenticationRepository,
    ActivitiesRepository? activitiesRepository,
    RoutinesRepository? routinesRepository,
  }) {
    const initialLocation = '/_initial';

    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          redirect: (state) => '/home/planner',
        ),
        GoRoute(
          path: initialLocation,
          builder: (context, state) => widget,
        ),
        GoRoute(
          path: '/home:page',
          builder: (context, state) => Container(
            key: state.pageKey,
          ),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => Container(
            key: state.pageKey,
          ),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => Container(
            key: state.pageKey,
          ),
        ),
      ],
    );

    return pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) =>
                authenticationRepository ?? MockAuthenticationRepository(),
          ),
          RepositoryProvider(
            create: (context) =>
                activitiesRepository ?? MockActivitiesRepository(),
          ),
          RepositoryProvider(
            create: (context) => routinesRepository ?? MockRoutinesRepository(),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
        ),
      ),
    );
  }
}
