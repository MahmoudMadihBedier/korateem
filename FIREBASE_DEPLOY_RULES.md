# Deploy Firebase Rules (Firestore + Storage)

Your app log shows:

- `PERMISSION_DENIED: Missing or insufficient permissions`

This means the rules in `firestore.rules` / `storage.rules` are not deployed to
your Firebase project yet.

## 1) Install Firebase CLI (once)

```bash
npm i -g firebase-tools
firebase login
```

## 2) Deploy rules to your project

From the project root:

```bash
firebase use koraa-teem
firebase deploy --only firestore:rules,storage:rules
```

## Notes

- Rules files are: `firestore.rules` and `storage.rules`.
- `firebase.json` is configured to point at those rules files.
- If team image upload fails with 404 / `object-not-found`, enable **Firebase Storage** in the Firebase console for project `koraa-teem` and then deploy `storage.rules`.
