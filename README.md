# Canis Odd Music.Com

Starter full-stack project for Canis Odd Music.Com.

## Business rules
- Every music download costs **700 UGX**.
- Donations have **no fixed maximum**; supporters choose the amount.
- Payment confirmation must come from the backend/payment provider webhook.
- Flutter must never contain database credentials, payment secrets, or admin secrets.

## Stack
- Frontend: Flutter / Dart
- Backend: Node.js / Express / TypeScript
- ORM: Prisma
- Database: PostgreSQL
- Payments: Mobile Money + bank cards (provider integration placeholder)

## Structure
- `frontend/` Flutter application starter
- `backend/` REST API starter
- `docs/` project notes

## Quick start
### Backend
```bash
cd backend
cp .env.example .env
npm install
npx prisma generate
npx prisma migrate dev --name init
npm run dev
```

### Flutter
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Replace the placeholder payment provider implementation with the provider selected for production in Uganda.
