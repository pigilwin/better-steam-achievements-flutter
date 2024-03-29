import 'package:better_steam_achievements/achievements/features/configuration.dart';
import 'package:better_steam_achievements/achievements/features/homepage.dart';
import 'package:better_steam_achievements/achievements/features/information.dart';
import 'package:better_steam_achievements/achievements/features/less_than_ten.dart';
import 'package:better_steam_achievements/achievements/features/more_than_ten.dart';
import 'package:better_steam_achievements/achievements/features/preferences.dart';
import 'package:better_steam_achievements/achievements/features/slideshow.dart';
import 'package:go_router/go_router.dart';

class ApplicationRouter {
  static GoRouter router() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/less-than-ten',
          builder: (context, state) => const LessThanTenPage(),
        ),
        GoRoute(
          path: '/more-than-ten',
          builder: (context, state) => const MoreThanTenPage(),
        ),
        GoRoute(
          path: '/information/:id',
          builder: (context, state) {
            return InformationPage(
              appId: int.parse(state.pathParameters['id']!),
            );
          },
        ),
        GoRoute(
          path: '/preferences',
          builder: (context, state) => const PreferencesPage(),
        ),
        GoRoute(
          path: '/slide-show',
          builder: (context, state) => const SlideShow(),
        ),
        GoRoute(
          path: '/config',
          builder: (context, state) => const ConfigurationPage(),
        ),
      ],
      initialLocation: '/',
    );
  }
}
