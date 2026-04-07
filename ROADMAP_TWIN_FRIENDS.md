# Twin Friends — Future Feature Roadmap

> Idee discutee le 7 avril 2026. A implementer apres stabilisation de la version solo.

## Concept

Ajouter une dimension sociale a Twin'Am : amis, challenges, interactions entre Twins.
Objectif : transformer Twin'Am d'un outil personnel en plateforme sociale de productivite.

## Stack technique : Supabase

**Choix : Supabase** (plutot que Firebase)

| Avantage | Detail |
|----------|--------|
| PostgreSQL | Relationnel, ideal pour challenges/amis/leaderboards |
| Free tier genereux | 500MB DB, 1GB storage, 50K auth users |
| Open source | Self-host possible, pas de vendor lock-in |
| RLS natif | Securite par ligne sans code complexe |
| Flutter SDK | supabase_flutter, bon support |
| Familiarite | L'equipe connait deja Supabase |

### Schema DB previsionnel

```sql
-- Profils utilisateurs
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  streak INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Systeme d'amis
CREATE TABLE friendships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id),
  friend_id UUID REFERENCES profiles(id),
  status TEXT DEFAULT 'pending', -- pending, accepted, rejected
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- Challenges
CREATE TABLE challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID REFERENCES profiles(id),
  title TEXT NOT NULL,
  description TEXT,
  habit_type TEXT NOT NULL,
  goal INTEGER NOT NULL,
  duration_days INTEGER DEFAULT 7,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status TEXT DEFAULT 'active', -- active, completed, cancelled
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Membres d'un challenge
CREATE TABLE challenge_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id),
  progress INTEGER DEFAULT 0,
  rank INTEGER,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(challenge_id, user_id)
);

-- Feed d'activite
CREATE TABLE activity_feed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id),
  type TEXT NOT NULL, -- goal_reached, streak, challenge_win, level_up
  content TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reactions
CREATE TABLE reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id UUID REFERENCES activity_feed(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id),
  emoji TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(activity_id, user_id)
);
```

## Phases d'implementation

### Phase 1 — Prerequis techniques
- [ ] Ajouter `supabase_flutter` au projet
- [ ] Auth Supabase (Google/Apple sign-in)
- [ ] Migration donnees local -> cloud (Hive -> Supabase)
- [ ] Sync bidirectionnelle local <-> cloud (offline-first)
- [ ] Profils utilisateurs cloud

### Phase 2 — Twin Friends MVP
- [ ] Ajout d'amis (code/QR/lien)
- [ ] Profils publics (niveau, streak, badges)
- [ ] Feed d'activite ("Karim a atteint 30 jours de streak")
- [ ] Encouragements (reactions emoji, "Go!")
- [ ] Notifications push entre amis

### Phase 3 — Challenges
- [ ] Creation de challenges (1v1 et groupe)
- [ ] Durees : 7j, 30j, custom
- [ ] Leaderboard temps reel (Supabase Realtime)
- [ ] Recompenses : XP bonus, badges exclusifs
- [ ] Historique des challenges

### Phase 4 — Twin vs Twin
- [ ] Ton Twin "affronte" celui de ton ami
- [ ] Avatar collectif d'equipe qui evolue
- [ ] Messages Twin personnalises ("Ton ami t'a depasse, rattrape-le !")
- [ ] Classement global Twin

## Cout estime

| Phase | Supabase | Autre | Total |
|-------|----------|-------|-------|
| Phase 1-2 | Free tier (0€) | 0€ | **0€** |
| Phase 3 | Free tier (0€) | 0€ | **0€** |
| Phase 4+ (scale) | ~$25/mois (Pro) | 0€ | **~$25/mois** |

> Supabase free tier supporte ~1000+ utilisateurs actifs sans probleme.

## Condition de lancement

- [ ] App solo stabilisee et publiee (iOS + Android)
- [ ] 500-1000 utilisateurs actifs
- [ ] Feedback utilisateurs recueilli
- [ ] Metriques de retention analysees

## Notes

- Garder l'approche **offline-first** : l'app doit rester fonctionnelle sans internet
- Les features sociales sont **optionnelles** : l'app solo reste complete
- Monetisation possible : challenges premium, badges exclusifs, themes Twin
