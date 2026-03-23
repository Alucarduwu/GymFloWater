# 🏋️ GymFlow: High-Performance Strength Tracking System

<div align="center">
  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-v3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
    <img src="https://img.shields.io/badge/Dart-v3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
    <img src="https://img.shields.io/badge/SQLite-Offline--First-003B57?style=for-the-badge&logo=sqlite&logoColor=white" />
    <img src="https://img.shields.io/badge/State--Management-Provider-60B5CC?style=for-the-badge" />
  </p>
  
  [**Español**](#español) | [**English**](#english)
</div>

---

<a name="español"></a>
## 🇪🇸 Versión en Español: Ingeniería de Entrenamiento

### 💎 Filosofía del Proyecto
**GymFlow** no es solo un registro; es un sistema de gestión de carga diseñado bajo principios de ingeniería de software. El objetivo es proporcionar una herramienta **Local-First** que elimine la fricción en la toma de datos sin comprometer la profundidad analítica.

### 🧪 ¿Cómo funciona? (Análisis Técnico)

#### 1. Motor de Persistencia Asíncrona (SQLite)
El sistema utiliza una capa de abstracción sobre **SQLite** (`DatabaseService`) que gestiona las transacciones de forma asíncrona. 
- **Integridad Referencial**: Las rutinas y sesiones están vinculadas mediante claves foráneas rigurosas, asegurando que ningún dato de progreso se pierda o se corrompa.
- **Cero Latencia**: Al ser exclusivamente local, los tiempos de respuesta son sub-miliseconales, ideales para entornos de alta intensidad.

#### 2. Gestión de Estado Reactiva (Provider)
Utilizamos el patrón **Provider** para orquestar el flujo de datos:
- La UI escucha cambios en el `GymProvider`.
- Cualquier actualización en el volumen o PR (Personal Record) se propaga instantáneamente a través de un bus de eventos reactivo, actualizando gráficas y estadísticas sin recargas costosas.

#### 3. Algoritmo de Carga Inteligente (%)
Implementamos una lógica de **Normalización de Volumen**. En lugar de sumas escalares, el sistema calcula la intensidad relativa por ejercicio, promediando series y sets para ofrecer una métrica de "Esfuerzo Real" que escala con el progreso del atleta.

---

<a name="english"></a>
## 🇺🇸 English Version: Training Engineering

### 💎 Project Philosophy
**GymFlow** is more than a logger; it's a load management system designed under software engineering principles. The goal is to provide a **Local-First** tool that removes friction in data entry without compromising analytical depth.

### 🧪 How it Works? (Technical Analysis)

#### 1. Asynchronous Persistence Engine (SQLite)
The system employs an abstraction layer over **SQLite** (`DatabaseService`) handling transactions asynchronously.
- **Referential Integrity**: Routines and sessions are linked via rigorous foreign keys, ensuring no progress data is lost or corrupted.
- **Zero Latency**: Being exclusively local, response times are sub-millisecond, ideal for high-intensity environments.

#### 2. Reactive State Management (Provider)
We utilize the **Provider** pattern to orchestrate the data flow:
- The UI listens for changes in the `GymProvider`.
- Any update in volume or PR (Personal Record) propagates instantly through a reactive event bus, updating charts and stats without costly reloads.

#### 3. Smart Load Algorithm (%)
We implement **Volume Normalization** logic. Instead of scalar sums, the system calculates relative intensity per exercise, averaging series and sets to offer a "Real Effort" metric that scales with the athlete's progress.

---

### 📦 Installation / Instalación
1. `flutter pub get`
2. `flutter run`
3. APK: [`mobile/build/app/outputs/flutter-apk/app-release.apk`](file:///c:/Users/anahy/OneDrive/Escritorio/Proyects/gymflow/mobile/build/app/outputs/flutter-apk/app-release.apk)

**Author / Autor**: **Anahi Lozano (A.B.L.DL)**.
[LinkedIn](https://www.linkedin.com/in/anahi-lozano-de-lira-a4213a187)
