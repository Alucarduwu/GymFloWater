# 🏋️ GymFlow Mobile (Flutter SDK)

<div align="center">
  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-v3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
    <img src="https://img.shields.io/badge/SQLite-Offline--First-003B57?style=for-the-badge&logo=sqlite&logoColor=white" />
  </p>
  
  [**Español**](#español) | [**English**](#english)
</div>

---

<a name="español"></a>
## 🇪🇸 Implementación Móvil Nativizada

Esta sub-carpeta contiene la lógica de negocio y el sistema de diseño reactivo para dispositivos móviles.

### 🧪 Arquitectura de Software
- **Provider Pattern**: Gestión de estado centralizado que desacopla la sincronización de la base de datos de la capa visual.
- **Relational Mapping**: El `DatabaseService` actúa como un ORM ligero sobre SQLite, garantizando transacciones seguras y rápidas.
- **Micro-interacciones**: Optimización de hilos secundarios para cálculos de volumen en tiempo real sin bloquear el `Main Thread` (60 FPS estables).

---

<a name="english"></a>
## 🇺🇸 Native Mobile Implementation

This sub-directory contains the business logic and reactive design system for mobile devices.

### 🧪 Software Architecture
- **Provider Pattern**: Centralized state management that decouples database synchronization from the visual layer.
- **Relational Mapping**: `DatabaseService` acts as a lightweight ORM over SQLite, ensuring secure and fast transactions.
- **Micro-interactions**: Secondary thread optimization for real-time volume calculations without blocking the `Main Thread` (stable 60 FPS).

---

### 📦 Installation / Instalación
1. `flutter pub get`
2. `flutter run`
3. APK: [`build/app/outputs/flutter-apk/app-release.apk`](file:///c:/Users/anahy/OneDrive/Escritorio/Proyects/gymflow/mobile/build/app/outputs/flutter-apk/app-release.apk)

---
© 2026 **A.B.L.DL**.
