# Twin'Am Website Deployment Guide

## 🌐 Site Web Flutter

Le site web Twin'Am est construit avec Flutter Web et déployé sur Vercel.

### Structure du Projet

```
lib/
├── main.dart           # App mobile principale
├── main_web.dart       # Point d'entrée web
└── screens/
    └── web/
        ├── home_page.dart      # Page d'accueil
        ├── privacy_page.dart   # Privacy Policy
        ├── terms_page.dart     # Terms of Service
        └── support_page.dart   # Support/FAQ
```

### Pages Disponibles

- **/** - Homepage avec features et CTA
- **/privacy** - Privacy Policy
- **/terms** - Terms of Service
- **/support** - Support et FAQ

## 🚀 Déploiement sur Vercel

### Prérequis

1. Compte Vercel (gratuit) : https://vercel.com
2. Git repository connecté à Vercel

### Étapes de Déploiement

#### 1. Connexion à Vercel

```bash
# Installer Vercel CLI (optionnel)
npm install -g vercel

# Se connecter
vercel login
```

#### 2. Configuration du Projet

Le fichier `vercel.json` est déjà configuré avec :
- Build command : `flutter build web --release --target=lib/main_web.dart`
- Output directory : `build/web`
- Rewrites pour SPA routing

#### 3. Déploiement via Dashboard Vercel

1. Va sur https://vercel.com/dashboard
2. Clique sur "Add New Project"
3. Importe ton repo GitHub `kawkumputer/twinam`
4. Configure :
   - **Framework Preset** : Other
   - **Build Command** : `flutter build web --release --target=lib/main_web.dart`
   - **Output Directory** : `build/web`
   - **Install Command** : Laisser vide (Vercel détectera Flutter)

5. Clique sur "Deploy"

#### 4. Configuration du Domaine

1. Dans Vercel Dashboard > Settings > Domains
2. Ajoute `twinam.app`
3. Configure les DNS chez ton registrar :

```
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

### Build Local

Pour tester le site localement :

```bash
# Build web
flutter build web --release --target=lib/main_web.dart

# Servir localement
cd build/web
python -m http.server 8000
# Ou avec Node.js
npx serve
```

Ouvre http://localhost:8000

### Build de Développement

Pour tester avec hot reload :

```bash
flutter run -d chrome --target=lib/main_web.dart
```

## 📝 Contenu du Site

### Homepage
- Hero section avec description
- 6 features cards
- CTA avec boutons App Store / Google Play
- Footer avec liens

### Privacy Policy
- Collecte de données (local only)
- Utilisation des données
- Notifications
- Droits des utilisateurs
- Contact

### Terms of Service
- Conditions d'utilisation
- Responsabilités
- Propriété intellectuelle
- Limitations de responsabilité

### Support
- Contact email : contact@twinam.app
- FAQ avec 9 questions courantes

## 🎨 Design

- **Couleurs** :
  - Bleu principal : `#2196F3`
  - Orange : `#FF9800`
  - Vert : `#4CAF50`
  - Rouge : `#FF7043`

- **Responsive** :
  - Mobile : < 768px
  - Desktop : ≥ 768px

## 🔧 Maintenance

### Mettre à Jour le Contenu

1. Modifie les fichiers dans `lib/screens/web/`
2. Commit et push sur GitHub
3. Vercel redéploie automatiquement

### Ajouter une Nouvelle Page

1. Crée `lib/screens/web/nouvelle_page.dart`
2. Ajoute la route dans `lib/main_web.dart` :

```dart
routes: {
  '/nouvelle-page': (context) => const NouvellePage(),
}
```

3. Build et déploie

## 📊 Analytics (Optionnel)

Pour ajouter Google Analytics :

1. Ajoute dans `web/index.html` avant `</head>` :

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

## 🐛 Troubleshooting

### Build échoue sur Vercel

- Vérifie que Flutter est bien installé dans le build environment
- Vérifie les logs de build dans Vercel Dashboard

### Routing ne fonctionne pas

- Vérifie que `vercel.json` contient les rewrites
- Vérifie que les routes sont bien définies dans `main_web.dart`

### Images ne s'affichent pas

- Place les images dans `web/` ou `assets/`
- Référence-les avec le bon chemin

## 📧 Contact

Email : contact@twinam.app
Website : https://twinam.app
