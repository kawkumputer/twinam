import 'app_en.dart';
import 'app_fr.dart';

class AppLocalizations {
  final String locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(String locale) {
    return AppLocalizations(locale);
  }

  Map<String, String> get _localizedStrings {
    switch (locale) {
      case 'fr':
        return fr;
      case 'en':
      default:
        return en;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? en[key] ?? key;
  }
}
