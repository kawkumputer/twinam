# Twin'Am - App de Suivi d'Habitudes

## 🎯 Concept

Twin'Am est une application mobile de suivi d'habitudes et de compteurs personnels, conçue pour vous aider à atteindre vos objectifs quotidiens de manière simple et motivante. Le nom "Twin'Am" symbolise le jumeau de votre ambition - votre compagnon personnel dans la poursuite de vos objectifs.

---

## 🌟 Fonctionnalités Principales

### 📊 **Tableau de Bord Intuitif**
- Vue d'ensemble de tous vos compteurs et habitudes
- Statistiques en temps réel (totaux du jour, streaks actifs)
- Indicateurs visuels de progression avec badges
- Design épuré avec thème sombre/clair adaptatif

### 🔢 **Compteurs Personnalisables**
- Créez des compteurs illimités pour n'importe quelle habitude
- Personnalisation complète : nom, emoji, couleur, et objectif
- Types d'objectifs flexibles :
  - **Atteindre** : Ex: Boire 3L d'eau par jour
  - **Maintenir sous** : Ex: Pas plus de 2h d'écrans
- Incrémentation configurable (pas de 1, 5, 10, etc.)

### 🎯 **Système d'Objectifs Intelligents**
- Définissez des objectifs quotidiens/hebdomadaires
- Barres de progression visuelles en temps réel
- Badges de progression motivants :
  - ✅ Checkmark vert quand l'objectif est atteint
  - 📊 Badge cyan avec pourcentage en cours
- Calcul automatique des streaks (jours consécutifs)

### 🏆 **Gamification & Récompenses**
- Système de XP basé sur votre activité
- Niveaux évolutifs avec barres d'expérience
- Plus de 20 achievements à débloquer :
  - Premiers pas, streaks, totaux, milestones
  - Badges thématiques (eau, sport, productivité, etc.)
- Tableau des achievements avec statistiques détaillées

### 📈 **Statistiques Avancées**
- Graphiques d'évolution sur 30 jours
- Heatmap d'activité quotidienne
- Analyse des tendances et patterns
- Statistiques détaillées par compteur :
  - Total cumulé, moyenne journalière
  - Meilleur jour, streak actuel et record
  - Progression vers l'objectif

### 🔔 **Rappels Intelligents**
- Notifications quotidiennes personnalisables
- Heure de rappel configurable par compteur
- Système robuste avec permissions Android complètes
- Support des fuseaux horaires automatiques

### 🎨 **Personnalisation Complète**
- **Thèmes** : Sombre et Clair avec transitions fluides
- **Palette Twin'Am** : Inspirée du logo (bleu twin, green twin, cyan sparkles)
- **Interface** : Design Material 3 moderne et responsive
- **Adaptative** : Barre de statut intelligente selon le thème

### 💾 **Sauvegarde & Persistance**
- Stockage local sécurisé avec Hive
- Sauvegarde automatique de toutes vos données
- Export/import des données (future version)
- Historique complet des entrées avec timestamps

---

## 🎮 Expérience Utilisateur

### **Flow Principal**
1. **Dashboard** → Vue d'ensemble et accès rapide
2. **Compteur** → Vue détaillée avec stats et progression
3. **Création** → Assistant simple pour nouveaux compteurs
4. **Stats** → Graphiques et analyses détaillées
5. **Achievements** → Collection et progression
6. **Settings** → Personnalisation et préférences

### **Interactions**
- **Quick Tap** : Bouton flottant pour incrémenter rapidement
- **Long Press** : Menu contextuel sur chaque carte
- **Swipe** : Navigation fluide entre les écrans
- **Haptics** : Retour tactile pour chaque action

### **Motivation**
- Feedback visuel immédiat
- Célébrations des milestones
- Streaks pour encourager la régularité
- Achievements pour reconnaître les efforts

---

## 🔧 Architecture Technique

### **Stack Technologique**
- **Framework** : Flutter 3.x
- **Language** : Dart
- **State Management** : Provider pattern
- **Storage** : Hive (base de données locale NoSQL)
- **Notifications** : flutter_local_notifications
- **Charts** : fl_chart pour les graphiques
- **Theming** : Material 3 avec palette personnalisée

### **Structure Modulaire**
```
lib/
├── providers/          # State management
├── models/            # Data models
├── screens/           # UI screens
├── widgets/           # Reusable components
├── services/          # Business logic
├── theme/             # App theming
└── l10n/              # Internationalization
```

### **Performance**
- Architecture reactive avec Provider
- Lazy loading des données
- Optimisation des rebuilds
- Support des dark mode transitions

---

## 🌍 Internationalisation

Support multilingue prêt :
- 🇫🇷 Français (par défaut)
- 🇬🇧 Anglais
- 🇪🇸 Espagnol
- 🇩🇪 Allemand

---

## 🔮 Fonctionnalités Futures

### **Prochaines Versions**
- **Cloud Sync** : Synchronisation multi-appareils
- **Teams** : Compteurs partagés en famille/team
- **Widgets** : Widgets home screen Android/iOS
- **Apple Watch** : Complication watchOS
- **Analytics** : Rapports PDF mensuels
- **Social** : Partage d'achievements

### **Idées en Exploration**
- IA pour prédiction d'habitudes
- Intégration santé (Apple Health/Google Fit)
- Thèmes saisonniers
- Sons et vibrations personnalisés
- Mode focus/Pomodoro intégré

---

## 📱 Cible Utilisateur

**Pour qui ?**
- 🎯 Personnes voulant suivre des habitudes simples
- 💪 Sportifs tracking progression
- 💼 Productivité et objectifs professionnels
- 💊 Santé et bien-être quotidien
- 📚 Éducation et apprentissage

**Pourquoi Twin'Am ?**
- ✅ Simple mais puissant
- ✅ Visuel et motivant
- ✅ Personnalisable à l'extrême
- ✅ Respectueux de la vie privée (100% local)
- ✅ Gratuit et sans publicités

---

## 🎯 Vision

Twin'Am n'est pas juste une app de comptage, c'est votre partenaire personnel dans l'accomplissement de vos ambitions. En combinant design élégant, gamification intelligente et puissance technique, nous rendons le suivi d'habitudes non seulement efficace, mais surtout enjoyable.

**Votre ambition, notre jumeau.** 🌟
