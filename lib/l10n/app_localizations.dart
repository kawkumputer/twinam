import 'app_en.dart';
import 'app_fr.dart';
import 'app_es.dart';
import 'app_ar.dart';
import 'app_de.dart';

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
      case 'es':
        return es;
      case 'ar':
        return ar;
      case 'de':
        return de;
      case 'en':
      default:
        return en;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? en[key] ?? key;
  }
}
