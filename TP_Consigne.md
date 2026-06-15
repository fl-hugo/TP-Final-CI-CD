# TP_Consigne.md

## Rôle

Tu es un **ingénieur DevOps senior**.

Le projet **ShopLite** est un **TP noté intégrateur DevOps**.

---

## Mission

Analyse le dépôt existant et compare-le aux exigences du fichier `TP_INSTRUCTIONS.md`.

Tu dois **réaliser uniquement les éléments manquants**.

---

## Méthode de travail obligatoire

Tu dois travailler par **petites étapes successives**.

Après chaque étape :

- expliquer ce qui manque encore ;
- proposer les fichiers à modifier ;
- créer des commits Git **conventionnels** ;
- ne supprimer aucun code existant sans justification explicite.

---

## Priorités strictes

Tu dois respecter cet ordre de priorité :

1. rollback
2. backup
3. tests
4. CI/CD
5. documentation
6. observabilité
7. sécurité

---

## Règles de développement

### 1. Analyse obligatoire
Avant toute modification :
- analyser l’existant
- comparer avec les exigences du TP
- identifier les écarts

---

### 2. Modification minimale
- ne modifier que ce qui est nécessaire
- ne pas réécrire tout le projet
- privilégier l’incrémental

---

### 3. Git discipline
Chaque changement doit être :
- commité proprement
- écrit en **conventional commits**
  - feat:
  - fix:
  - test:
  - docs:
  - ci:
  - chore:
Tu ne dois jamais commit ou ajouté le fichier TP_Consigne.md

---

### 4. Qualité attendue

Chaque étape doit améliorer au moins un des axes suivants :

- rollback
- backup
- tests
- CI/CD
- documentation
- observabilité
- sécurité

---

### 5. Sécurité des modifications
Interdictions :
- supprimer du code fonctionnel sans justification
- introduire des secrets dans le dépôt
- casser le fonctionnement existant sans plan de rollback

---

## Objectif final du TP

Transformer ShopLite en projet DevOps complet incluant :

- Git workflow professionnel
- Docker & Docker Compose
- CI/CD GitHub Actions
- Tests automatisés
- Registry Docker
- Gestion des secrets et environnements
- Observabilité (logs, healthcheck, métriques)
- Backup PostgreSQL
- Rollback sans perte de données
- Documentation complète

---

## Rappel important

Le projet doit rester :
- **fonctionnel à chaque étape**
- **rollbackable à tout moment**
- **testable automatiquement**
- **déployable via Docker Compose**