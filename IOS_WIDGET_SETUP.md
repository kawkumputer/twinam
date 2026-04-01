# Configuration des Widgets iOS pour Twin'Am

## 📱 Étapes de configuration dans Xcode

### 1. Ouvrir le projet dans Xcode
```bash
cd ios
open Runner.xcworkspace
```

### 2. Créer la Widget Extension

1. Dans Xcode : **File → New → Target**
2. Rechercher et sélectionner **"Widget Extension"**
3. Configuration :
   - **Product Name:** `TwinAmWidget`
   - **Team:** Votre équipe de développement
   - **Organization Identifier:** `com.twinam`
   - **Bundle Identifier:** `com.twinam.app.TwinAmWidget`
   - **Language:** Swift
   - ✅ Cocher "Include Configuration Intent" (optionnel)
4. Cliquer sur **Finish**
5. Quand demandé "Activate TwinAmWidget scheme?", cliquer **Activate**

### 3. Remplacer le code du widget

1. Dans le navigateur de projet, trouver `TwinAmWidget/TwinAmWidget.swift`
2. Remplacer tout le contenu par le code du fichier `ios/TwinAmWidget/TwinAmWidget.swift`

### 4. Configurer App Groups

#### Pour la cible Runner (app principale) :
1. Sélectionner le projet **Runner** dans le navigateur
2. Sélectionner la cible **Runner**
3. Onglet **Signing & Capabilities**
4. Cliquer sur **+ Capability**
5. Ajouter **App Groups**
6. Cliquer sur **+** et ajouter : `group.com.twinam.app`
7. Cocher la case à côté de `group.com.twinam.app`

#### Pour la cible TwinAmWidget :
1. Sélectionner la cible **TwinAmWidget**
2. Répéter les étapes 3-7 ci-dessus
3. **Important :** Utiliser le MÊME App Group ID : `group.com.twinam.app`

### 5. Configurer le Bundle Identifier

1. Sélectionner la cible **TwinAmWidget**
2. Onglet **General**
3. Vérifier que le **Bundle Identifier** est : `com.twinam.app.TwinAmWidget`

### 6. Configurer le Deployment Target

1. Sélectionner la cible **TwinAmWidget**
2. Onglet **General**
3. **iOS Deployment Target:** Minimum iOS 14.0

### 7. Build et Test

1. Sélectionner le scheme **Runner** (pas TwinAmWidget)
2. Choisir un simulateur iOS 14+ ou un appareil réel
3. Cliquer sur **Run** (⌘R)
4. Une fois l'app lancée :
   - Retourner à l'écran d'accueil
   - Appuyer longuement sur l'écran
   - Cliquer sur **+** en haut à gauche
   - Rechercher **Twin'Am**
   - Ajouter le widget

## 🔧 Dépannage

### Erreur "No such module 'WidgetKit'"
- Vérifier que le Deployment Target est iOS 14.0 minimum

### Le widget n'affiche pas les données
- Vérifier que les App Groups sont identiques dans les deux cibles
- Vérifier que l'App Group ID est `group.com.twinam.app`
- Redémarrer l'app Flutter

### Le widget ne se met pas à jour
- Les widgets iOS se mettent à jour toutes les 30 minutes par défaut
- Forcer la mise à jour en modifiant un compteur dans l'app

## 📝 Notes importantes

- **App Groups** : Permet le partage de données entre l'app principale et le widget
- **Timeline** : Le widget se met à jour automatiquement toutes les 30 minutes
- **Tailles supportées** : Small et Medium (peut être étendu à Large)
- **iOS minimum** : iOS 14.0+

## 🎨 Personnalisation

Le widget affiche :
- 📊 Niveau et titre de l'utilisateur
- 📈 Progression du jour (barre de progression)
- 🎯 Nombre de compteurs
- 🏆 Nombre d'objectifs atteints

Pour modifier l'apparence, éditer `TwinAmWidget.swift` dans la section `TwinAmWidgetEntryView`.
