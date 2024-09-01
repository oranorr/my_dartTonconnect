import 'dart:convert';
import 'dart:developer';
import 'package:darttonconnect/exceptions.dart';
import 'package:darttonconnect/models/wallet_app.dart';
import 'package:http/http.dart' as http;

const fallbackWalletsList = [
  WalletApp(
      name: 'Tonkeeper',
      bridgeUrl: 'https://bridge.tonapi.io/bridge',
      image: 'https://tonkeeper.com/assets/tonconnect-icon.png',
      aboutUrl: 'https://tonkeeper.com',
      universalUrl: 'https://app.tonkeeper.com/ton-connect'),
  WalletApp(
      name: 'Tonhub',
      bridgeUrl: 'https://connect.tonhubapi.com/tonconnect',
      image: 'https://tonhub.com/tonconnect_logo.png',
      aboutUrl: 'https://tonhub.com',
      universalUrl: 'https://tonhub.com/ton-connect')
];

class WalletsListManager {
  String _walletsListSource =
      'https://raw.githubusercontent.com/ton-blockchain/wallets-list/main/wallets-v2.json';
  // 'https://raw.githubusercontent.com/ton-blockchain/wallets-list/main/wallets.json';
  final int? _cacheTtl;

  dynamic _dynamicWalletsListCache;
  List<WalletApp> walletsListCache = [];
  int? _walletsListCacheCreationTimestamp;

  WalletsListManager({String? walletsListSource, int? cacheTtl})
      : _cacheTtl = cacheTtl {
    if (walletsListSource != null) {
      _walletsListSource = walletsListSource;
    }
  }

  Future<List<WalletApp>> getWallets() async {
    const browserPlatforms = {'chrome', 'firefox', 'safari', 'edge'};
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (_cacheTtl != null &&
        _walletsListCacheCreationTimestamp != null &&
        currentTimestamp > _walletsListCacheCreationTimestamp! + _cacheTtl!) {
      _dynamicWalletsListCache = null;
    }

    if (_dynamicWalletsListCache == null) {
      List<WalletApp> walletsList = [];
      try {
        final response = await http.get(Uri.parse(_walletsListSource));
        // log('Reponse is: ${response.body}');
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body.toString());
          // log(responseBody.toString());
          if (responseBody is List) {
            for (Map<String, dynamic> walletMap in responseBody) {
              List<String> platforms =
                  List<String>.from(walletMap['platforms']);
              bool onlyBrowsers = platforms.every((platform) =>
                  browserPlatforms.contains(platform.toLowerCase()));
              if (!onlyBrowsers) {
                walletsList.add(WalletApp.fromMap(walletMap));
              }
            }
          } else {
            throw FetchWalletsError(
                'Wrong wallets list format, wallets list must be an array.');
          }
        } else {
          throw FetchWalletsError('Failed to fetch wallets list.');
        }
      } catch (e) {
        log('we fall to fallback with: $e');
        walletsList = fallbackWalletsList;
      }

      walletsListCache = [];
      for (final wallet in walletsList) {
        walletsListCache.add(wallet);
      }

      _walletsListCacheCreationTimestamp = currentTimestamp;
    }

    return walletsListCache;
  }
}
