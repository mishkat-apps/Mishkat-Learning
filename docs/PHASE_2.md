# Phase 2: Web-first UI Shell + Auth + Catalog

## Progress
- [x] Initialized Flutter Web project: `apps/mishkat_learning_app`
- [x] Setup architecture: Riverpod for state, GoRouter for routing
- [x] Defined `lib/src` structure (Core, Features, Services, Theme)
- [x] Implemented `AppTheme` with Emerald/Gold/Navy brand colors
- [x] Setup `main.dart` with `ProviderScope` and `GoRouter`

## UI Decisions
- **Breakpoints**: Planning for `< 600px` (mobile), `600px - 1024px` (tablet), `> 1024px` (desktop)
- **Primary Font**: Outfit for headings, Inter for body
- **Navigation**: Goal is Sidebar for desktop and Bottom Nav for mobile

## Next Steps
- Implement Auth Flow (Auth Service + Login/Register UI)
- Build Dashboard Shell
- Develop Catalog Page
