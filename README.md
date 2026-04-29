# template-de-standards-de-travail-

Repo gabarit qui impose la **méthode de travail Paul** à chaque session Claude Code.
À cloner comme base de tout nouveau projet (RénoBoost, scraping ADEME/Pappers, automation, etc.).

## À quoi ça sert

Plus besoin de répéter "applique ma méthode" à chaque conversation : la méthode se charge automatiquement au démarrage de Claude Code grâce à un hook `SessionStart`.

## Contenu

| Fichier | Rôle |
|---|---|
| `CLAUDE.md` | Manuel de méthode lu par Claude au démarrage : format prompt 6 points, langages prioritaires, architecture d'erreurs, règles de sécurité, RGPD, routines de fin de livraison. |
| `.claude/settings.json` | Hook `SessionStart` qui injecte un rappel de la méthode au début de chaque session. |
| `.gitignore` | Bloque le commit accidentel de secrets (`.env`, `*.key`, `*.pem`, `credentials.json`, `secrets.json`). |

## Utilisation

### Comme base de nouveau projet

```bash
git clone <url-de-ce-repo> mon-nouveau-projet
cd mon-nouveau-projet
rm -rf .git && git init   # repartir d'un historique propre
```

Ouvrir le dossier dans Claude Code : la méthode est appliquée d'office.

### Installation globale (toutes sessions, tous repos)

Copier `CLAUDE.md` dans `~/.claude/CLAUDE.md` pour que la méthode soit chargée
dans **toutes** les sessions Claude Code, sans avoir à toucher chaque repo :

```bash
./scripts/sync-claude-method.sh
```

Ce script :
- fait un `git pull --ff-only` du repo template
- copie `CLAUDE.md` → `~/.claude/CLAUDE.md`
- crée un backup horodaté si l'ancien diffère
- ne touche **pas** à `~/.claude/settings.json` (hook = installation manuelle one-shot)

Re-lancer le script à chaque évolution de la méthode pour propager partout.

## Méthode résumée (extrait de `CLAUDE.md`)

- **Format prompt 6 points** : CONTEXTE / OBJECTIF / ENTRÉES-SORTIES / CONTRAINTES / GESTION ERREURS / STYLE
- **Si requête incomplète** → Claude demande les manques avant de coder
- **Architecture erreurs par défaut** : Pydantic/Zod, try/catch typé, fallbacks, logger JSON
- **Sécurité par défaut** : secrets en `.env`, validation entrées hostiles, SQL paramétré, HTTPS+timeout, RGPD
- **Fin de livraison code** : bloc `🔒 Retour sécurité` + `⚡ Retour optimisation`
- **Fin de réponse** : bloc `📋 Retour méthode` (pédagogique)

Voir `CLAUDE.md` pour le détail complet.
