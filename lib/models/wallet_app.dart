class WalletApp {
  final String name;
  final String bridgeUrl;
  final String image;
  final String? universalUrl;
  final String aboutUrl;

  const WalletApp({
    required this.name,
    required this.bridgeUrl,
    required this.image,
    required this.aboutUrl,
    this.universalUrl,
  });

  factory WalletApp.fromMap(Map<String, dynamic> json) {
    // const browserPlatforms = {'chrome', 'firefox', 'safari', 'edge'};

    // List<String> platforms = List<String>.from(json['platforms']);
    // bool onlyBrowsers = platforms
    //     .every((platform) => browserPlatforms.contains(platform.toLowerCase()));

    // if (onlyBrowsers) {
    //   return null;
    // }

    String bridgeUrl = '';
    if (json.containsKey('bridge') && json['bridge'] is List) {
      var bridgeList = json['bridge'] as List;
      for (var bridge in bridgeList) {
        if (bridge is Map<String, dynamic> && bridge['type'] == 'sse') {
          var url = bridge['url'];
          if (url is String) {
            bridgeUrl = url;
          } else if (url != null) {
            bridgeUrl = url.toString();
          }
          break;
        }
      }
    }

    return WalletApp(
      name: json['name'].toString(),
      image: json['image'].toString(),
      bridgeUrl: bridgeUrl,
      aboutUrl: json['about_url'].toString(),
      universalUrl: json.containsKey('universal_url')
          ? json['universal_url'].toString()
          : null,
    );
  }
  // factory WalletApp.fromMap(Map<String, dynamic> json) {
  //  String bridgeUrl = json.containsKey('bridge_url') ?
  //       json['bridge_url'].toString() :
  //       (json.containsKey('bridge')
  //           ? (json['bridge'] as List).firstWhere(
  //               (bridge) => bridge['type'] == 'sse',
  //               orElse: () => '')['url'].toString()
  //           : '');

  //   return WalletApp(
  //     name: json['name'].toString(),
  //     image: json['image'].toString(),
  //     bridgeUrl: bridgeUrl,
  //     aboutUrl: json['about_url'].toString(),
  //     universalUrl: json.containsKey('universal_url')
  //         ? json['universal_url'].toString()
  //         : null,
  //   );
  // }
}
