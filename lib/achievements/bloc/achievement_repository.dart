import 'package:better_steam_achievements/achievements/bloc/data/achievement.dart';
import 'package:better_steam_achievements/achievements/bloc/data/credentials.dart';
import 'package:better_steam_achievements/achievements/bloc/data/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AchievementRepository {
  Future<Credentials> getCredentials() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final containsSteamId = sharedPreferences.containsKey('steamId');
    final containsApiKey = sharedPreferences.containsKey('apiKey');

    if (!containsApiKey || !containsSteamId) {
      return Credentials.empty();
    }
    final id = sharedPreferences.getString('steamId')!;
    final apiKey = sharedPreferences.getString('apiKey')!;
    return Credentials(id, apiKey);
  }

  Future<void> saveCredentials(Credentials credentials) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('steamId', credentials.steamId);
    sharedPreferences.setString('apiKey', credentials.steamApiKey);
  }

  Future<List<Game>> getGames(Credentials credentials) async {
    final gamesResponse = await http.get(
      getBuiltUrl(
        'IPlayerService/GetOwnedGames/v0001',
        credentials,
        {'include_appinfo': true.toString()},
      ),
    );

    if (gamesResponse.statusCode != 200) {
      return [];
    }

    final reponseBody = convert.jsonDecode(gamesResponse.body);
    final data = reponseBody['response']['games'];
    final games = <Game>[];
    for (final game in data) {
      final applicationId = game['appid'];
      final achievements = <Achievement>[];

      final achievementsResponse = await http.get(
        getBuiltUrl(
          'ISteamUserStats/GetPlayerAchievements/v0001',
          credentials,
          {'appid': applicationId.toString(), 'l': 'en'},
        ),
      );
      if (achievementsResponse.statusCode == 200) {
        final reponseBody = convert.jsonDecode(achievementsResponse.body);
        final playerstats = reponseBody['playerstats'] as Map;
        if (playerstats.containsKey('achievements')) {
          final data = playerstats['achievements'];
          for (final achievement in data) {
            achievements.add(
              Achievement(
                achievement['apiname'],
                achievement['name'],
                achievement['description'],
                achievement['achieved'] == 1,
                achievement['unlocktime'],
              ),
            );
          }
        }
      }

      games.add(
        Game(
          applicationId,
          game['name'],
          game['img_icon_url'],
          game['playtime_forever'],
          achievements,
        ),
      );
    }
    return games;
  }

  Uri getBuiltUrl(
    String path,
    Credentials credentials,
    Map<String, dynamic> additional,
  ) {
    Map<String, dynamic> queryParameters = {
      'key': credentials.steamApiKey,
      'steamid': credentials.steamId,
      'format': 'json'
    };
    queryParameters.addAll(additional);
    return Uri.https("api.steampowered.com", path, queryParameters);
  }
}
