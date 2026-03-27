# iOS App Store Deployment Guide for Twin'Am

## 🚀 Prérequis

### 1. Secrets GitHub (à configurer dans Repository Settings > Secrets and variables > Actions)

```bash
# Apple Developer
P12_BASE64                    # Certificate .p12 encodé en base64
P12_PASSWORD                  # Mot de passe du certificat
PROVISION_PROFILE_BASE64      # Provisioning profile encodé en base64
KEYCHAIN_PASSWORD             # Mot de passe pour la keychain temporaire

# Apple Development
DEVELOPMENT_TEAM              # Votre Team ID (ex: ABC1234567)

# App Store Connect API
APP_STORE_CONNECT_ISSUER_ID   # Issuer ID de votre API Key
APP_STORE_CONNECT_API_KEY_ID # ID de votre API Key
APP_STORE_CONNECT_API_KEY_BASE64 # Clé API .p8 encodée en base64
```

### 2. Configuration Apple Developer

1. **Créer un App Store Connect API Key** :
   - Allez dans [App Store Connect > Users and Access > Keys](https://appstoreconnect.apple.com/access/api)
   - Créez une nouvelle clé API
   - Donnez-lui un accès "App Manager"
   - Téléchargez le fichier `.p8`

2. **Certificate de distribution** :
   - Générez un "Apple Distribution" certificate
   - Exportez-le en format `.p12`
   - Encodez-le en base64 : `base64 -i certificate.p12 | pbcopy`

3. **Provisioning Profile** :
   - Créez un provisioning profile "App Store" pour `com.twinam.twin_am`
   - Téléchargez-le et encodez-le en base64

## 📋 Déploiement

### 1. Créer un tag de version
```bash
git tag v1.0.0
git push origin v1.0.0
```

### 2. Déclencher le workflow
Le workflow se déclenche automatiquement sur les tags `v*` ou manuellement via "Actions > iOS Build & Deploy to App Store > Run workflow"

## 🔧 Fichiers créés

### `.github/workflows/ios-deploy.yml`
- Workflow GitHub Actions pour build iOS et déploiement App Store
- Basé sur Flutter 3.24.0 stable
- Gère automatiquement les certificats et provisioning profiles
- Upload direct vers App Store Connect

### `ios/ExportOptions.plist`
- Configuration d'export Xcode
- `method: app-store` pour déploiement production
- Signing manuel avec provisioning profiles
- Upload des symboles de debug activé

## 📱 Configuration iOS

### Bundle Identifier
Assurez-vous que `ios/Runner.xcodeproj/project.pbxproj` contient :
```
PRODUCT_BUNDLE_IDENTIFIER = com.twinam.twin_am
```

### Info.plist
Vérifiez `ios/Runner/Info.plist` pour :
- Permissions nécessaires (notifications)
- Version et build number
- App Transport Security settings

## 🚨 Dépannage

### Erreurs communes
1. **Certificate expired** : Regénérer le certificat de distribution
2. **Provisioning profile invalid** : Recréer le profile avec le bon bundle ID
3. **Team ID mismatch** : Vérifier `DEVELOPMENT_TEAM` secret
4. **API Key permissions** : Assurer "App Manager" access

### Logs utiles
Le workflow inclut des étapes de debug :
- Vérification Flutter doctor
- Listing des fichiers iOS
- Archive creation verification
- IPA path detection

## 🔄 Processus complet

1. **Développement** → Tester sur device/simulator
2. **Version** : Mettre à jour `pubspec.yaml` version et build number
3. **Tag** : Créer et pousser un tag de version
4. **CI/CD** : Le workflow build et upload automatiquement
5. **App Store** : Configurer les métadonnées dans App Store Connect
6. **Review** : Soumettre pour review Apple
7. **Release** : Une fois approuvé, publier sur l'App Store

## 📊 Monitoring

Après déploiement :
- Surveillez les crash reports dans App Store Connect
- Analytics pour les téléchargements et performances
- User feedback pour les futures versions

## 🎯 Bonnes pratiques

- Toujours tester sur device réel avant déploiement
- Maintenir les certificats à jour
- Utiliser des tags de version sémantique (v1.0.0, v1.0.1, etc.)
- Documenter les changements dans les release notes
- Tester le workflow avec un tag de test (ex: v0.1.0-test)
