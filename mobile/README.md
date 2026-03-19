# 🏋️ GymFlow Mobile 🐟

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![SQLite](https://img.shields.io/badge/SQLite-07405E?logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev/)

Bienvenido a la implementación nativa de **GymFlow**. Diseñada con una arquitectura reactiva y un motor de base de datos local para ofrecer la máxima velocidad durante tus sesiones de alta intensidad.

---

## ✨ Características Principales

### 📈 Dashboard de Volumen (Power Analytics)
Revisa de un vistazo tu progreso semanal y compara con la semana anterior. Visualiza tu volumen total levantado en kg para entender tu sobrecarga progresiva.

### 📝 Registro Dinámico de Series
Entrada de datos ultra-rápida. Registra ejercicios, series, pesos y repeticiones. La aplicación calcula automáticamente el volumen por ejercicio y sesión.

### 📅 Calendario de Consistencia
Un calendario interactivo que marca automáticamente los días en que has cumplido tus metas. Mantén la disciplina visualizando tus rachas.

### 🐠 Sistema de Rangos Marinos (Gamificación)
No solo entrenas, evolucionas. Mantén tu racha activa para ascender en la cadena alimenticia del fitness:
- **🥚 Huevo de Pez**: ¡Bienvenido al océano!
- **🦐 Camarón**: Tu primera victoria.
- **🐟 Pez Neta**: La constancia empieza a notarse.
- **🐡 Pez Globo**: Ya no eres un principiante.
- **🗡️ Pez Espada**: Dominio total del arrecife.

---

## 🛠️ Stack Tecnológico

- **🚀 Framework**: [Flutter 3.x](https://flutter.dev/) - UI nativa multiplataforma (60fps).
- **💾 Base de Datos**: [SQLite (sqflite)](https://pub.dev/packages/sqflite) - Almacenamiento local persistente (Offline-First).
- **🏗️ Arquitectura**: **Provider** - Gestión de estado escalable y reactiva.
- **📉 Visualización**: **FL Chart** - Gráficas vectoriales interactivas y dinámicas.
- **🎨 UI/UX**: Diseño Glassmorphism premium, Dark Mode nativo y tipografía Inter.

---

## 📦 Cómo Empezar

### 1. Requisitos Previos
- Flutter SDK instalado.
- Android Studio / Xcode (para compilación nativa).

### 2. Instalación de Dependencias
Ejecuta el siguiente comando en la raíz de la carpeta `mobile`:
```bash
flutter pub get
```

### 3. Ejecutar la Aplicación
Conecta tu dispositivo físico o abre un emulador y ejecuta:
```bash
flutter run
```

---

## 🔒 Privacidad y Seguridad
**GymFlow Mobile** es una aplicación *Offline-First*. Tus datos de salud y entrenamiento se almacenan únicamente en la base de datos SQLite interna de tu dispositivo. Esto garantiza privacidad total y disponibilidad incluso sin conexión a internet.

---

Diseñado por **Anahyd Lira**. Construido para la fuerza.
