import 'package:upgrader/upgrader.dart';

class UpgraderMessagesFr extends UpgraderMessages {
  @override
  String get body => 'Une nouvelle version de {{appName}} est disponible ! Version {{currentInstalledVersion}} → {{currentAppStoreVersion}}';

  @override
  String get buttonTitleIgnore => 'Ignorer';

  @override
  String get buttonTitleLater => 'Plus tard';

  @override
  String get buttonTitleUpdate => 'Mettre à jour';

  @override
  String get prompt => 'Nouvelle version disponible 🎉';

  @override
  String get title => 'Mise à jour disponible';
}

class UpgraderMessagesAr extends UpgraderMessages {
  @override
  String get body => 'إصدار جديد من {{appName}} متاح! الإصدار {{currentInstalledVersion}} ← {{currentAppStoreVersion}}';

  @override
  String get buttonTitleIgnore => 'تجاهل';

  @override
  String get buttonTitleLater => 'لاحقاً';

  @override
  String get buttonTitleUpdate => 'تحديث';

  @override
  String get prompt => 'إصدار جديد متاح 🎉';

  @override
  String get title => 'تحديث متاح';
}

class UpgraderMessagesEs extends UpgraderMessages {
  @override
  String get body => '¡Una nueva versión de {{appName}} está disponible! Versión {{currentInstalledVersion}} → {{currentAppStoreVersion}}';

  @override
  String get buttonTitleIgnore => 'Ignorar';

  @override
  String get buttonTitleLater => 'Más tarde';

  @override
  String get buttonTitleUpdate => 'Actualizar';

  @override
  String get prompt => 'Nueva versión disponible 🎉';

  @override
  String get title => 'Actualización disponible';
}

class UpgraderMessagesDe extends UpgraderMessages {
  @override
  String get body => 'Eine neue Version von {{appName}} ist verfügbar! Version {{currentInstalledVersion}} → {{currentAppStoreVersion}}';

  @override
  String get buttonTitleIgnore => 'Ignorieren';

  @override
  String get buttonTitleLater => 'Später';

  @override
  String get buttonTitleUpdate => 'Aktualisieren';

  @override
  String get prompt => 'Neue Version verfügbar 🎉';

  @override
  String get title => 'Update verfügbar';
}
