# Configuration Widget iOS via GitHub Actions (Sans Xcode)

## 🚀 Déploiement automatique iOS avec Widgets

Puisque vous utilisez GitHub Actions pour déployer sur App Store Connect, voici comment intégrer les widgets iOS dans votre workflow.

## 📁 Fichiers créés

✅ **Code Widget iOS :**
- `ios/TwinAmWidget/TwinAmWidget.swift` - Code SwiftUI du widget
- `ios/TwinAmWidget/Info.plist` - Configuration du widget
- `ios/Runner/Runner.entitlements` - App Groups pour Runner
- `ios/TwinAmWidget/TwinAmWidget.entitlements` - App Groups pour Widget

✅ **Scripts :**
- `scripts/setup_ios_widget.sh` - Script de configuration automatique

## 🔧 Configuration requise

### 1. Ajouter le Widget Extension au projet Xcode (Une seule fois)

**Option A : Via Xcode Cloud ou machine macOS distante**
```bash
# Sur une machine avec Xcode (ou via Xcode Cloud)
cd ios
open Runner.xcworkspace

# Puis :
# File → New → Target → Widget Extension
# Product Name: TwinAmWidget
# Bundle ID: com.twinam.app.TwinAmWidget
```

**Option B : Modifier directement le fichier project.pbxproj**

Le fichier `ios/Runner.xcodeproj/project.pbxproj` doit inclure la cible Widget. Cela peut être fait :
1. Une fois manuellement sur une machine avec Xcode
2. Ou en modifiant le fichier XML directement (complexe)

### 2. Configuration App Groups dans App Store Connect

1. Aller sur [Apple Developer Portal](https://developer.apple.com)
2. **Certificates, Identifiers & Profiles**
3. **Identifiers** → Sélectionner votre App ID
4. Activer **App Groups**
5. Créer/Sélectionner : `group.com.twinam.app`
6. Répéter pour le Widget Extension ID : `com.twinam.app.TwinAmWidget`

### 3. Mettre à jour les Provisioning Profiles

Les profils de provisionnement doivent inclure :
- ✅ App Groups capability
- ✅ Widget Extension target

Régénérer les profils dans Apple Developer Portal après avoir activé App Groups.

## 🔄 Workflow GitHub Actions

Votre workflow iOS doit inclure :

```yaml
- name: Setup iOS Widget
  run: |
    chmod +x scripts/setup_ios_widget.sh
    ./scripts/setup_ios_widget.sh

- name: Build iOS with Widget
  run: |
    cd ios
    flutter build ios --release --no-codesign
    # Ou avec fastlane si vous l'utilisez
    # fastlane ios release
```

## 📦 Structure du projet iOS

```
ios/
├── Runner/
│   ├── Runner.entitlements          # App Groups pour l'app principale
│   └── Info.plist
├── TwinAmWidget/                     # Widget Extension
│   ├── TwinAmWidget.swift           # Code du widget
│   ├── TwinAmWidget.entitlements    # App Groups pour le widget
│   └── Info.plist
└── Runner.xcodeproj/
    └── project.pbxproj               # Doit inclure la cible Widget
```

## ✅ Checklist de déploiement

- [ ] Widget Extension ajoutée au projet Xcode
- [ ] App Groups configurés dans Apple Developer Portal
- [ ] Provisioning Profiles régénérés avec App Groups
- [ ] Secrets GitHub Actions mis à jour (si nécessaire)
- [ ] Script `setup_ios_widget.sh` exécuté dans le workflow
- [ ] Build iOS réussi avec le widget
- [ ] Upload vers TestFlight/App Store Connect

## 🧪 Test local (si accès à un Mac)

```bash
# Installer les dépendances
flutter pub get

# Setup widget
chmod +x scripts/setup_ios_widget.sh
./scripts/setup_ios_widget.sh

# Build iOS
flutter build ios --release

# Ou run sur simulateur
flutter run -d "iPhone 15 Pro"
```

## 🔍 Vérification

Une fois déployé sur TestFlight :
1. Installer l'app depuis TestFlight
2. Aller sur l'écran d'accueil iOS
3. Appuyer longuement → Widgets
4. Chercher "Twin'Am"
5. Ajouter le widget

## 📝 Notes importantes

- **App Groups** : Essentiel pour partager les données entre l'app et le widget
- **Bundle IDs** :
  - App principale : `com.twinam.app`
  - Widget : `com.twinam.app.TwinAmWidget`
- **Mise à jour** : Le widget se met à jour automatiquement toutes les 30 minutes
- **iOS minimum** : 14.0+

## 🆘 Dépannage

### Le widget n'apparaît pas dans la liste
- Vérifier que le Widget Extension est bien inclus dans le build
- Vérifier le Bundle ID du widget

### Le widget affiche des données vides
- Vérifier que les App Groups sont identiques dans l'app et le widget
- Vérifier que `WidgetService().initialize()` est appelé au démarrage de l'app

### Erreur de build
- Vérifier que les provisioning profiles incluent App Groups
- Vérifier que tous les fichiers Swift sont dans le bon target
