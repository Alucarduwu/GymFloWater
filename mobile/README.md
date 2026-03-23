# 🏋️ GymFlow Mobile (Flutter SDK)

[**Español**](#español) | [**English**](#english)

---

<a name="español"></a>
## 🇪🇸 Versión en Español

Esta carpeta contiene la implementación nativa para dispositivos móviles de **GymFlow**. La arquitectura sigue los principios de **Clean Architecture** adaptados para aplicaciones Flutter de alto rendimiento.

### 🧩 Implementación Técnica
- **Modelo de Datos**: Utiliza una estructura relacional gestionada por el servicio `DatabaseService` (SQLite).
- **Lógica de Negocio**: Centralizada en el `GymProvider`, permitiendo una gestión de estado global reactiva.
- **UI/UX**: Estética de alto contraste con componentes personalizados (`GlassCard`, `StatChip`) optimizados para visibilidad en entornos de gimnasio.

---

<a name="english"></a>
## 🇺🇸 English Version

This directory contains the native mobile implementation of **GymFlow**. The architecture follows **Clean Architecture** principles tailored for high-performance Flutter applications.

### 🧩 Technical Implementation
- **Data Model**: Uses a relational structure managed by the `DatabaseService` (SQLite).
- **Business Logic**: Centralized within `GymProvider`, enabling reactive global state management.
- **UI/UX**: High-contrast aesthetic featuring custom components (`GlassCard`, `StatChip`) optimized for visibility in gym environments.

---

### 📦 Installation / Instalación
1. `flutter pub get`
2. `flutter run`
3. APK: [`build/app/outputs/flutter-apk/app-release.apk`](file:///c:/Users/anahy/OneDrive/Escritorio/Proyects/gymflow/mobile/build/app/outputs/flutter-apk/app-release.apk)

---
© 2026 **A.B.L.DL**.
