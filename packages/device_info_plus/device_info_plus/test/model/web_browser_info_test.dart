// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$WebBrowserInfo', () {
    group('fromMap | toMap', () {
      const webBrowserInfoMap = <String, dynamic>{
        'browserName': BrowserName.safari,
        'appCodeName': 'appCodeName',
        'appName': 'appName',
        'appVersion': 'appVersion',
        'deviceMemory': 42,
        'language': 'language',
        'languages': ['en', 'es'],
        'platform': 'platform',
        'product': 'product',
        'productSub': 'productSub',
        'userAgent': 'Safari',
        'vendor': 'vendor',
        'vendorSub': 'vendorSub',
        'hardwareConcurrency': 2,
        'maxTouchPoints': 42,
      };

      test('fromMap should return $WebBrowserInfo with correct values', () {
        final webBrowserInfo = WebBrowserInfo.fromMap(webBrowserInfoMap);

        expect(webBrowserInfo.browserName, BrowserName.safari);
        expect(webBrowserInfo.appCodeName, 'appCodeName');
        expect(webBrowserInfo.appName, 'appName');
        expect(webBrowserInfo.appVersion, 'appVersion');
        expect(webBrowserInfo.deviceMemory, 42);
        expect(webBrowserInfo.language, 'language');
        expect(webBrowserInfo.languages, ['en', 'es']);
        expect(webBrowserInfo.platform, 'platform');
        expect(webBrowserInfo.product, 'product');
        expect(webBrowserInfo.productSub, 'productSub');
        expect(webBrowserInfo.userAgent, 'Safari');
        expect(webBrowserInfo.vendor, 'vendor');
        expect(webBrowserInfo.vendorSub, 'vendorSub');
        expect(webBrowserInfo.hardwareConcurrency, 2);
        expect(webBrowserInfo.maxTouchPoints, 42);
      });

      test('toMap should return map with correct key and map', () {
        final webBrowserInfo = WebBrowserInfo.fromMap(webBrowserInfoMap);
        expect(webBrowserInfo.data, webBrowserInfoMap);
      });
    });

    // Drives every branch of `_parseUserAgentToBrowserName` via the
    // `browserName` getter (BrowserName enum coverage).
    group('browserName parsing', () {
      BrowserName parse(String? userAgent) =>
          WebBrowserInfo.fromMap(<String, dynamic>{'userAgent': userAgent})
              .browserName;

      test('null userAgent -> unknown', () {
        expect(parse(null), BrowserName.unknown);
      });

      test('Firefox', () {
        expect(
          parse('Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) '
              'Gecko/20100101 Firefox/61.0'),
          BrowserName.firefox,
        );
      });

      test('SamsungBrowser -> samsungInternet', () {
        expect(
          parse('Mozilla/5.0 (Linux; Android 9; SAMSUNG SM-G955F) '
              'AppleWebKit/537.36 SamsungBrowser/9.4 Chrome/67.0.3396.87'),
          BrowserName.samsungInternet,
        );
      });

      test('OPR -> opera', () {
        expect(
          parse('Mozilla/5.0 (Macintosh) AppleWebKit/537.36 Chrome/70.0.3538.102 '
              'Safari/537.36 OPR/57.0.3098.106'),
          BrowserName.opera,
        );
      });

      test('Opera substring -> opera', () {
        expect(parse('Mozilla/5.0 Opera/57.0'), BrowserName.opera);
      });

      test('Trident -> msie', () {
        expect(
          parse('Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) '
              'like Gecko'),
          BrowserName.msie,
        );
      });

      test('Edg -> edge', () {
        expect(
          parse('Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/79.0.3945.74 '
              'Safari/537.36 Edg/79.0.309.43'),
          BrowserName.edge,
        );
      });

      test('Edge (legacy) -> edge', () {
        expect(
          parse('Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/58.0.3029.110 '
              'Safari/537.36 Edge/16.16299'),
          BrowserName.edge,
        );
      });

      test('Chrome (checked before Safari)', () {
        expect(
          parse('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
              'Ubuntu Chromium/66.0.3359.181 Chrome/66.0.3359.181 Safari/537.36'),
          BrowserName.chrome,
        );
      });

      test('Safari', () {
        expect(
          parse('Mozilla/5.0 (iPhone; CPU iPhone OS 11_4 like Mac OS X) '
              'AppleWebKit/605.1.15 Version/11.0 Mobile/15E148 Safari/604.1'),
          BrowserName.safari,
        );
      });

      test('unrecognized userAgent -> unknown', () {
        expect(parse('curl/7.81.0'), BrowserName.unknown);
      });
    });
  });
}
