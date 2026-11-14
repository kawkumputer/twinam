/// Interrupteurs des grandes fonctions de l'app.
///
/// La partie sociale (amis, défis, classement, notifications push) demande un
/// compte Supabase et Firebase. Elle est masquée tant que l'app n'a pas assez
/// d'utilisateurs pour qu'elle serve : l'app reste alors 100 % locale, sans compte.
/// Le code est conservé ; repasser à `true` pour la réactiver.
const bool kSocialEnabled = false;

/// Nombre de compteurs autorisés sans Twin'Am Pro.
const int kFreeCounterLimit = 3;
