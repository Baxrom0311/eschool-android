# Developer 2 — Backend / API Specialist

> **Ishlash joyi:** `lib/data/` va `lib/presentation/providers/`
>
> **Qoidalar:** Har bir model + repository tayyor bo'lgach `git commit`. Provider lar test qilingan bo'lsin.

## Sprint 1 (4.5 kun) — Auth + User Models

- [ ] `data/models/user_model.dart` — fromJson, toJson
- [ ] `data/models/child_model.dart` — fromJson, toJson
- [ ] `data/datasources/remote/auth_api.dart` — login, register, logout, google, refresh
- [ ] `data/repositories/auth_repository.dart`
- [ ] `presentation/providers/auth_provider.dart` — login/register/logout state
- [ ] Token management — DioClient interceptor da auto-refresh ishlaydi
- [ ] Google Sign In integratsiya

## Sprint 2 (4 kun) — User + Payments

- [ ] `data/datasources/remote/user_api.dart` — profile, children, update
- [ ] `data/repositories/user_repository.dart`
- [ ] `presentation/providers/user_provider.dart` — child selector bilan
- [ ] `data/models/payment_model.dart` — fromJson, toJson
- [ ] `data/datasources/remote/payment_api.dart`
- [ ] `data/repositories/payment_repository.dart`
- [ ] `presentation/providers/payment_provider.dart`

## Sprint 3 (4 kun) — Academics

- [ ] `data/models/grade_model.dart`
- [ ] `data/models/schedule_model.dart`
- [ ] `data/models/assignment_model.dart`
- [ ] `data/models/attendance_model.dart`
- [ ] `data/datasources/remote/academic_api.dart`
- [ ] `data/repositories/academic_repository.dart`
- [ ] `presentation/providers/academic_provider.dart`

## Sprint 4 (4 kun) — Menu + Chat

- [ ] `data/models/menu_model.dart`
- [ ] `data/datasources/remote/menu_api.dart`
- [ ] `data/repositories/menu_repository.dart`
- [ ] `presentation/providers/menu_provider.dart`
- [ ] `data/models/chat_model.dart` — message, conversation
- [ ] `data/datasources/remote/chat_api.dart`
- [ ] `data/repositories/chat_repository.dart`
- [ ] `presentation/providers/chat_provider.dart`

## Sprint 5 (4.5 kun) — Notifications + Payment Integration

- [ ] `data/models/notification_model.dart`
- [ ] `data/datasources/remote/notification_api.dart`
- [ ] `presentation/providers/notification_provider.dart`
- [ ] Firebase FCM setup — `main.dart` + AndroidManifest
- [ ] PayMe SDK integratsiya
- [ ] Click SDK integratsiya

## Sprint 6 (3.5 kun) — Offline + Error Polish

- [ ] `data/models/rating_model.dart`
- [ ] `data/datasources/remote/rating_api.dart`
- [ ] `presentation/providers/rating_provider.dart`
- [ ] `data/datasources/local/local_cache.dart` — SharedPrefs ga cache
- [ ] Error handling polish — barcha provider larda try-catch

## Sprint 7 (4 kun) — Integration + Testing

- [ ] `main.dart` ga barcha provider larni qo'shish
- [ ] Dev1 bilan integratsiya — providers ↔ screens bog'lash
- [ ] Unit testlar — `test/` papkasida
- [ ] Bug fix va optimization

---

**Jami: ~28 kun**
