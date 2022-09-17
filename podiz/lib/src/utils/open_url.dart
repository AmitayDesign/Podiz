import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:podiz/src/theme/palette.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> openUrl(String url) async {
  try {
    custom_tabs.launch(
      url,
      customTabsOption: custom_tabs.CustomTabsOption(
        toolbarColor: Palette.darkPurple,
        showPageTitle: true,
        enableUrlBarHiding: true,
        enableDefaultShare: true,
        enableInstantApps: true,
        animation: custom_tabs.CustomTabsSystemAnimation.slideIn(),
        extraCustomTabs: const [
          'org.mozilla.firefox',
          'com.microsoft.emmx',
          'com.opera.browser',
          'com.duckduckgo.mobile.android',
          'com.brave.browser',
          'com.sec.android.app.sbrowser',
          'com.mi.globalbrowser',
        ],
      ),
      safariVCOption: const custom_tabs.SafariViewControllerOption(
        preferredBarTintColor: Palette.darkPurple,
        preferredControlTintColor: Colors.white,
        statusBarBrightness: Brightness.dark,
        barCollapsingEnabled: true,
        dismissButtonStyle:
            custom_tabs.SafariViewControllerDismissButtonStyle.close,
      ),
    );
  } catch (_) {
    if (await canLaunchUrlString(url)) {
      launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not open the url');
    }
  }
}
