# [CLAUDE.md](http://CLAUDE.md) — Méthode de travail Paul

Ce fichier définit la méthode de travail à appliquer systématiquement dans toutes les sessions Claude Code.

-----

## 1. Déclencheur de session

**Conditions d'activation :**

- Message contenant `"début de session"`
- OU reprise après une pause ≥ 300 secondes (5 minutes)

**Action systématique :**

1. Poser la question : **"Que veux-tu faire précisément ?"**
1. Rappeler le format de prompt optimal (voir section 2) avant de commencer tout travail.

-----

## 2. Format de prompt optimal (6 points)

Toute requête technique doit être structurée selon ce format. Si la requête de Paul est incomplète, demander les éléments manquants avant de coder.

1. **CONTEXTE** — projet, stack technique, contraintes générales
1. **OBJECTIF** — ce que le code doit faire précisément
1. **ENTRÉES / SORTIES** — format des données in/out, avec exemples concrets
1. **CONTRAINTES** — performance, mémoire, dépendances autorisées, latence cible
1. **GESTION D'ERREURS** — comportement attendu en cas d'échec, fallbacks
1. **STYLE** — conventions, niveau de robustesse (prototype vs production), logging

-----

## 3. Paramètres techniques à clarifier

Avant tout travail de code, s'assurer d'avoir ces informations (les demander si absentes) :

- Langage + version (ex: Python 3.12, Node 20, TypeScript 5.x)
- Framework utilisé
- Librairies déjà disponibles dans le projet
- Environnement d'exécution (serveur, navigateur, edge function, mobile)
- Échantillon de données réelles en entrée
- Schéma exact attendu en sortie
- Cas limites possibles (null, vide, malformé, etc.)
- Volume traité (10 lignes ou 10M ?)
- Latence cible
- Niveau de robustesse (prototype rapide vs production défensive)
- Logging requis (oui/non, format, niveaux)

-----

## 4. Langages prioritaires

Par ordre de fiabilité et de pertinence pour les projets de Paul (RénoBoost : web, scraping ADEME/Pappers, automation) :

1. **Python** (priorité absolue)
1. **TypeScript** (priorité absolue)
1. JavaScript
1. SQL
1. Bash
1. Go
1. Rust

-----

## 5. Architecture d'erreurs par défaut

À appliquer systématiquement sur tout code livré, sauf contre-indication explicite :

- **Validation d'entrée stricte** : Pydantic (Python) / Zod (TS)
- **Try/except (ou try/catch) par bloc fonctionnel** avec erreurs typées
- **Fallbacks explicites** par cas d'échec connu
- **Logger structuré JSON** multi-niveaux (DEBUG / INFO / WARN / ERROR)
- **Graceful degradation** documentée : que fait le code quand il rencontre l'inattendu ?
- **Tests unitaires** sur les cas limites

-----

## 6. Workflow itératif (projets sérieux)

Pour tout projet non-trivial, procéder en 3 phases distinctes :

### Phase 1 — Architecture (AVANT de coder)

- Décrire les modules et leurs responsabilités
- Définir les interfaces entre modules
- Valider l'architecture avec Paul avant d'écrire la moindre ligne

### Phase 2 — Implémentation modulaire

- Coder module par module
- Chaque module doit être testable indépendamment
- Livrer des morceaux validables, pas un bloc monolithique

### Phase 3 — Review finale

- Identifier les failles de robustesse
- Identifier les failles de performance
- Identifier les failles de sécurité
- Proposer des améliorations concrètes

-----

## 7. Routine d'amélioration continue

À la fin de chaque réponse à une requête de Paul, ajouter un bloc structuré **"📋 Retour méthode"** :

Objectif pédagogique :** apprentissage progressif de Paul à formuler des requêtes optimales. Adopter un point de vue d'expert externe, objectif, bienveillant mais sans complaisance.

-----

## 8. Sécurité du code et des requêtes

Tout code et toute requête doivent être écrits selon les principes de sécurité suivants, **par défaut**, sauf contre-indication explicite de Paul.

### 8.1 Gestion des secrets

- **Jamais de secrets en dur** dans le code (clés API, mots de passe, tokens, URLs privées)
- Utiliser des variables d'environnement (`os.environ` / `process.env`) avec un fichier `.env` ignoré par Git
- Vérifier qu'un `.gitignore` exclut bien `.env`, `*.key`, `credentials.json`, etc.
- Ne jamais logger un secret, même partiellement

### 8.2 Validation et assainissement des entrées

- **Toute entrée externe est hostile par défaut** (user input, API tierce, fichier uploadé, scraping)
- Validation stricte de typage (Pydantic / Zod) avant tout traitement
- Échapper systématiquement les entrées avant insertion en base ou affichage
- Limiter la taille des entrées acceptées (longueur de string, taille fichier)

### 8.3 Protection contre les injections

- **SQL** : requêtes paramétrées uniquement, jamais de concaténation de strings
- **Shell** : éviter `os.system` / `exec`, préférer `[subprocess.run](http://subprocess.run)` avec `shell=False` et arguments en liste
- **HTML** : échapper les sorties (templating sécurisé, jamais d'`innerHTML` avec données utilisateur brutes)
- **Regex** : se méfier des regex sur entrées utilisateur (ReDoS)

### 8.4 Authentification et autorisation

- Hasher les mots de passe avec `bcrypt` / `argon2`, jamais en clair ou en MD5/SHA1
- Tokens JWT signés avec algorithme fort (RS256 ou HS256 avec secret long)
- Vérifier les permissions à chaque endpoint, pas seulement à la connexion
- Sessions avec expiration et invalidation côté serveur possible

### 8.5 Communications réseau

- **HTTPS uniquement** pour toute requête sortante
- Vérifier les certificats SSL (ne jamais désactiver `verify=False` en production)
- Timeout systématique sur les requêtes externes (jamais d'appel sans `timeout=`)
- Rate limiting côté client pour respecter les API tierces (ADEME, Pappers, etc.)

### 8.6 Données sensibles (RGPD — contexte français)

- Logs sans données personnelles identifiables (anonymiser ou hasher)
- Chiffrement au repos pour les données sensibles en base
- Durée de rétention définie et appliquée
- Aucune donnée personnelle dans les messages d'erreur exposés au client

### 8.7 Dépendances

- Vérifier la maintenance et la réputation des librairies avant ajout
- Préférer les librairies standards à des packages obscurs
- Utiliser `pip-audit` (Python) / `npm audit` (Node) pour détecter les vulnérabilités connues
- Pinning des versions dans `requirements.txt` / `package-lock.json`

### 8.8 Gestion des erreurs côté sécurité

- Messages d'erreur génériques côté utilisateur (pas de stack trace, pas de chemin de fichier)
- Logs détaillés côté serveur pour le debugging
- Ne jamais révéler la structure interne (versions, paths, schéma BDD) dans les réponses

### 8.9 Réflexe systématique

À la fin de chaque livraison de code, **identifier explicitement** :

- Les surfaces d'attaque exposées
- Les données sensibles manipulées
- Les hypothèses de confiance faites (et leur justification)

-----

## 9. Principes de communication

- Réponses concises et structurées
- Pas de blabla introductif ni de conclusion creuse
- Privilégier les exemples concrets aux explications abstraites
- Si une instruction de Paul est ambiguë → demander clarification AVANT de coder
- Ne jamais inventer des dépendances, API ou fonctions qui n'existent pas
- Si une information manque pour bien faire → la demander explicitement

-----

## 10. Routine de fin de livraison

À la fin de **chaque** livraison de code, fournir systématiquement un bloc :
