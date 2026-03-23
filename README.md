# 🏋️ GymFlow: High-Performance Strength Tracking System

[**Español**](#español) | [**English**](#english)

---

<a name="español"></a>
## 🇪🇸 Versión en Español

### Descripción General
**GymFlow** es una arquitectura de software diseñada para el registro analítico y sistemático del entrenamiento de fuerza. Este proyecto prioriza la integridad de los datos (Local-First), la privacidad del usuario y la visualización técnica de métricas de rendimiento.

### 🏗️ Arquitectura Técnica (Flutter)
La implementación se basa en el SDK de **Flutter**, utilizando un motor de renderizado de alto rendimiento para una experiencia fluida (60 FPS) con una estética de alto contraste.

- **Gestión de Estado**: Implementada mediante el patrón **Provider**, asegurando un desacoplamiento eficiente entre la lógica de negocio (`Business Logic`) y la capa de presentación.
- **Persistencia Local**: Utiliza **SQLite (sqflite)** para una gestión relacional de datos estrictamente local. Esto garantiza latencia cero y una privacidad de datos absoluta.
- **Análisis de Intensidad (%)**: Integra un algoritmo personalizado de **Carga Media de Sesión** que normaliza el volumen levantado por ejercicio para evitar sesgos por volumen total acumulado.

### 🛠️ Stack Tecnológico
- **Lenguaje**: Dart 3.x
- **Framework**: Flutter (v3.22+)
- **Base de Datos**: SQLite
- **Visualización**: `fl_chart` (Gráficas de sobrecarga progresiva)

---

<a name="english"></a>
## 🇺🇸 English Version

### Project Overview
**GymFlow** is a software architecture engineered for systematic and analytical strength training tracking. This project focuses on data integrity (Local-First), user privacy, and technical performance metric visualization.

### 🏗️ Technical Architecture (Flutter)
Built on the **Flutter SDK**, utilizing a high-performance rendering engine to ensure a smooth 60 FPS experience with high-contrast UI aesthetics.

- **State Management**: Implemented using the **Provider** pattern, ensuring efficient decoupling between Business Logic and the Presentation Layer.
- **Local Persistence**: Uses **SQLite (sqflite)** for strictly local relational data management. This guarantees zero latency and absolute data privacy.
- **Intensity Analysis (%)**: Integrates a custom **Session Average Load** algorithm that normalizes lifted volume per exercise to avoid biases from accumulated total volume.

### 🛠️ Tech Stack
- **Language**: Dart 3.x
- **Framework**: Flutter (v3.22+)
- **Database**: SQLite
- **Visualization**: `fl_chart` (Progressive overload analytics)

---

### 📦 Installation / Instalación
1. `flutter pub get`
2. `flutter run`
3. APK: [`mobile/build/app/outputs/flutter-apk/app-release.apk`](file:///c:/Users/anahy/OneDrive/Escritorio/Proyects/gymflow/mobile/build/app/outputs/flutter-apk/app-release.apk)

**Author / Autor**: **Anahi Lozano (A.B.L.DL)**.
[LinkedIn](https://www.linkedin.com/in/anahi-lozano-de-lira-a4213a187)
