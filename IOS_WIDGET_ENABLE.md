# Comment activer les Widgets iOS pour Twin'Am

## 🚫 Statut actuel : DÉSACTIVÉ

Les widgets iOS sont actuellement désactivés dans le build pour éviter les erreurs de provisioning profile.

**Widgets Android** : ✅ Fonctionnels  
**Widgets iOS** : ⏸️ Désactivés temporairement

---

## 📋 Pourquoi désactivés ?

Le Widget Extension iOS nécessite :
1. Un **Bundle ID séparé** : `com.twinam.twinam.TwinAmWidget`
2. Un **Provisioning Profile dédié** avec la capability **App Groups**
3. Configuration dans **Apple Developer Portal**

Sans ces éléments, le build échoue avec :
```
error: Provisioning profile "TwinAm App" has app ID "com.twinam.twinam", 
which does not match the bundle ID "com.twinam.app.TwinAmWidget"
```

---

## ✅ Comment activer les widgets iOS

### **Étape 1 : Apple Developer Portal**

#### 1.1 Créer l'App ID pour le Widget
1. Aller sur [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
2. **Identifiers** → **+** (Add)
3. Sélectionner **App IDs** → Continue
4. **Description** : `Twin'Am Widget Extension`
5. **Bundle ID** : `com.twinam.twinam.TwinAmWidget` (Explicit)
6. **Capabilities** :
   - ✅ Cocher **App Groups**
   - Cliquer sur **Configure**
   - Sélectionner ou créer : `group.com.twinam.app`
7. **Continue** → **Register**

#### 1.2 Créer le Provisioning Profile pour le Widget
1. **Profiles** → **+** (Add)
2. **Distribution** → **App Store** → Continue
3. **App ID** : Sélectionner `com.twinam.twinam.TwinAmWidget`
4. **Certificate** : Sélectionner votre certificat de distribution
5. **Profile Name** : `TwinAm Widget Distribution`
6. **Generate** → **Download** le fichier `.mobileprovision`

#### 1.3 Convertir en Base64
```bash
# Sur macOS/Linux
base64 -i TwinAm_Widget_Distribution.mobileprovision | pbcopy

# Sur Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("TwinAm_Widget_Distribution.mobileprovision")) | Set-Clipboard
```

---

### **Étape 2 : GitHub Secrets**

1. Aller sur votre repo GitHub : **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret**
3. **Name** : `WIDGET_PROVISION_PROFILE_BASE64`
4. **Value** : Coller le contenu Base64 du profil widget
5. **Add secret**

---

### **Étape 3 : Mettre à jour le Workflow GitHub Actions**

Éditer `.github/workflows/ios-deploy.yml` :

Ajouter après l'installation du profil principal (ligne ~58) :

```yaml
# Install widget provisioning profile
WIDGET_PP_PATH=$RUNNER_TEMP/twinam_widget_distribution.mobileprovision
echo -n "$WIDGET_PROVISION_PROFILE_BASE64" | base64 --decode -o $WIDGET_PP_PATH

# Get widget profile UUID
WIDGET_UUID=$(/usr/libexec/PlistBuddy -c "Print UUID" /dev/stdin <<< $(/usr/bin/security cms -D -i $WIDGET_PP_PATH))
cp $WIDGET_PP_PATH ~/Library/MobileDevice/Provisioning\ Profiles/$WIDGET_UUID.mobileprovision
echo "Installed widget provisioning profile with UUID: $WIDGET_UUID"
```

Et ajouter la variable d'environnement :

```yaml
env:
  # ... autres secrets ...
  WIDGET_PROVISION_PROFILE_BASE64: ${{ secrets.WIDGET_PROVISION_PROFILE_BASE64 }}
```

---

### **Étape 4 : Réactiver le Widget dans le Script**

Éditer `scripts/setup_ios_widget.sh` :

Décommenter les lignes 90-107 :

```bash
# Remplacer cette section :
# iOS Widget Extension setup is DISABLED for now
# Uncomment below when provisioning profiles are configured

# echo "🔧 Adding Widget Extension to Xcode project..."
# ...

# Par :
echo "🔧 Adding Widget Extension to Xcode project..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/add_widget_to_xcode.py"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Widget Extension successfully added to Xcode project!"
    # ...
fi
```

---

### **Étape 5 : Corriger le Bundle ID dans le Script Python**

Éditer `scripts/add_widget_to_xcode.py` ligne ~235 :

```python
# Chercher :
PRODUCT_BUNDLE_IDENTIFIER = com.twinam.app.TwinAmWidget;

# Remplacer par :
PRODUCT_BUNDLE_IDENTIFIER = com.twinam.twinam.TwinAmWidget;
```

---

### **Étape 6 : Commit et Push**

```bash
git add .
git commit -m "feat: Enable iOS widget with proper provisioning"
git push origin main
```

---

## 🧪 Tester

Une fois activé, le workflow GitHub Actions devrait :
1. ✅ Installer les deux provisioning profiles (app + widget)
2. ✅ Configurer le Widget Extension automatiquement
3. ✅ Builder l'IPA avec le widget inclus
4. ✅ Uploader vers App Store Connect

Sur TestFlight/App Store, les utilisateurs pourront :
1. Installer l'app
2. Aller sur l'écran d'accueil iOS
3. Appuyer longuement → Widgets
4. Chercher "Twin'Am"
5. Ajouter le widget (Small ou Medium)

---

## 📝 Notes

- **Android widgets** : Fonctionnent déjà sans configuration supplémentaire
- **iOS widgets** : Nécessitent cette configuration une seule fois
- **App Groups** : Permet le partage de données entre l'app et le widget
- **Minimum iOS** : 14.0+ (requis pour les widgets)

---

## 🆘 Dépannage

### Le build échoue avec "Bundle ID mismatch"
→ Vérifier que le Bundle ID dans le script Python est `com.twinam.twinam.TwinAmWidget`

### "Provisioning profile doesn't support App Groups"
→ Recréer le provisioning profile en s'assurant que App Groups est activé

### Le widget n'apparaît pas dans la liste
→ Vérifier que le Widget Extension est bien inclus dans le build (target dependency)

---

**Pour toute question, consulter :**
- `IOS_WIDGET_CI_CD.md` - Guide complet CI/CD
- `IOS_WIDGET_SETUP.md` - Guide Xcode manuel
