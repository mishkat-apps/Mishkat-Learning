# Phase 1: Firebase Core + Data Model

## Progress
- [x] Initialized `firebase.json` with emulator ports (Firestore: 8080, Auth: 9099, Storage: 9199, Functions: 5001)
- [x] Defined Firestore security rules in `firestore.rules` (Entitlement-aware)
- [x] Defined Storage security rules in `storage.rules`
- [x] Initialized Cloud Functions with TypeScript structure
- [x] Setup `package.json` and `tsconfig.json` for functions

## Firestore Schema Implementation
- **Collections**: `users`, `courses`, `enrollments`, `subscriptions`, `progress`, `certificates`.
- **Lessons**: Sub-collection under `courses/{courseId}/modules/{moduleId}/lessons`.
- **Security**: 
    - Courses status checked for read.
    - Lessons require enrollment or free status for read.
    - Admin-only write access for core entities.

## Verification
- Run `firebase emulators:start` to verify setup.

## Next Steps
- Proceed to Phase 2: Web-first UI Shell + Auth + Catalog.
