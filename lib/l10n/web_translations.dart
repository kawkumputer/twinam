class WebL10n {
  final String locale;
  WebL10n(this.locale);

  String t(String key) => _t[locale]?[key] ?? _t['en']?[key] ?? key;

  static const _t = {
    'en': _en,
    'fr': _fr,
    'ar': _ar,
    'es': _es,
    'de': _de,
  };

  // ═══════════════════════════════════════════════════════════════
  // ENGLISH
  // ═══════════════════════════════════════════════════════════════
  static const _en = {
    // Navigation
    'navPrivacy': 'Privacy',
    'navTerms': 'Terms',
    'navSupport': 'Support',
    'backHome': 'Back to Home',
    'copyright': "© 2026 Twin'Am. All rights reserved.",
    'privacyPolicy': 'Privacy Policy',
    'termsOfService': 'Terms of Service',

    // Home - Hero
    'heroTitle1': 'Your digital companion for',
    'heroTitle2': 'building better habits',
    'heroSub': "With Twin'Am, your personal Twin accompanies you every day to reach your goals and boost your productivity.",

    // Home - Twin Avatars
    'meetTwin': 'Meet your Twin',
    'meetTwinSub': 'Your companion who evolves with you',
    'twinHappy': 'Proud of you! 🌟',
    'twinHappyDesc': 'When you reach your goals',
    'twinNeutral': 'Keep going! 💪',
    'twinNeutralDesc': 'When you make progress',
    'twinSad': 'You can do better! 🔥',
    'twinSadDesc': 'When you need motivation',

    // Home - Features
    'features': 'Features',
    'feat1Title': 'Your Personal Twin',
    'feat1Desc': 'A digital companion that encourages and motivates you every day',
    'feat2Title': 'Habit Tracking',
    'feat2Desc': 'Create custom counters to track your daily habits',
    'feat3Title': 'Task Management',
    'feat3Desc': 'Organize your tasks with priorities and deadlines',
    'feat4Title': 'Statistics',
    'feat4Desc': 'Visualize your progress with graphs and detailed stats',
    'feat5Title': 'Gamification',
    'feat5Desc': 'Earn XP, level up and unlock achievements',
    'feat6Title': 'Smart Reminders',
    'feat6Desc': 'Get personalized notifications to stay on track',

    // Home - CTA
    'ctaTitle': 'Ready to transform your habits?',
    'ctaSub': "Download Twin'Am for free and start your journey towards a better version of yourself.",

    // Home - Donate
    'donateTitle': "💝 Support Twin'Am",
    'donateSub': "Help us keep Twin'Am free for everyone",

    // ── Privacy Page ──
    'privacyTitle': 'Privacy Policy',
    'privacyDate': 'Last updated: April 16, 2026',
    'privacyIntroTitle': 'Introduction',
    'privacyIntroContent': "Twin'Am mobile application (\"Twin'Am\", \"we\", \"our\", or \"us\") developed and published by Hamath Kane is committed to protecting your privacy. This Privacy Policy explains how Twin'Am collects, uses, and safeguards your information when you use our mobile application available on Google Play Store and Apple App Store.",
    'privacyCollectTitle': '1. Information We Collect',
    'privacyCollectContent': "Twin'Am uses both local and cloud storage depending on the feature.\n\n"
        "Stored locally on your device (Hive):\n"
        "• Counter data (names, values, goals, icons)\n"
        "• Task information (titles, descriptions, deadlines, priorities)\n"
        "• Preferences (theme, notifications, XP progress)\n\n"
        "Stored in the cloud (Supabase) when you create an account:\n"
        "• Your profile (username)\n"
        "• Friend list\n"
        "• Challenge data (title, type, progress, participants)\n\n"
        "Using the app without an account keeps all data local only.",
    'privacyUseTitle': '2. How We Use Your Information',
    'privacyUseContent': "Your locally stored data is used to:\n\n"
        "• Provide core app functionality (counters, tasks, statistics)\n"
        "• Personalize your experience with your Twin companion\n"
        "• Send local notifications and reminders\n"
        "• Track your progress and achievements\n"
        "• Save your preferences and settings",
    'privacyStorageTitle': '3. Data Storage and Security',
    'privacyStorageContent': "Twin'Am uses two storage systems:\n\n"
        "Local storage (Hive): Counters, tasks and preferences stay on your device and are never transmitted.\n\n"
        "Cloud storage (Supabase): When you create an account, your profile, friends and challenges are securely stored on Supabase servers (GDPR-compliant infrastructure). We do not:\n"
        "• Share your data with third parties\n"
        "• Sell your personal information\n"
        "• Track your activity outside the app",
    'privacyNotifTitle': '4. Notifications',
    'privacyNotifContent': "Twin'Am uses local notifications to:\n\n"
        "• Remind you about tasks and deadlines\n"
        "• Send motivational messages from your Twin\n"
        "• Notify you of achievements\n\n"
        "These notifications are generated locally on your device. You can disable notifications at any time in your device settings or within the app.",
    'privacyThirdTitle': '5. Third-Party Services',
    'privacyThirdContent': "Twin'Am uses the following third-party services:\n\n"
        "Supabase (authentication & cloud storage): Used for account management, friend list and social challenges. Data is stored on GDPR-compliant servers.\n"
        "Supabase Privacy Policy: https://supabase.com/privacy\n\n"
        "Google AdMob (advertising): Currently disabled. When active, AdMob may collect device identifiers, IP address and ad interaction data for personalized ads. You can opt out in your device settings.\n"
        "AdMob Privacy Policy: https://policies.google.com/privacy",
    'privacyChildrenTitle': "6. Children's Privacy",
    'privacyChildrenContent': "Twin'Am does not knowingly collect information from children under 13. The app is designed for general audiences and does not require age verification.",
    'privacyDeletionTitle': '7. Data Deletion',
    'privacyDeletionContent': "You have complete control over your data:\n\n"
        "• Delete account in-app: Settings > My Account > Delete my account. This permanently removes your profile, friends, challenges and all cloud data from Supabase, as well as all local data associated with challenges.\n"
        "• Delete individual counters or tasks within the app\n"
        "• Uninstall the app to remove all local data\n\n"
        "Account deletion is immediate and irreversible. All Supabase cloud data is deleted at the moment of deletion.",
    'privacyChangesTitle': '8. Changes to This Privacy Policy',
    'privacyChangesContent': "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last updated\" date.",
    'privacyContactTitle': '9. Contact Us',
    'privacyContactContent': "If you have any questions about this Privacy Policy or Twin'Am mobile application, please contact us at:\n\n"
        "Developer: Hamath Kane\n"
        "Application: Twin'Am\n"
        "Email: contact@twinam.app\n"
        "Available on: Google Play Store & Apple App Store",

    // ── Terms Page ──
    'termsTitle': 'Terms of Service',
    'termsDate': 'Last updated: April 16, 2026',
    'termsIntroTitle': 'Introduction',
    'termsIntroContent': "Welcome to Twin'Am. By downloading, installing, or using our mobile application, you agree to be bound by these Terms of Service. Please read them carefully.",
    'termsAcceptTitle': '1. Acceptance of Terms',
    'termsAcceptContent': "By accessing and using Twin'Am, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these Terms of Service, please do not use the app.",
    'termsDescTitle': '2. Description of Service',
    'termsDescContent': "Twin'Am is a productivity and habit-tracking mobile application that provides:\n\n"
        "• Habit tracking with customizable counters\n"
        "• Task management with priorities and deadlines\n"
        "• Personal Twin companion for motivation\n"
        "• Statistics and progress visualization\n"
        "• Achievement system and gamification\n"
        "• Local notifications and reminders\n"
        "• Social challenges with friends (requires account creation)",
    'termsUserTitle': '3. User Responsibilities',
    'termsUserContent': "You agree to:\n\n"
        "• Use the app for lawful purposes only\n"
        "• Not attempt to reverse engineer or modify the app\n"
        "• Not use the app in any way that could damage or impair the service\n"
        "• Maintain the security of your device\n"
        "• Be responsible for all data entered into the app",
    'termsDataTitle': '4. Data Storage',
    'termsDataContent': "Twin'Am uses local storage (Hive) for counters and tasks, and cloud storage (Supabase) for your profile, friends and challenges. You acknowledge that:\n\n"
        "• You are responsible for backing up local data\n"
        "• Cloud data (profile, challenges) is managed by Supabase and subject to their terms\n"
        "• Deleting your account removes all cloud data permanently and irreversibly\n"
        "• Uninstalling the app removes all local data",
    'termsIPTitle': '5. Intellectual Property',
    'termsIPContent': "The Twin'Am app, including its design, features, graphics, and content, is owned by us and protected by copyright and other intellectual property laws. You may not:\n\n"
        "• Copy, modify, or distribute the app\n"
        "• Use our trademarks without permission\n"
        "• Create derivative works based on the app",
    'termsDisclaimerTitle': '6. Disclaimer of Warranties',
    'termsDisclaimerContent': "Twin'Am is provided \"as is\" without warranties of any kind. We do not guarantee that:\n\n"
        "• The app will be error-free or uninterrupted\n"
        "• Defects will be corrected\n"
        "• The app will meet your specific requirements\n\n"
        "You use the app at your own risk.",
    'termsLiabilityTitle': '7. Limitation of Liability',
    'termsLiabilityContent': "To the maximum extent permitted by law, we shall not be liable for any:\n\n"
        "• Indirect, incidental, or consequential damages\n"
        "• Loss of data or profits\n"
        "• Damages arising from your use of the app\n\n"
        "Our total liability shall not exceed the amount you paid for the app (if applicable).",
    'termsUpdatesTitle': '8. Updates and Modifications',
    'termsUpdatesContent': "We reserve the right to:\n\n"
        "• Modify or discontinue the app at any time\n"
        "• Update these Terms of Service\n"
        "• Add or remove features\n\n"
        "Continued use of the app after changes constitutes acceptance of the new terms.",
    'termsTermTitle': '9. Termination',
    'termsTermContent': "You may stop using the app at any time by uninstalling it from your device. We reserve the right to terminate or suspend access to the app for violations of these terms.",
    'termsLawTitle': '10. Governing Law',
    'termsLawContent': "These Terms of Service shall be governed by and construed in accordance with the laws of France, without regard to its conflict of law provisions.",
    'termsContactTitle': '11. Contact Information',
    'termsContactContent': "For questions about these Terms of Service, please contact us at:\n\nEmail: contact@twinam.app",

    // ── Support Page ──
    'supportTitle': 'Support',
    'supportSub': "We're here to help you",
    'contactTitle': 'Contact Us',
    'contactSub': 'A question? A problem? A suggestion?',
    'faqTitle': 'Frequently Asked Questions',
    'faq1Q': 'How to create a new counter?',
    'faq1A': 'Tap the "+" button at the bottom right of the Dashboard, then fill in your counter information (name, goal, icon, etc.).',
    'faq2Q': 'How to set a daily goal?',
    'faq2A': 'When creating or editing a counter, enable the "Goal" option and set the number you want to reach each day.',
    'faq3Q': 'How to add a task?',
    'faq3A': 'Click the task icon in the Dashboard header, then tap "+" to create a new task with a title, description, deadline and priority.',
    'faq4Q': 'Is my data synced to the cloud?',
    'faq4A': 'Counters and tasks are stored locally on your device only. However, if you create an account, your profile, friends and challenges are synced to the cloud via Supabase — this is required for social features. You can use the app without an account to keep everything local.',
    'faq5Q': 'How to disable notifications?',
    'faq5A': 'Go to Settings > Notifications and disable the notifications you don\'t want. You can also manage notifications in your device settings.',
    'faq6Q': 'How to change the app language?',
    'faq6A': 'Go to Settings > Language and select your preferred language. Twin\'Am supports English, French, Arabic, Spanish and German.',
    'faq7Q': 'What happens if I uninstall the app or delete my account?',
    'faq7A': 'Uninstalling removes local data (counters, tasks). To delete your profile and all cloud data (friends, challenges), use Settings > My Account > Delete my account. This action is immediate and irreversible.',
    'faq8Q': 'How does the Twin system work?',
    'faq8A': 'Your Twin is a virtual companion that reacts to your progress. It\'s happy when you reach your goals, neutral when you make efforts, and sad when you need motivation. It sends personalized messages to encourage you.',
    'faq9Q': 'How to earn XP and level up?',
    'faq9A': 'You earn XP by reaching daily goals, completing tasks and maintaining streaks. The more consistent you are, the faster you level up!',
    'faq10Q': 'How do social challenges work?',
    'faq10A': 'Create an account, add friends, then go to the Challenges tab to send a challenge. Once your opponent accepts, both of you track the same habit with linked counters. You can follow each other\'s progress in real time.',
    'faq11Q': 'How do I delete my account?',
    'faq11A': 'Go to Settings > My Account > Delete my account and confirm. All your data (profile, friends, challenges) is permanently deleted from our servers. Local counters and tasks remain until you uninstall the app.',

    'feat7Title': 'Social Challenges',
    'feat7Desc': 'Challenge your friends to habit duels and track each other\'s progress in real time',
  };

  // ═══════════════════════════════════════════════════════════════
  // FRENCH
  // ═══════════════════════════════════════════════════════════════
  static const _fr = {
    // Navigation
    'navPrivacy': 'Confidentialité',
    'navTerms': 'Conditions',
    'navSupport': 'Support',
    'backHome': "Retour à l'accueil",
    'copyright': "© 2026 Twin'Am. Tous droits réservés.",
    'privacyPolicy': 'Politique de confidentialité',
    'termsOfService': "Conditions d'utilisation",

    // Home - Hero
    'heroTitle1': 'Ton compagnon digital pour',
    'heroTitle2': 'construire de meilleures habitudes',
    'heroSub': "Avec Twin'Am, ton Twin personnel t'accompagne chaque jour pour atteindre tes objectifs et booster ta productivité.",

    // Home - Twin Avatars
    'meetTwin': 'Rencontre ton Twin',
    'meetTwinSub': 'Ton compagnon qui évolue avec toi',
    'twinHappy': 'Fier de toi ! 🌟',
    'twinHappyDesc': 'Quand tu atteins tes objectifs',
    'twinNeutral': 'Continue ! 💪',
    'twinNeutralDesc': 'Quand tu fais des progrès',
    'twinSad': 'Tu peux mieux faire ! 🔥',
    'twinSadDesc': 'Quand tu as besoin de motivation',

    // Home - Features
    'features': 'Fonctionnalités',
    'feat1Title': 'Ton Twin Personnel',
    'feat1Desc': "Un compagnon digital qui t'encourage et te motive chaque jour",
    'feat2Title': "Suivi d'Habitudes",
    'feat2Desc': 'Crée des compteurs personnalisés pour suivre tes habitudes quotidiennes',
    'feat3Title': 'Gestion de Tâches',
    'feat3Desc': 'Organise tes tâches avec des priorités et des échéances',
    'feat4Title': 'Statistiques',
    'feat4Desc': 'Visualise tes progrès avec des graphiques et des stats détaillées',
    'feat5Title': 'Gamification',
    'feat5Desc': "Gagne de l'XP, monte de niveau et débloque des achievements",
    'feat6Title': 'Rappels Intelligents',
    'feat6Desc': 'Reçois des notifications personnalisées pour rester sur la bonne voie',

    // Home - CTA
    'ctaTitle': 'Prêt à transformer tes habitudes ?',
    'ctaSub': "Télécharge Twin'Am gratuitement et commence ton voyage vers une meilleure version de toi-même.",

    // Home - Donate
    'donateTitle': "💝 Soutenir Twin'Am",
    'donateSub': "Aide-nous à garder Twin'Am gratuit pour tous",

    // ── Privacy Page ──
    'privacyTitle': 'Politique de Confidentialité',
    'privacyDate': 'Dernière mise à jour : 16 avril 2026',
    'privacyIntroTitle': 'Introduction',
    'privacyIntroContent': "L'application mobile Twin'Am (\"Twin'Am\", \"nous\", \"notre\") développée et publiée par Hamath Kane s'engage à protéger votre vie privée. Cette Politique de Confidentialité explique comment Twin'Am collecte, utilise et protège vos informations lorsque vous utilisez notre application mobile disponible sur Google Play Store et Apple App Store.",
    'privacyCollectTitle': '1. Informations collectées',
    'privacyCollectContent': "Twin'Am combine stockage local et cloud selon les fonctionnalités.\n\n"
        "Stocké localement sur votre appareil (Hive) :\n"
        "• Données des compteurs (noms, valeurs, objectifs, icônes)\n"
        "• Informations des tâches (titres, descriptions, échéances, priorités)\n"
        "• Préférences (thème, notifications, progression XP)\n\n"
        "Stocké dans le cloud (Supabase) si vous créez un compte :\n"
        "• Votre profil (nom d'utilisateur)\n"
        "• Liste d'amis\n"
        "• Données des défis (titre, type, progression, participants)\n\n"
        "Utiliser l'application sans compte conserve toutes les données en local uniquement.",
    'privacyUseTitle': '2. Utilisation de vos informations',
    'privacyUseContent': "Vos données stockées localement sont utilisées pour :\n\n"
        "• Fournir les fonctionnalités principales (compteurs, tâches, statistiques)\n"
        "• Personnaliser votre expérience avec votre compagnon Twin\n"
        "• Envoyer des notifications et rappels locaux\n"
        "• Suivre vos progrès et achievements\n"
        "• Sauvegarder vos préférences et paramètres",
    'privacyStorageTitle': '3. Stockage et sécurité des données',
    'privacyStorageContent': "Twin'Am utilise deux systèmes de stockage :\n\n"
        "Stockage local (Hive) : compteurs, tâches et préférences restent sur votre appareil et ne sont jamais transmis.\n\n"
        "Stockage cloud (Supabase) : si vous créez un compte, votre profil, vos amis et vos défis sont stockés sur les serveurs Supabase (infrastructure conforme RGPD). Nous ne :\n"
        "• Partageons pas vos données avec des tiers\n"
        "• Vendons pas vos informations personnelles\n"
        "• Suivons pas votre activité en dehors de l'application",
    'privacyNotifTitle': '4. Notifications',
    'privacyNotifContent': "Twin'Am utilise des notifications locales pour :\n\n"
        "• Vous rappeler vos tâches et échéances\n"
        "• Envoyer des messages motivants de votre Twin\n"
        "• Vous notifier de vos achievements\n\n"
        "Ces notifications sont générées localement sur votre appareil. Vous pouvez désactiver les notifications à tout moment dans les paramètres de votre appareil ou dans l'application.",
    'privacyThirdTitle': '5. Services tiers',
    'privacyThirdContent': "Twin'Am utilise les services tiers suivants :\n\n"
        "Supabase (authentification et stockage cloud) : utilisé pour la gestion de compte, la liste d'amis et les défis sociaux. Les données sont stockées sur des serveurs conformes au RGPD.\n"
        "Politique de confidentialité Supabase : https://supabase.com/privacy\n\n"
        "Google AdMob (publicité) : actuellement désactivé. Lorsqu'actif, AdMob peut collecter des identifiants d'appareil, l'adresse IP et des données d'interaction publicitaire. Vous pouvez désactiver les publicités personnalisées dans les paramètres de votre appareil.\n"
        "Politique de confidentialité AdMob : https://policies.google.com/privacy",
    'privacyChildrenTitle': '6. Confidentialité des enfants',
    'privacyChildrenContent': "Twin'Am ne collecte pas sciemment d'informations auprès d'enfants de moins de 13 ans. L'application est conçue pour un public général et ne nécessite pas de vérification d'âge.",
    'privacyDeletionTitle': '7. Suppression des données',
    'privacyDeletionContent': "Vous avez un contrôle total sur vos données :\n\n"
        "• Supprimer le compte dans l'app : Paramètres > Mon compte > Supprimer mon compte. Cela supprime définitivement votre profil, vos amis, vos défis et toutes les données cloud Supabase, ainsi que les données locales liées aux défis.\n"
        "• Supprimer des compteurs ou tâches individuellement dans l'application\n"
        "• Désinstaller l'application pour supprimer toutes les données locales\n\n"
        "La suppression du compte est immédiate et irréversible. Toutes les données Supabase sont supprimées au moment de la demande.",
    'privacyChangesTitle': '8. Modifications de cette politique',
    'privacyChangesContent': "Nous pouvons mettre à jour cette Politique de Confidentialité de temps en temps. Nous vous informerons de tout changement en publiant la nouvelle politique sur cette page et en mettant à jour la date de \"Dernière mise à jour\".",
    'privacyContactTitle': '9. Nous contacter',
    'privacyContactContent': "Si vous avez des questions sur cette Politique de Confidentialité ou l'application mobile Twin'Am, veuillez nous contacter :\n\n"
        "Développeur : Hamath Kane\n"
        "Application : Twin'Am\n"
        "Email : contact@twinam.app\n"
        "Disponible sur : Google Play Store et Apple App Store",

    // ── Terms Page ──
    'termsTitle': "Conditions d'Utilisation",
    'termsDate': 'Dernière mise à jour : 16 avril 2026',
    'termsIntroTitle': 'Introduction',
    'termsIntroContent': "Bienvenue sur Twin'Am. En téléchargeant, installant ou utilisant notre application mobile, vous acceptez d'être lié par ces Conditions d'Utilisation. Veuillez les lire attentivement.",
    'termsAcceptTitle': "1. Acceptation des conditions",
    'termsAcceptContent': "En accédant et utilisant Twin'Am, vous acceptez d'être lié par les termes et dispositions de cet accord. Si vous n'acceptez pas ces Conditions d'Utilisation, veuillez ne pas utiliser l'application.",
    'termsDescTitle': '2. Description du service',
    'termsDescContent': "Twin'Am est une application mobile de productivité et de suivi d'habitudes qui fournit :\n\n"
        "• Suivi d'habitudes avec des compteurs personnalisables\n"
        "• Gestion de tâches avec priorités et échéances\n"
        "• Compagnon Twin personnel pour la motivation\n"
        "• Statistiques et visualisation des progrès\n"
        "• Système d'achievements et gamification\n"
        "• Notifications et rappels locaux\n"
        "• Défis sociaux avec des amis (nécessite la création d'un compte)",
    'termsUserTitle': "3. Responsabilités de l'utilisateur",
    'termsUserContent': "Vous acceptez de :\n\n"
        "• Utiliser l'application uniquement à des fins légales\n"
        "• Ne pas tenter de rétro-ingénierie ou de modifier l'application\n"
        "• Ne pas utiliser l'application d'une manière pouvant endommager le service\n"
        "• Maintenir la sécurité de votre appareil\n"
        "• Être responsable de toutes les données saisies dans l'application",
    'termsDataTitle': '4. Stockage des données',
    'termsDataContent': "Twin'Am utilise le stockage local (Hive) pour les compteurs et tâches, et le cloud (Supabase) pour le profil, les amis et les défis. Vous reconnaissez que :\n\n"
        "• Vous êtes responsable de la sauvegarde des données locales\n"
        "• Les données cloud (profil, défis) sont gérées par Supabase et soumises à leurs conditions\n"
        "• La suppression du compte efface définitivement et irréversiblement toutes les données cloud\n"
        "• La désinstallation de l'application supprime toutes les données locales",
    'termsIPTitle': '5. Propriété intellectuelle',
    'termsIPContent': "L'application Twin'Am, y compris son design, ses fonctionnalités, ses graphiques et son contenu, est notre propriété et est protégée par le droit d'auteur et d'autres lois sur la propriété intellectuelle. Vous ne pouvez pas :\n\n"
        "• Copier, modifier ou distribuer l'application\n"
        "• Utiliser nos marques sans autorisation\n"
        "• Créer des œuvres dérivées basées sur l'application",
    'termsDisclaimerTitle': '6. Exclusion de garanties',
    'termsDisclaimerContent': "Twin'Am est fourni \"tel quel\" sans garantie d'aucune sorte. Nous ne garantissons pas que :\n\n"
        "• L'application sera sans erreur ou ininterrompue\n"
        "• Les défauts seront corrigés\n"
        "• L'application répondra à vos exigences spécifiques\n\n"
        "Vous utilisez l'application à vos propres risques.",
    'termsLiabilityTitle': '7. Limitation de responsabilité',
    'termsLiabilityContent': "Dans la mesure maximale permise par la loi, nous ne serons pas responsables de :\n\n"
        "• Dommages indirects, accessoires ou consécutifs\n"
        "• Perte de données ou de profits\n"
        "• Dommages résultant de votre utilisation de l'application\n\n"
        "Notre responsabilité totale ne dépassera pas le montant que vous avez payé pour l'application (le cas échéant).",
    'termsUpdatesTitle': '8. Mises à jour et modifications',
    'termsUpdatesContent': "Nous nous réservons le droit de :\n\n"
        "• Modifier ou interrompre l'application à tout moment\n"
        "• Mettre à jour ces Conditions d'Utilisation\n"
        "• Ajouter ou supprimer des fonctionnalités\n\n"
        "L'utilisation continue de l'application après les modifications constitue l'acceptation des nouvelles conditions.",
    'termsTermTitle': '9. Résiliation',
    'termsTermContent': "Vous pouvez arrêter d'utiliser l'application à tout moment en la désinstallant de votre appareil. Nous nous réservons le droit de résilier ou suspendre l'accès à l'application en cas de violation de ces conditions.",
    'termsLawTitle': '10. Droit applicable',
    'termsLawContent': "Ces Conditions d'Utilisation seront régies et interprétées conformément aux lois françaises, sans tenir compte de ses dispositions en matière de conflit de lois.",
    'termsContactTitle': '11. Contact',
    'termsContactContent': "Pour toute question concernant ces Conditions d'Utilisation, veuillez nous contacter :\n\nEmail : contact@twinam.app",

    // ── Support Page ──
    'supportTitle': 'Support',
    'supportSub': "Nous sommes là pour t'aider",
    'contactTitle': 'Contacte-nous',
    'contactSub': 'Une question ? Un problème ? Une suggestion ?',
    'faqTitle': 'Questions Fréquentes',
    'faq1Q': 'Comment créer un nouveau compteur ?',
    'faq1A': "Appuie sur le bouton \"+\" en bas à droite du Dashboard, puis remplis les informations de ton compteur (nom, objectif, icône, etc.).",
    'faq2Q': 'Comment définir un objectif quotidien ?',
    'faq2A': "Lors de la création ou modification d'un compteur, active l'option \"Objectif\" et définis le nombre que tu souhaites atteindre chaque jour.",
    'faq3Q': 'Comment ajouter une tâche ?',
    'faq3A': "Clique sur l'icône de tâches dans le header du Dashboard, puis sur le bouton \"+\" pour créer une nouvelle tâche avec un titre, une description, une échéance et une priorité.",
    'faq4Q': 'Mes données sont-elles synchronisées dans le cloud ?',
    'faq4A': "Les compteurs et tâches sont uniquement stockés localement. En revanche, si tu crées un compte, ton profil, tes amis et tes défis sont synchronisés via Supabase — nécessaire pour les fonctionnalités sociales. Tu peux utiliser l'app sans compte pour garder tout en local.",
    'faq5Q': 'Comment désactiver les notifications ?',
    'faq5A': "Va dans Paramètres > Notifications et désactive les notifications que tu ne souhaites pas recevoir. Tu peux aussi gérer les notifications dans les paramètres de ton appareil.",
    'faq6Q': "Comment changer la langue de l'app ?",
    'faq6A': "Va dans Paramètres > Langue et sélectionne ta langue préférée. Twin'Am prend en charge l'anglais, le français, l'arabe, l'espagnol et l'allemand.",
    'faq7Q': "Que se passe-t-il si je désinstalle l'app ou supprime mon compte ?",
    'faq7A': "La désinstallation supprime les données locales (compteurs, tâches). Pour supprimer ton profil et toutes les données cloud (amis, défis), utilise Paramètres > Mon compte > Supprimer mon compte. Cette action est immédiate et irréversible.",
    'faq8Q': 'Comment fonctionne le système de Twin ?',
    'faq8A': "Ton Twin est un compagnon virtuel qui réagit à tes progrès. Il est heureux quand tu atteins tes objectifs, neutre quand tu fais des efforts, et triste quand tu as besoin de motivation. Il t'envoie des messages personnalisés pour t'encourager.",
    'faq9Q': "Comment gagner de l'XP et monter de niveau ?",
    'faq9A': "Tu gagnes de l'XP en atteignant tes objectifs quotidiens, en complétant des tâches et en maintenant des séries (streaks). Plus tu es régulier, plus tu montes de niveaux rapidement !",
    'faq10Q': 'Comment fonctionnent les défis sociaux ?',
    'faq10A': "Crée un compte, ajoute des amis, puis va dans l'onglet Défis pour envoyer un défi. Une fois accepté par ton adversaire, vous suivez la même habitude avec des compteurs liés. Vous pouvez voir la progression de l'autre en temps réel.",
    'faq11Q': 'Comment supprimer mon compte ?',
    'faq11A': "Va dans Paramètres > Mon compte > Supprimer mon compte et confirme. Toutes tes données (profil, amis, défis) sont définitivement supprimées de nos serveurs. Les compteurs et tâches locaux restent jusqu'à la désinstallation de l'app.",

    'feat7Title': 'Défis Sociaux',
    'feat7Desc': "Défie tes amis sur une habitude et suivez mutuellement votre progression en temps réel",
  };

  // ═══════════════════════════════════════════════════════════════
  // ARABIC
  // ═══════════════════════════════════════════════════════════════
  static const _ar = {
    // Navigation
    'navPrivacy': 'الخصوصية',
    'navTerms': 'الشروط',
    'navSupport': 'الدعم',
    'backHome': 'العودة للرئيسية',
    'copyright': "© 2026 Twin'Am. جميع الحقوق محفوظة.",
    'privacyPolicy': 'سياسة الخصوصية',
    'termsOfService': 'شروط الاستخدام',

    // Home - Hero
    'heroTitle1': 'رفيقك الرقمي من أجل',
    'heroTitle2': 'بناء عادات أفضل',
    'heroSub': "مع Twin'Am، توأمك الشخصي يرافقك كل يوم لتحقيق أهدافك وتعزيز إنتاجيتك.",

    // Home - Twin Avatars
    'meetTwin': 'تعرّف على توأمك',
    'meetTwinSub': 'رفيقك الذي يتطور معك',
    'twinHappy': 'فخور بك! 🌟',
    'twinHappyDesc': 'عندما تحقق أهدافك',
    'twinNeutral': 'استمر! 💪',
    'twinNeutralDesc': 'عندما تحرز تقدماً',
    'twinSad': 'يمكنك أن تفعل أفضل! 🔥',
    'twinSadDesc': 'عندما تحتاج للتحفيز',

    // Home - Features
    'features': 'المميزات',
    'feat1Title': 'توأمك الشخصي',
    'feat1Desc': 'رفيق رقمي يشجعك ويحفزك كل يوم',
    'feat2Title': 'تتبع العادات',
    'feat2Desc': 'أنشئ عدادات مخصصة لتتبع عاداتك اليومية',
    'feat3Title': 'إدارة المهام',
    'feat3Desc': 'نظّم مهامك بالأولويات والمواعيد النهائية',
    'feat4Title': 'الإحصائيات',
    'feat4Desc': 'تصوّر تقدمك بالرسوم البيانية والإحصائيات المفصلة',
    'feat5Title': 'التلعيب',
    'feat5Desc': 'اكسب نقاط خبرة، ارتقِ بمستواك وافتح الإنجازات',
    'feat6Title': 'تذكيرات ذكية',
    'feat6Desc': 'احصل على إشعارات مخصصة للبقاء على المسار الصحيح',

    // Home - CTA
    'ctaTitle': 'مستعد لتغيير عاداتك؟',
    'ctaSub': "حمّل Twin'Am مجاناً وابدأ رحلتك نحو نسخة أفضل من نفسك.",

    // Home - Donate
    'donateTitle': "💝 ادعم Twin'Am",
    'donateSub': "ساعدنا في إبقاء Twin'Am مجانياً للجميع",

    // ── Privacy Page ──
    'privacyTitle': 'سياسة الخصوصية',
    'privacyDate': 'آخر تحديث: 16 أبريل 2026',
    'privacyIntroTitle': 'مقدمة',
    'privacyIntroContent': "تطبيق Twin'Am (\"Twin'Am\"، \"نحن\"، \"لنا\") المطور والمنشور من قبل حمث كاني ملتزم بحماية خصوصيتك. توضح سياسة الخصوصية هذه كيف يجمع Twin'Am معلوماتك ويستخدمها ويحميها عند استخدام تطبيقنا المتاح على Google Play Store و Apple App Store.",
    'privacyCollectTitle': '1. المعلومات التي نجمعها',
    'privacyCollectContent': "يجمع Twin'Am بين التخزين المحلي والسحابي حسب الميزة.\n\n"
        "مخزّن محلياً على جهازك (Hive):\n"
        "• بيانات العدادات (الأسماء، القيم، الأهداف، الأيقونات)\n"
        "• معلومات المهام (العناوين، الأوصاف، المواعيد، الأولويات)\n"
        "• التفضيلات (المظهر، الإشعارات، تقدم نقاط الخبرة)\n\n"
        "مخزّن في السحابة (Supabase) عند إنشاء حساب:\n"
        "• ملفك الشخصي (اسم المستخدم)\n"
        "• قائمة الأصدقاء\n"
        "• بيانات التحديات (العنوان، النوع، التقدم، المشاركون)\n\n"
        "استخدام التطبيق بدون حساب يحتفظ بجميع البيانات محلياً فقط.",
    'privacyUseTitle': '2. كيف نستخدم معلوماتك',
    'privacyUseContent': "تُستخدم بياناتك المخزنة محلياً من أجل:\n\n"
        "• توفير الوظائف الأساسية (العدادات، المهام، الإحصائيات)\n"
        "• تخصيص تجربتك مع رفيقك التوأم\n"
        "• إرسال إشعارات وتذكيرات محلية\n"
        "• تتبع تقدمك وإنجازاتك\n"
        "• حفظ تفضيلاتك وإعداداتك",
    'privacyStorageTitle': '3. تخزين البيانات وأمانها',
    'privacyStorageContent': "يستخدم Twin'Am نظامَي تخزين:\n\n"
        "التخزين المحلي (Hive): تبقى العدادات والمهام والتفضيلات على جهازك ولا تُنقل أبداً.\n\n"
        "التخزين السحابي (Supabase): عند إنشاء حساب، يُخزَّن ملفك الشخصي وأصدقاؤك وتحدياتك على خوادم Supabase (بنية تحتية متوافقة مع GDPR). نحن لا:\n"
        "• نشارك بياناتك مع أطراف ثالثة\n"
        "• نبيع معلوماتك الشخصية\n"
        "• نتتبع نشاطك خارج التطبيق",
    'privacyNotifTitle': '4. الإشعارات',
    'privacyNotifContent': "يستخدم Twin'Am إشعارات محلية من أجل:\n\n"
        "• تذكيرك بمهامك ومواعيدك\n"
        "• إرسال رسائل تحفيزية من توأمك\n"
        "• إعلامك بإنجازاتك\n\n"
        "تُنشأ هذه الإشعارات محلياً على جهازك. يمكنك تعطيلها في أي وقت من إعدادات جهازك أو داخل التطبيق.",
    'privacyThirdTitle': '5. خدمات الطرف الثالث',
    'privacyThirdContent': "يستخدم Twin'Am الخدمات التالية:\n\n"
        "Supabase (المصادقة والتخزين السحابي): يُستخدم لإدارة الحسابات وقائمة الأصدقاء والتحديات الاجتماعية. تُخزَّن البيانات على خوادم متوافقة مع GDPR.\n"
        "سياسة خصوصية Supabase: https://supabase.com/privacy\n\n"
        "Google AdMob (الإعلانات): معطّل حالياً. عند تفعيله، قد يجمع AdMob معرّفات الجهاز وعنوان IP وبيانات التفاعل مع الإعلانات. يمكنك إلغاء الإعلانات المخصصة من إعدادات جهازك.\n"
        "سياسة خصوصية AdMob: https://policies.google.com/privacy",
    'privacyChildrenTitle': '6. خصوصية الأطفال',
    'privacyChildrenContent': "لا يجمع Twin'Am معلومات من الأطفال دون 13 عاماً عن قصد. التطبيق مصمم لجمهور عام ولا يتطلب التحقق من العمر.",
    'privacyDeletionTitle': '7. حذف البيانات',
    'privacyDeletionContent': "لديك سيطرة كاملة على بياناتك:\n\n"
        "• حذف الحساب من التطبيق: الإعدادات > حسابي > حذف حسابي. يؤدي ذلك إلى حذف ملفك الشخصي وأصدقائك وتحدياتك وجميع بيانات Supabase السحابية نهائياً، إضافة إلى البيانات المحلية المرتبطة بالتحديات.\n"
        "• حذف عدادات أو مهام فردية داخل التطبيق\n"
        "• إلغاء تثبيت التطبيق لإزالة جميع البيانات المحلية\n\n"
        "حذف الحساب فوري ولا يمكن التراجع عنه. تُحذف جميع بيانات Supabase في لحظة الطلب.",
    'privacyChangesTitle': '8. تغييرات على هذه السياسة',
    'privacyChangesContent': "قد نحدّث سياسة الخصوصية هذه من وقت لآخر. سنُعلمك بأي تغييرات عبر نشر السياسة الجديدة على هذه الصفحة وتحديث تاريخ \"آخر تحديث\".",
    'privacyContactTitle': '9. اتصل بنا',
    'privacyContactContent': "إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه أو تطبيق Twin'Am، يرجى التواصل معنا:\n\n"
        "المطور: حمث كاني\n"
        "التطبيق: Twin'Am\n"
        "البريد: contact@twinam.app\n"
        "متاح على: Google Play Store و Apple App Store",

    // ── Terms Page ──
    'termsTitle': 'شروط الاستخدام',
    'termsDate': 'آخر تحديث: 16 أبريل 2026',
    'termsIntroTitle': 'مقدمة',
    'termsIntroContent': "مرحباً بك في Twin'Am. بتحميل أو تثبيت أو استخدام تطبيقنا، فإنك توافق على الالتزام بشروط الاستخدام هذه. يرجى قراءتها بعناية.",
    'termsAcceptTitle': '1. قبول الشروط',
    'termsAcceptContent': "باستخدام Twin'Am، فإنك تقبل وتوافق على الالتزام بشروط وأحكام هذا الاتفاق. إذا كنت لا توافق على هذه الشروط، يرجى عدم استخدام التطبيق.",
    'termsDescTitle': '2. وصف الخدمة',
    'termsDescContent': "Twin'Am هو تطبيق إنتاجية وتتبع عادات يوفر:\n\n"
        "• تتبع العادات بعدادات قابلة للتخصيص\n"
        "• إدارة المهام بالأولويات والمواعيد\n"
        "• رفيق توأم شخصي للتحفيز\n"
        "• إحصائيات وتصور التقدم\n"
        "• نظام إنجازات وتلعيب\n"
        "• إشعارات وتذكيرات محلية\n"
        "• تحديات اجتماعية مع الأصدقاء (تتطلب إنشاء حساب)",
    'termsUserTitle': '3. مسؤوليات المستخدم',
    'termsUserContent': "أنت توافق على:\n\n"
        "• استخدام التطبيق لأغراض قانونية فقط\n"
        "• عدم محاولة الهندسة العكسية أو تعديل التطبيق\n"
        "• عدم استخدام التطبيق بطريقة قد تضر بالخدمة\n"
        "• الحفاظ على أمان جهازك\n"
        "• تحمل مسؤولية جميع البيانات المدخلة في التطبيق",
    'termsDataTitle': '4. تخزين البيانات',
    'termsDataContent': "يستخدم Twin'Am التخزين المحلي (Hive) للعدادات والمهام، والتخزين السحابي (Supabase) للملف الشخصي والأصدقاء والتحديات. أنت تُقر بأن:\n\n"
        "• أنت مسؤول عن نسخ البيانات المحلية احتياطياً\n"
        "• البيانات السحابية (الملف، التحديات) تُدار بواسطة Supabase وفق شروطهم\n"
        "• حذف الحساب يمسح جميع البيانات السحابية نهائياً ولا يمكن التراجع عنه\n"
        "• إلغاء التثبيت يحذف جميع البيانات المحلية",
    'termsIPTitle': '5. الملكية الفكرية',
    'termsIPContent': "تطبيق Twin'Am، بما في ذلك تصميمه وميزاته ورسوماته ومحتواه، ملكيتنا ومحمي بقوانين حقوق النشر والملكية الفكرية. لا يجوز لك:\n\n"
        "• نسخ أو تعديل أو توزيع التطبيق\n"
        "• استخدام علاماتنا التجارية دون إذن\n"
        "• إنشاء أعمال مشتقة من التطبيق",
    'termsDisclaimerTitle': '6. إخلاء المسؤولية',
    'termsDisclaimerContent': "يُقدم Twin'Am \"كما هو\" دون ضمانات. لا نضمن أن:\n\n"
        "• التطبيق سيكون خالياً من الأخطاء أو متاحاً دائماً\n"
        "• سيتم تصحيح العيوب\n"
        "• التطبيق سيلبي متطلباتك المحددة\n\n"
        "أنت تستخدم التطبيق على مسؤوليتك الخاصة.",
    'termsLiabilityTitle': '7. تحديد المسؤولية',
    'termsLiabilityContent': "إلى أقصى حد يسمح به القانون، لن نكون مسؤولين عن:\n\n"
        "• أضرار غير مباشرة أو عرضية أو تبعية\n"
        "• فقدان البيانات أو الأرباح\n"
        "• أضرار ناتجة عن استخدامك للتطبيق",
    'termsUpdatesTitle': '8. التحديثات والتعديلات',
    'termsUpdatesContent': "نحتفظ بالحق في:\n\n"
        "• تعديل أو إيقاف التطبيق في أي وقت\n"
        "• تحديث شروط الاستخدام\n"
        "• إضافة أو إزالة ميزات\n\n"
        "الاستمرار في استخدام التطبيق بعد التغييرات يعني قبول الشروط الجديدة.",
    'termsTermTitle': '9. الإنهاء',
    'termsTermContent': "يمكنك التوقف عن استخدام التطبيق في أي وقت بإلغاء تثبيته. نحتفظ بالحق في إنهاء أو تعليق الوصول للتطبيق في حالة انتهاك هذه الشروط.",
    'termsLawTitle': '10. القانون الحاكم',
    'termsLawContent': "تخضع شروط الاستخدام هذه للقوانين الفرنسية وتُفسر وفقاً لها.",
    'termsContactTitle': '11. معلومات الاتصال',
    'termsContactContent': "لأي أسئلة حول شروط الاستخدام:\n\nالبريد: contact@twinam.app",

    // ── Support Page ──
    'supportTitle': 'الدعم',
    'supportSub': 'نحن هنا لمساعدتك',
    'contactTitle': 'اتصل بنا',
    'contactSub': 'سؤال؟ مشكلة؟ اقتراح؟',
    'faqTitle': 'الأسئلة الشائعة',
    'faq1Q': 'كيف أنشئ عداداً جديداً؟',
    'faq1A': 'اضغط على زر "+" أسفل يمين الشاشة الرئيسية، ثم أدخل معلومات عدادك (الاسم، الهدف، الأيقونة، إلخ).',
    'faq2Q': 'كيف أحدد هدفاً يومياً؟',
    'faq2A': 'عند إنشاء أو تعديل عداد، فعّل خيار "الهدف" وحدد الرقم الذي تريد الوصول إليه يومياً.',
    'faq3Q': 'كيف أضيف مهمة؟',
    'faq3A': 'اضغط على أيقونة المهام في رأس الشاشة الرئيسية، ثم اضغط "+" لإنشاء مهمة جديدة بعنوان ووصف وموعد وأولوية.',
    'faq4Q': 'هل بياناتي متزامنة مع السحابة؟',
    'faq4A': 'العدادات والمهام مخزنة محلياً فقط. أما إذا أنشأت حساباً، فإن ملفك الشخصي وأصدقاءك وتحدياتك تتزامن عبر Supabase — وهو ضروري للميزات الاجتماعية. يمكنك استخدام التطبيق بدون حساب للاحتفاظ بكل شيء محلياً.',
    'faq5Q': 'كيف أعطّل الإشعارات؟',
    'faq5A': 'اذهب إلى الإعدادات > الإشعارات وعطّل ما لا تريده. يمكنك أيضاً إدارتها من إعدادات جهازك.',
    'faq6Q': 'كيف أغيّر لغة التطبيق؟',
    'faq6A': "اذهب إلى الإعدادات > اللغة واختر لغتك المفضلة. يدعم Twin'Am الإنجليزية والفرنسية والعربية والإسبانية والألمانية.",
    'faq7Q': 'ماذا يحدث إذا حذفت التطبيق أو حسابي؟',
    'faq7A': 'حذف التطبيق يزيل البيانات المحلية (العدادات، المهام). لحذف ملفك الشخصي وجميع البيانات السحابية (الأصدقاء، التحديات)، استخدم الإعدادات > حسابي > حذف حسابي. هذا الإجراء فوري ولا يمكن التراجع عنه.',
    'faq8Q': 'كيف يعمل نظام التوأم؟',
    'faq8A': 'توأمك هو رفيق افتراضي يتفاعل مع تقدمك. يكون سعيداً عند تحقيق أهدافك، محايداً عند بذل الجهد، وحزيناً عندما تحتاج للتحفيز.',
    'faq9Q': 'كيف أكسب نقاط خبرة وأرتقي بمستواي؟',
    'faq9A': 'تكسب نقاط خبرة بتحقيق أهدافك اليومية وإكمال المهام والحفاظ على سلاسل متتالية. كلما كنت أكثر انتظاماً، كلما ارتقيت أسرع!',
    'faq10Q': 'كيف تعمل التحديات الاجتماعية؟',
    'faq10A': 'أنشئ حساباً، أضف أصدقاء، ثم اذهب إلى تبويب التحديات لإرسال تحدٍّ. بعد قبول خصمك، يتتبع كلاكما نفس العادة بعدادات مرتبطة ويمكنكما متابعة تقدم بعضكما في الوقت الفعلي.',
    'faq11Q': 'كيف أحذف حسابي؟',
    'faq11A': 'اذهب إلى الإعدادات > حسابي > حذف حسابي وأكّد. ستُحذف جميع بياناتك (الملف الشخصي، الأصدقاء، التحديات) نهائياً من خوادمنا. تبقى العدادات والمهام المحلية حتى تحذف التطبيق.',

    'feat7Title': 'التحديات الاجتماعية',
    'feat7Desc': 'تحدّى أصدقاءك على عادة وتابعوا تقدم بعضكم في الوقت الفعلي',
  };

  // ═══════════════════════════════════════════════════════════════
  // SPANISH
  // ═══════════════════════════════════════════════════════════════
  static const _es = {
    // Navigation
    'navPrivacy': 'Privacidad',
    'navTerms': 'Términos',
    'navSupport': 'Soporte',
    'backHome': 'Volver al inicio',
    'copyright': "© 2026 Twin'Am. Todos los derechos reservados.",
    'privacyPolicy': 'Política de Privacidad',
    'termsOfService': 'Términos de Servicio',

    // Home - Hero
    'heroTitle1': 'Tu compañero digital para',
    'heroTitle2': 'construir mejores hábitos',
    'heroSub': "Con Twin'Am, tu Twin personal te acompaña cada día para alcanzar tus objetivos y aumentar tu productividad.",

    // Home - Twin Avatars
    'meetTwin': 'Conoce a tu Twin',
    'meetTwinSub': 'Tu compañero que evoluciona contigo',
    'twinHappy': '¡Orgulloso de ti! 🌟',
    'twinHappyDesc': 'Cuando alcanzas tus objetivos',
    'twinNeutral': '¡Sigue así! 💪',
    'twinNeutralDesc': 'Cuando haces progresos',
    'twinSad': '¡Puedes hacerlo mejor! 🔥',
    'twinSadDesc': 'Cuando necesitas motivación',

    // Home - Features
    'features': 'Funcionalidades',
    'feat1Title': 'Tu Twin Personal',
    'feat1Desc': 'Un compañero digital que te anima y motiva cada día',
    'feat2Title': 'Seguimiento de Hábitos',
    'feat2Desc': 'Crea contadores personalizados para seguir tus hábitos diarios',
    'feat3Title': 'Gestión de Tareas',
    'feat3Desc': 'Organiza tus tareas con prioridades y fechas límite',
    'feat4Title': 'Estadísticas',
    'feat4Desc': 'Visualiza tu progreso con gráficos y estadísticas detalladas',
    'feat5Title': 'Gamificación',
    'feat5Desc': 'Gana XP, sube de nivel y desbloquea logros',
    'feat6Title': 'Recordatorios Inteligentes',
    'feat6Desc': 'Recibe notificaciones personalizadas para mantenerte en el camino',

    // Home - CTA
    'ctaTitle': '¿Listo para transformar tus hábitos?',
    'ctaSub': "Descarga Twin'Am gratis y comienza tu viaje hacia una mejor versión de ti mismo.",

    // Home - Donate
    'donateTitle': "💝 Apoya Twin'Am",
    'donateSub': "Ayúdanos a mantener Twin'Am gratis para todos",

    // ── Privacy Page ──
    'privacyTitle': 'Política de Privacidad',
    'privacyDate': 'Última actualización: 16 de abril de 2026',
    'privacyIntroTitle': 'Introducción',
    'privacyIntroContent': "La aplicación móvil Twin'Am (\"Twin'Am\", \"nosotros\", \"nuestro\") desarrollada y publicada por Hamath Kane se compromete a proteger su privacidad. Esta Política de Privacidad explica cómo Twin'Am recopila, usa y protege su información cuando utiliza nuestra aplicación disponible en Google Play Store y Apple App Store.",
    'privacyCollectTitle': '1. Información que recopilamos',
    'privacyCollectContent': "Twin'Am combina almacenamiento local y en la nube según la función.\n\n"
        "Almacenado localmente en su dispositivo (Hive):\n"
        "• Datos de contadores (nombres, valores, objetivos, iconos)\n"
        "• Información de tareas (títulos, descripciones, fechas, prioridades)\n"
        "• Preferencias (tema, notificaciones, progreso XP)\n\n"
        "Almacenado en la nube (Supabase) al crear una cuenta:\n"
        "• Su perfil (nombre de usuario)\n"
        "• Lista de amigos\n"
        "• Datos de desafíos (título, tipo, progreso, participantes)\n\n"
        "Usar la app sin cuenta mantiene todos los datos solo en local.",
    'privacyUseTitle': '2. Cómo usamos su información',
    'privacyUseContent': "Sus datos almacenados localmente se usan para:\n\n"
        "• Proporcionar funcionalidad principal (contadores, tareas, estadísticas)\n"
        "• Personalizar su experiencia con su compañero Twin\n"
        "• Enviar notificaciones y recordatorios locales\n"
        "• Seguir su progreso y logros\n"
        "• Guardar sus preferencias y configuraciones",
    'privacyStorageTitle': '3. Almacenamiento y seguridad',
    'privacyStorageContent': "Twin'Am utiliza dos sistemas de almacenamiento:\n\n"
        "Almacenamiento local (Hive): contadores, tareas y preferencias permanecen en su dispositivo y nunca se transmiten.\n\n"
        "Almacenamiento en la nube (Supabase): al crear una cuenta, su perfil, amigos y desafíos se almacenan en servidores Supabase (infraestructura compatible con GDPR). No:\n"
        "• Compartimos sus datos con terceros\n"
        "• Vendemos su información personal\n"
        "• Rastreamos su actividad fuera de la app",
    'privacyNotifTitle': '4. Notificaciones',
    'privacyNotifContent': "Twin'Am usa notificaciones locales para:\n\n"
        "• Recordarle sus tareas y fechas límite\n"
        "• Enviar mensajes motivacionales de su Twin\n"
        "• Notificarle de sus logros\n\n"
        "Estas notificaciones se generan localmente. Puede desactivarlas en cualquier momento desde la configuración de su dispositivo o dentro de la app.",
    'privacyThirdTitle': '5. Servicios de terceros',
    'privacyThirdContent': "Twin'Am utiliza los siguientes servicios de terceros:\n\n"
        "Supabase (autenticación y almacenamiento en la nube): usado para gestión de cuentas, lista de amigos y desafíos sociales. Los datos se almacenan en servidores compatibles con GDPR.\n"
        "Política de privacidad de Supabase: https://supabase.com/privacy\n\n"
        "Google AdMob (publicidad): actualmente desactivado. Cuando esté activo, AdMob puede recopilar identificadores del dispositivo, dirección IP y datos de interacción con anuncios. Puede optar por no recibir anuncios personalizados en la configuración de su dispositivo.\n"
        "Política de privacidad de AdMob: https://policies.google.com/privacy",
    'privacyChildrenTitle': '6. Privacidad de menores',
    'privacyChildrenContent': "Twin'Am no recopila intencionalmente información de menores de 13 años. La app está diseñada para público general.",
    'privacyDeletionTitle': '7. Eliminación de datos',
    'privacyDeletionContent': "Tiene control total sobre sus datos:\n\n"
        "• Eliminar cuenta en la app: Ajustes > Mi cuenta > Eliminar mi cuenta. Esto elimina permanentemente su perfil, amigos, desafíos y todos los datos en la nube de Supabase, así como los datos locales asociados a desafíos.\n"
        "• Eliminar contadores o tareas individuales dentro de la app\n"
        "• Desinstalar la app para eliminar todos los datos locales\n\n"
        "La eliminación de la cuenta es inmediata e irreversible. Todos los datos de Supabase se eliminan en el momento de la solicitud.",
    'privacyChangesTitle': '8. Cambios en esta política',
    'privacyChangesContent': "Podemos actualizar esta Política de Privacidad periódicamente. Le notificaremos de cualquier cambio publicando la nueva política en esta página.",
    'privacyContactTitle': '9. Contáctenos',
    'privacyContactContent': "Si tiene preguntas sobre esta Política de Privacidad o la aplicación Twin'Am:\n\n"
        "Desarrollador: Hamath Kane\n"
        "Aplicación: Twin'Am\n"
        "Email: contact@twinam.app\n"
        "Disponible en: Google Play Store y Apple App Store",

    // ── Terms Page ──
    'termsTitle': 'Términos de Servicio',
    'termsDate': 'Última actualización: 16 de abril de 2026',
    'termsIntroTitle': 'Introducción',
    'termsIntroContent': "Bienvenido a Twin'Am. Al descargar, instalar o usar nuestra aplicación, acepta estar sujeto a estos Términos de Servicio.",
    'termsAcceptTitle': '1. Aceptación de términos',
    'termsAcceptContent': "Al acceder y usar Twin'Am, acepta estar sujeto a los términos de este acuerdo. Si no está de acuerdo, no use la app.",
    'termsDescTitle': '2. Descripción del servicio',
    'termsDescContent': "Twin'Am es una aplicación de productividad y seguimiento de hábitos que ofrece:\n\n"
        "• Seguimiento de hábitos con contadores personalizables\n"
        "• Gestión de tareas con prioridades y fechas límite\n"
        "• Compañero Twin personal para motivación\n"
        "• Estadísticas y visualización del progreso\n"
        "• Sistema de logros y gamificación\n"
        "• Notificaciones y recordatorios locales\n"
        "• Desafíos sociales con amigos (requiere creación de cuenta)",
    'termsUserTitle': '3. Responsabilidades del usuario',
    'termsUserContent': "Acepta:\n\n"
        "• Usar la app solo para fines legales\n"
        "• No intentar ingeniería inversa o modificar la app\n"
        "• No usar la app de manera que pueda dañar el servicio\n"
        "• Mantener la seguridad de su dispositivo\n"
        "• Ser responsable de todos los datos ingresados",
    'termsDataTitle': '4. Almacenamiento de datos',
    'termsDataContent': "Twin'Am usa almacenamiento local (Hive) para contadores y tareas, y almacenamiento en la nube (Supabase) para perfil, amigos y desafíos. Usted reconoce que:\n\n"
        "• Es responsable de respaldar los datos locales\n"
        "• Los datos en la nube (perfil, desafíos) son gestionados por Supabase sujeto a sus términos\n"
        "• Eliminar la cuenta borra todos los datos en la nube de forma permanente e irreversible\n"
        "• Desinstalar la app elimina todos los datos locales",
    'termsIPTitle': '5. Propiedad intelectual',
    'termsIPContent': "La app Twin'Am es nuestra propiedad y está protegida por leyes de propiedad intelectual. No puede:\n\n"
        "• Copiar, modificar o distribuir la app\n"
        "• Usar nuestras marcas sin permiso\n"
        "• Crear obras derivadas de la app",
    'termsDisclaimerTitle': '6. Descargo de garantías',
    'termsDisclaimerContent': "Twin'Am se proporciona \"tal cual\" sin garantías. No garantizamos que:\n\n"
        "• La app estará libre de errores\n"
        "• Los defectos serán corregidos\n"
        "• La app cumplirá sus requisitos específicos\n\n"
        "Usa la app bajo su propio riesgo.",
    'termsLiabilityTitle': '7. Limitación de responsabilidad',
    'termsLiabilityContent': "En la medida máxima permitida por ley, no seremos responsables por:\n\n"
        "• Daños indirectos, incidentales o consecuentes\n"
        "• Pérdida de datos o ganancias\n"
        "• Daños derivados del uso de la app",
    'termsUpdatesTitle': '8. Actualizaciones y modificaciones',
    'termsUpdatesContent': "Nos reservamos el derecho de:\n\n"
        "• Modificar o descontinuar la app\n"
        "• Actualizar estos Términos\n"
        "• Agregar o eliminar funciones\n\n"
        "El uso continuado implica aceptación de los nuevos términos.",
    'termsTermTitle': '9. Terminación',
    'termsTermContent': "Puede dejar de usar la app desinstalándola. Nos reservamos el derecho de terminar el acceso por violación de estos términos.",
    'termsLawTitle': '10. Ley aplicable',
    'termsLawContent': "Estos Términos se rigen por las leyes de Francia.",
    'termsContactTitle': '11. Contacto',
    'termsContactContent': "Para preguntas sobre estos Términos:\n\nEmail: contact@twinam.app",

    // ── Support Page ──
    'supportTitle': 'Soporte',
    'supportSub': 'Estamos aquí para ayudarte',
    'contactTitle': 'Contáctanos',
    'contactSub': '¿Una pregunta? ¿Un problema? ¿Una sugerencia?',
    'faqTitle': 'Preguntas Frecuentes',
    'faq1Q': '¿Cómo crear un nuevo contador?',
    'faq1A': 'Pulsa el botón "+" en la parte inferior derecha del Dashboard, luego completa la información del contador (nombre, objetivo, icono, etc.).',
    'faq2Q': '¿Cómo establecer un objetivo diario?',
    'faq2A': 'Al crear o editar un contador, activa la opción "Objetivo" y define el número que deseas alcanzar cada día.',
    'faq3Q': '¿Cómo añadir una tarea?',
    'faq3A': 'Pulsa el icono de tareas en el Dashboard, luego "+" para crear una nueva tarea con título, descripción, fecha límite y prioridad.',
    'faq4Q': '¿Mis datos se sincronizan con la nube?',
    'faq4A': 'Los contadores y tareas se almacenan solo localmente. Sin embargo, si creas una cuenta, tu perfil, amigos y desafíos se sincronizan vía Supabase — necesario para las funciones sociales. Puedes usar la app sin cuenta para mantener todo en local.',
    'faq5Q': '¿Cómo desactivar las notificaciones?',
    'faq5A': 'Ve a Ajustes > Notificaciones y desactiva las que no desees. También puedes gestionarlas desde los ajustes de tu dispositivo.',
    'faq6Q': '¿Cómo cambiar el idioma de la app?',
    'faq6A': "Ve a Ajustes > Idioma y selecciona tu preferencia. Twin'Am soporta inglés, francés, árabe, español y alemán.",
    'faq7Q': '¿Qué pasa si desinstalo la app o elimino mi cuenta?',
    'faq7A': 'Desinstalar elimina los datos locales (contadores, tareas). Para eliminar tu perfil y todos los datos en la nube (amigos, desafíos), usa Ajustes > Mi cuenta > Eliminar mi cuenta. Esta acción es inmediata e irreversible.',
    'faq8Q': '¿Cómo funciona el sistema Twin?',
    'faq8A': 'Tu Twin es un compañero virtual que reacciona a tu progreso. Está feliz cuando alcanzas tus objetivos, neutral cuando te esfuerzas y triste cuando necesitas motivación.',
    'faq9Q': '¿Cómo ganar XP y subir de nivel?',
    'faq9A': 'Ganas XP alcanzando objetivos diarios, completando tareas y manteniendo rachas. ¡Cuanto más constante seas, más rápido subes!',
    'faq10Q': '¿Cómo funcionan los desafíos sociales?',
    'faq10A': 'Crea una cuenta, añade amigos y ve a la pestaña Desafíos para enviar un desafío. Una vez aceptado, ambos rastrean el mismo hábito con contadores vinculados y pueden ver el progreso del otro en tiempo real.',
    'faq11Q': '¿Cómo elimino mi cuenta?',
    'faq11A': 'Ve a Ajustes > Mi cuenta > Eliminar mi cuenta y confirma. Todos tus datos (perfil, amigos, desafíos) se eliminan permanentemente de nuestros servidores. Los contadores y tareas locales permanecen hasta que desinstales la app.',

    'feat7Title': 'Desafíos Sociales',
    'feat7Desc': 'Desafía a tus amigos en un hábito y seguiros el progreso mutuamente en tiempo real',
  };

  // ═══════════════════════════════════════════════════════════════
  // GERMAN
  // ═══════════════════════════════════════════════════════════════
  static const _de = {
    // Navigation
    'navPrivacy': 'Datenschutz',
    'navTerms': 'AGB',
    'navSupport': 'Hilfe',
    'backHome': 'Zurück zur Startseite',
    'copyright': "© 2026 Twin'Am. Alle Rechte vorbehalten.",
    'privacyPolicy': 'Datenschutzerklärung',
    'termsOfService': 'Nutzungsbedingungen',

    // Home - Hero
    'heroTitle1': 'Dein digitaler Begleiter für',
    'heroTitle2': 'bessere Gewohnheiten',
    'heroSub': "Mit Twin'Am begleitet dich dein persönlicher Twin jeden Tag, um deine Ziele zu erreichen und deine Produktivität zu steigern.",

    // Home - Twin Avatars
    'meetTwin': 'Triff deinen Twin',
    'meetTwinSub': 'Dein Begleiter, der mit dir wächst',
    'twinHappy': 'Stolz auf dich! 🌟',
    'twinHappyDesc': 'Wenn du deine Ziele erreichst',
    'twinNeutral': 'Weiter so! 💪',
    'twinNeutralDesc': 'Wenn du Fortschritte machst',
    'twinSad': 'Du kannst es besser! 🔥',
    'twinSadDesc': 'Wenn du Motivation brauchst',

    // Home - Features
    'features': 'Funktionen',
    'feat1Title': 'Dein persönlicher Twin',
    'feat1Desc': 'Ein digitaler Begleiter, der dich jeden Tag ermutigt und motiviert',
    'feat2Title': 'Gewohnheits-Tracking',
    'feat2Desc': 'Erstelle individuelle Zähler, um deine täglichen Gewohnheiten zu verfolgen',
    'feat3Title': 'Aufgabenverwaltung',
    'feat3Desc': 'Organisiere deine Aufgaben mit Prioritäten und Fristen',
    'feat4Title': 'Statistiken',
    'feat4Desc': 'Visualisiere deinen Fortschritt mit Grafiken und detaillierten Statistiken',
    'feat5Title': 'Gamification',
    'feat5Desc': 'Verdiene XP, steige auf und schalte Erfolge frei',
    'feat6Title': 'Intelligente Erinnerungen',
    'feat6Desc': 'Erhalte personalisierte Benachrichtigungen, um am Ball zu bleiben',

    // Home - CTA
    'ctaTitle': 'Bereit, deine Gewohnheiten zu verändern?',
    'ctaSub': "Lade Twin'Am kostenlos herunter und beginne deine Reise zu einer besseren Version von dir selbst.",

    // Home - Donate
    'donateTitle': "💝 Twin'Am unterstützen",
    'donateSub': "Hilf uns, Twin'Am für alle kostenlos zu halten",

    // ── Privacy Page ──
    'privacyTitle': 'Datenschutzerklärung',
    'privacyDate': 'Letzte Aktualisierung: 16. April 2026',
    'privacyIntroTitle': 'Einleitung',
    'privacyIntroContent': "Die mobile Anwendung Twin'Am (\"Twin'Am\", \"wir\", \"unser\"), entwickelt und veröffentlicht von Hamath Kane, verpflichtet sich zum Schutz Ihrer Privatsphäre. Diese Datenschutzerklärung erläutert, wie Twin'Am Ihre Informationen sammelt, nutzt und schützt, wenn Sie unsere App im Google Play Store und Apple App Store nutzen.",
    'privacyCollectTitle': '1. Gesammelte Informationen',
    'privacyCollectContent': "Twin'Am kombiniert lokale und Cloud-Speicherung je nach Funktion.\n\n"
        "Lokal auf Ihrem Gerät gespeichert (Hive):\n"
        "• Zählerdaten (Namen, Werte, Ziele, Symbole)\n"
        "• Aufgabeninformationen (Titel, Beschreibungen, Fristen, Prioritäten)\n"
        "• Einstellungen (Design, Benachrichtigungen, XP-Fortschritt)\n\n"
        "In der Cloud gespeichert (Supabase) bei Konto-Erstellung:\n"
        "• Ihr Profil (Benutzername)\n"
        "• Freundesliste\n"
        "• Herausforderungsdaten (Titel, Typ, Fortschritt, Teilnehmer)\n\n"
        "Die App ohne Konto zu nutzen hält alle Daten nur lokal.",
    'privacyUseTitle': '2. Verwendung Ihrer Informationen',
    'privacyUseContent': "Ihre lokal gespeicherten Daten werden verwendet für:\n\n"
        "• Bereitstellung der Kernfunktionen (Zähler, Aufgaben, Statistiken)\n"
        "• Personalisierung Ihrer Erfahrung mit Ihrem Twin-Begleiter\n"
        "• Senden lokaler Benachrichtigungen und Erinnerungen\n"
        "• Verfolgung Ihrer Fortschritte und Erfolge\n"
        "• Speichern Ihrer Einstellungen und Präferenzen",
    'privacyStorageTitle': '3. Datenspeicherung und Sicherheit',
    'privacyStorageContent': "Twin'Am verwendet zwei Speichersysteme:\n\n"
        "Lokaler Speicher (Hive): Zähler, Aufgaben und Einstellungen bleiben auf Ihrem Gerät und werden niemals übertragen.\n\n"
        "Cloud-Speicher (Supabase): Bei Konto-Erstellung werden Ihr Profil, Freunde und Herausforderungen auf Supabase-Servern gespeichert (DSGVO-konforme Infrastruktur). Wir:\n"
        "• Teilen Ihre Daten nicht mit Dritten\n"
        "• Verkaufen Ihre persönlichen Informationen nicht\n"
        "• Verfolgen Ihre Aktivitäten nicht außerhalb der App",
    'privacyNotifTitle': '4. Benachrichtigungen',
    'privacyNotifContent': "Twin'Am nutzt lokale Benachrichtigungen um:\n\n"
        "• Sie an Aufgaben und Fristen zu erinnern\n"
        "• Motivierende Nachrichten von Ihrem Twin zu senden\n"
        "• Sie über Erfolge zu benachrichtigen\n\n"
        "Diese Benachrichtigungen werden lokal erzeugt. Sie können sie jederzeit in den Geräteeinstellungen oder in der App deaktivieren.",
    'privacyThirdTitle': '5. Drittanbieter-Dienste',
    'privacyThirdContent': "Twin'Am verwendet folgende Drittanbieter-Dienste:\n\n"
        "Supabase (Authentifizierung & Cloud-Speicher): Wird für Kontoverwaltung, Freundesliste und soziale Herausforderungen genutzt. Daten werden auf DSGVO-konformen Servern gespeichert.\n"
        "Supabase-Datenschutzrichtlinie: https://supabase.com/privacy\n\n"
        "Google AdMob (Werbung): Derzeit deaktiviert. Bei Aktivierung kann AdMob Gerätekennungen, IP-Adresse und Werbeinteraktionsdaten sammeln. Sie können personalisierte Werbung in Ihren Geräteeinstellungen deaktivieren.\n"
        "AdMob-Datenschutzrichtlinie: https://policies.google.com/privacy",
    'privacyChildrenTitle': '6. Datenschutz für Kinder',
    'privacyChildrenContent': "Twin'Am sammelt wissentlich keine Daten von Kindern unter 13 Jahren. Die App ist für ein allgemeines Publikum konzipiert.",
    'privacyDeletionTitle': '7. Datenlöschung',
    'privacyDeletionContent': "Sie haben volle Kontrolle über Ihre Daten:\n\n"
        "• Konto in der App löschen: Einstellungen > Mein Konto > Konto löschen. Dadurch werden Ihr Profil, Freunde, Herausforderungen und alle Supabase-Cloud-Daten dauerhaft gelöscht, sowie lokale Daten der Herausforderungen.\n"
        "• Einzelne Zähler oder Aufgaben in der App löschen\n"
        "• App deinstallieren, um alle lokalen Daten zu entfernen\n\n"
        "Die Kontolöschung ist sofort und unwiderruflich. Alle Supabase-Daten werden im Moment der Anfrage gelöscht.",
    'privacyChangesTitle': '8. Änderungen dieser Richtlinie',
    'privacyChangesContent': "Wir können diese Datenschutzerklärung gelegentlich aktualisieren. Wir informieren Sie über Änderungen durch Veröffentlichung der neuen Richtlinie auf dieser Seite.",
    'privacyContactTitle': '9. Kontakt',
    'privacyContactContent': "Bei Fragen zu dieser Datenschutzerklärung oder der Twin'Am App:\n\n"
        "Entwickler: Hamath Kane\n"
        "Anwendung: Twin'Am\n"
        "E-Mail: contact@twinam.app\n"
        "Verfügbar auf: Google Play Store und Apple App Store",

    // ── Terms Page ──
    'termsTitle': 'Nutzungsbedingungen',
    'termsDate': 'Letzte Aktualisierung: 16. April 2026',
    'termsIntroTitle': 'Einleitung',
    'termsIntroContent': "Willkommen bei Twin'Am. Durch das Herunterladen, Installieren oder Nutzen unserer App stimmen Sie diesen Nutzungsbedingungen zu.",
    'termsAcceptTitle': '1. Annahme der Bedingungen',
    'termsAcceptContent': "Durch die Nutzung von Twin'Am akzeptieren Sie diese Bedingungen. Wenn Sie nicht einverstanden sind, nutzen Sie die App bitte nicht.",
    'termsDescTitle': '2. Beschreibung des Dienstes',
    'termsDescContent': "Twin'Am ist eine Produktivitäts- und Gewohnheits-Tracking-App, die bietet:\n\n"
        "• Gewohnheits-Tracking mit anpassbaren Zählern\n"
        "• Aufgabenverwaltung mit Prioritäten und Fristen\n"
        "• Persönlicher Twin-Begleiter für Motivation\n"
        "• Statistiken und Fortschrittsvisualisierung\n"
        "• Erfolgs-System und Gamification\n"
        "• Lokale Benachrichtigungen und Erinnerungen\n"
        "• Soziale Herausforderungen mit Freunden (erfordert Konto-Erstellung)",
    'termsUserTitle': '3. Benutzerverantwortung',
    'termsUserContent': "Sie stimmen zu:\n\n"
        "• Die App nur für legale Zwecke zu nutzen\n"
        "• Kein Reverse Engineering oder Modifikation der App\n"
        "• Die App nicht so zu nutzen, dass der Dienst geschädigt wird\n"
        "• Die Sicherheit Ihres Geräts zu gewährleisten\n"
        "• Für alle eingegebenen Daten verantwortlich zu sein",
    'termsDataTitle': '4. Datenspeicherung',
    'termsDataContent': "Twin'Am nutzt lokalen Speicher (Hive) für Zähler und Aufgaben, und Cloud-Speicher (Supabase) für Profil, Freunde und Herausforderungen. Sie erkennen an:\n\n"
        "• Sie sind für die Sicherung lokaler Daten verantwortlich\n"
        "• Cloud-Daten (Profil, Herausforderungen) werden von Supabase gemäß deren Bedingungen verwaltet\n"
        "• Kontolöschung entfernt alle Cloud-Daten dauerhaft und unwiderruflich\n"
        "• Deinstallation löscht alle lokalen Daten",
    'termsIPTitle': '5. Geistiges Eigentum',
    'termsIPContent': "Die Twin'Am App ist unser Eigentum und durch Urheberrecht geschützt. Sie dürfen nicht:\n\n"
        "• Die App kopieren, modifizieren oder verbreiten\n"
        "• Unsere Marken ohne Erlaubnis verwenden\n"
        "• Abgeleitete Werke erstellen",
    'termsDisclaimerTitle': '6. Haftungsausschluss',
    'termsDisclaimerContent': "Twin'Am wird \"wie besehen\" ohne Gewährleistung bereitgestellt. Wir garantieren nicht:\n\n"
        "• Die App ist fehlerfrei oder unterbrechungsfrei\n"
        "• Mängel werden behoben\n"
        "• Die App erfüllt Ihre spezifischen Anforderungen\n\n"
        "Die Nutzung erfolgt auf eigenes Risiko.",
    'termsLiabilityTitle': '7. Haftungsbeschränkung',
    'termsLiabilityContent': "Im maximal gesetzlich zulässigen Umfang haften wir nicht für:\n\n"
        "• Indirekte, beiläufige oder Folgeschäden\n"
        "• Datenverlust oder entgangenen Gewinn\n"
        "• Schäden durch Ihre Nutzung der App",
    'termsUpdatesTitle': '8. Aktualisierungen und Änderungen',
    'termsUpdatesContent': "Wir behalten uns das Recht vor:\n\n"
        "• Die App jederzeit zu ändern oder einzustellen\n"
        "• Diese Nutzungsbedingungen zu aktualisieren\n"
        "• Funktionen hinzuzufügen oder zu entfernen\n\n"
        "Die weitere Nutzung nach Änderungen gilt als Zustimmung.",
    'termsTermTitle': '9. Kündigung',
    'termsTermContent': "Sie können die Nutzung jederzeit durch Deinstallation beenden. Wir behalten uns das Recht vor, den Zugang bei Verstößen zu sperren.",
    'termsLawTitle': '10. Anwendbares Recht',
    'termsLawContent': "Diese Nutzungsbedingungen unterliegen französischem Recht.",
    'termsContactTitle': '11. Kontakt',
    'termsContactContent': "Bei Fragen zu diesen Nutzungsbedingungen:\n\nE-Mail: contact@twinam.app",

    // ── Support Page ──
    'supportTitle': 'Hilfe',
    'supportSub': 'Wir sind für dich da',
    'contactTitle': 'Kontaktiere uns',
    'contactSub': 'Eine Frage? Ein Problem? Ein Vorschlag?',
    'faqTitle': 'Häufig gestellte Fragen',
    'faq1Q': 'Wie erstelle ich einen neuen Zähler?',
    'faq1A': 'Tippe auf "+" unten rechts im Dashboard und gib die Informationen deines Zählers ein (Name, Ziel, Symbol, etc.).',
    'faq2Q': 'Wie setze ich ein tägliches Ziel?',
    'faq2A': 'Beim Erstellen oder Bearbeiten eines Zählers aktiviere die Option "Ziel" und lege die Zahl fest, die du täglich erreichen möchtest.',
    'faq3Q': 'Wie füge ich eine Aufgabe hinzu?',
    'faq3A': 'Tippe auf das Aufgaben-Symbol im Dashboard-Header, dann auf "+" um eine neue Aufgabe mit Titel, Beschreibung, Frist und Priorität zu erstellen.',
    'faq4Q': 'Werden meine Daten mit der Cloud synchronisiert?',
    'faq4A': 'Zähler und Aufgaben werden nur lokal gespeichert. Wenn du ein Konto erstellst, werden Profil, Freunde und Herausforderungen über Supabase synchronisiert — notwendig für soziale Funktionen. Du kannst die App ohne Konto nutzen, um alles lokal zu halten.',
    'faq5Q': 'Wie deaktiviere ich Benachrichtigungen?',
    'faq5A': 'Gehe zu Einstellungen > Benachrichtigungen und deaktiviere die unerwünschten. Du kannst sie auch in den Geräteeinstellungen verwalten.',
    'faq6Q': 'Wie ändere ich die App-Sprache?',
    'faq6A': "Gehe zu Einstellungen > Sprache und wähle deine bevorzugte Sprache. Twin'Am unterstützt Englisch, Französisch, Arabisch, Spanisch und Deutsch.",
    'faq7Q': 'Was passiert, wenn ich die App deinstalliere oder mein Konto lösche?',
    'faq7A': 'Deinstallation entfernt lokale Daten (Zähler, Aufgaben). Um Profil und alle Cloud-Daten (Freunde, Herausforderungen) zu löschen, nutze Einstellungen > Mein Konto > Konto löschen. Diese Aktion ist sofort und unwiderruflich.',
    'faq8Q': 'Wie funktioniert das Twin-System?',
    'faq8A': 'Dein Twin ist ein virtueller Begleiter, der auf deinen Fortschritt reagiert. Er ist glücklich bei erreichten Zielen, neutral bei Bemühungen und traurig, wenn du Motivation brauchst.',
    'faq9Q': 'Wie verdiene ich XP und steige auf?',
    'faq9A': 'Du verdienst XP durch Erreichen täglicher Ziele, Erledigen von Aufgaben und Aufrechterhalten von Serien. Je regelmäßiger du bist, desto schneller steigst du auf!',
    'faq10Q': 'Wie funktionieren soziale Herausforderungen?',
    'faq10A': 'Erstelle ein Konto, füge Freunde hinzu und gehe zum Herausforderungen-Tab. Sobald dein Gegner akzeptiert, verfolgt ihr beide dieselbe Gewohnheit mit verknüpften Zählern und könnt euren gegenseitigen Fortschritt in Echtzeit sehen.',
    'faq11Q': 'Wie lösche ich mein Konto?',
    'faq11A': 'Gehe zu Einstellungen > Mein Konto > Konto löschen und bestätige. Alle deine Daten (Profil, Freunde, Herausforderungen) werden dauerhaft von unseren Servern gelöscht. Lokale Zähler und Aufgaben bleiben bis zur Deinstallation bestehen.',

    'feat7Title': 'Soziale Herausforderungen',
    'feat7Desc': 'Fordere deine Freunde zu Gewohnheits-Duellen heraus und verfolgt gegenseitig euren Fortschritt in Echtzeit',
  };
}
