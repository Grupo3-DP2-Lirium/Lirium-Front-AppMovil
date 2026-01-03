# 🌸 Lirium - Aplicación Móvil

<p align="center">
  <img src="https://media.discordapp.net/attachments/1301045138868670495/1456889811632783420/image.png?ex=695a01de&is=6958b05e&hm=6331d80c3628ce88751a1ee5046374c372654145899c8a566cae8c27ae0e5250&=&format=webp&quality=lossless" alt="Lirium Logo"/>
</p>

<p align="center">
  <strong>Preserva tus recuerdos y memorias personales en un espacio digital seguro</strong>
</p>

<p align="center">
  <a href="#características">Características</a> •
  <a href="#tecnologías">Tecnologías</a> •
  <a href="#instalación">Instalación</a> •
  <a href="#uso">Uso</a> •
  <a href="#capturas">Capturas</a> •
  <a href="#contribución">Contribución</a>
</p>

---

## 📖 Sobre el Proyecto

**Lirium** es una aplicación móvil y web desarrollada con Flutter, diseñada para la preservación de recuerdos y memorias personales mediante la creación de perfiles y memoriales digitales. La plataforma ofrece un entorno seguro y colaborativo donde los usuarios pueden registrar, organizar y compartir sus momentos más significativos.

### 🎯 Objetivo Principal

Proporcionar una solución integral para la documentación y preservación de la historia personal y familiar, facilitando la conexión emocional a través de recuerdos digitales organizados y accesibles.

---

## ✨ Características

### 📝 Gestión de Recuerdos
- ✅ Registro de recuerdos en múltiples formatos: 
  - 📄 Texto
  - 🖼️ Imágenes
  - 🎵 Audio
  - 🎥 Video
- ✅ Organización automática en líneas de tiempo
- ✅ Clasificación por temáticas y momentos
- ✅ Etiquetado y búsqueda avanzada

### 👥 Colaboración y Compartición
- ✅ Perfiles personales y memoriales digitales
- ✅ Compartición controlada de recuerdos
- ✅ Colaboración en memoriales grupales
- ✅ Configuración de privacidad y permisos

### 🤖 Inteligencia Artificial
- ✅ Generación automática de contenido audiovisual
- ✅ Sugerencias inteligentes de organización
- ✅ Mejora y optimización de medios

### 🔐 Seguridad y Privacidad
- ✅ Autenticación segura de usuarios
- ✅ Control granular de permisos
- ✅ Encriptación de datos sensibles
- ✅ Respaldo automático en la nube

### 📊 Panel Administrativo
- ✅ Gestión de usuarios y roles
- ✅ Administración de memoriales
- ✅ Control de suscripciones y planes
- ✅ Métricas y analíticas de uso
- ✅ Monitoreo de rendimiento

---

## 🛠️ Tecnologías

### Frontend Móvil
- **Framework**: Flutter 3.x
- **Lenguaje**: Dart 3.x
- **Gestión de Estado**: Provider / Bloc / Riverpod
- **Navegación**:  Flutter Navigator 2.0 / Go Router
- **UI Components**: Material Design 3 / Custom Widgets

### Paquetes Principales
```yaml
dependencies:
  flutter:  sdk: flutter
  provider: ^6.0.0          # Gestión de estado
  http: ^1.1.0              # Peticiones HTTP
  dio: ^5.0.0               # Cliente HTTP avanzado
  image_picker: ^1.0.0      # Selección de imágenes
  video_player: ^2.7.0      # Reproducción de videos
  audioplayers: ^5.0.0      # Reproducción de audio
  cached_network_image: ^3.2.0  # Cache de imágenes
  shared_preferences: ^2.2.0    # Almacenamiento local
  flutter_secure_storage: ^9.0.0  # Almacenamiento seguro
  intl: ^0.18.0             # Internacionalización
  timeline_tile: ^2.0.0     # Líneas de tiempo
```

---

## 📦 Instalación

### Prerrequisitos

```bash
# Flutter SDK (versión recomendada 3.x)
flutter --version

# Verificar instalación y dependencias
flutter doctor

# Debe mostrar:
# ✓ Flutter
# ✓ Android toolchain
# ✓ Xcode (para iOS, solo en macOS)
# ✓ Chrome (para desarrollo web)
# ✓ VS Code / Android Studio
```

### Requisitos del Sistema

- **Flutter**:  3.0.0 o superior
- **Dart**: 3.0.0 o superior
- **Android Studio**: 2021.1 o superior (para Android)
- **Xcode**: 14.0 o superior (para iOS, solo macOS)
- **iOS**: 11.0 o superior
- **Android**: API 21 (Android 5.0) o superior

### Configuración del Proyecto

1. **Clonar el repositorio**

```bash
git clone https://github.com/Grupo3-DP2-Lirium/Lirium-Front-AppMovil.git
cd Lirium-Front-AppMovil
```

2. **Instalar dependencias de Flutter**

```bash
flutter pub get
```

3. **Configurar variables de entorno**

```bash
# Crear archivo de configuración
cp lib/config/env.example. dart lib/config/env.dart

# Editar lib/config/env.dart con tus credenciales
```

```dart
// lib/config/env.dart
class Environment {
  static const String apiUrl = 'https://api.lirium.com';
  static const String apiKey = 'tu_api_key';
  static const String storageBucket = 'tu_bucket';
}
```

4. **Configurar Firebase (si aplica)**

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login en Firebase
firebase login

# Configurar FlutterFire
dart pub global activate flutterfire_cli
flutterfire configure
```

5. **Ejecutar en modo desarrollo**

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en Android
flutter run -d android

# Ejecutar en iOS
flutter run -d ios

# Ejecutar en Chrome (web)
flutter run -d chrome

# Modo debug con hot reload automático
flutter run --hot
```

---

## 🚀 Uso

### Inicio Rápido

1. **Registro de Usuario**
   - Abre la aplicación
   - Selecciona "Crear cuenta"
   - Completa el formulario de registro
   - Verifica tu email

2. **Crear tu Primer Recuerdo**
   - Toca el botón "+" en la pantalla principal
   - Selecciona el tipo de contenido (texto, imagen, audio, video)
   - Añade título, descripción y etiquetas
   - Guarda el recuerdo

3. **Organizar Recuerdos**
   - Accede a la sección "Línea de Tiempo"
   - Visualiza tus recuerdos organizados cronológicamente
   - Filtra por temáticas o momentos específicos

4. **Compartir un Memorial**
   - Crea o accede a un memorial
   - Toca "Compartir"
   - Invita a colaboradores por email
   - Configura permisos de visualización/edición

### Funcionalidades Avanzadas

#### Generación de Contenido con IA
```
1. Selecciona múltiples recuerdos
2. Toca "Generar Video"
3. Elige plantilla y música
4. La IA creará automáticamente un video compilado
```

#### Gestión de Suscripciones
- **Plan Gratuito**: 100 recuerdos, 5GB almacenamiento
- **Plan Premium**:  Recuerdos ilimitados, 100GB, IA avanzada
- **Plan Familiar**: Hasta 5 usuarios, 500GB compartidos

---

## 📸 Capturas

### Pantalla Principal
![Pantalla Principal](https://cdn.discordapp.com/attachments/1301045138868670495/1456899142730252491/image.png?ex=695a0a8f&is=6958b90f&hm=7460eea989f35d39a0f5f2b8b1f24ad2196eab5a3de52597997d09ecdefece92&)

### Creación de Recuerdo
![Crear Recuerdo](https://media.discordapp.net/attachments/1301045138868670495/1456900475717681152/59d451d9-8694-4fc0-bf33-462b1bd0f68d.png?ex=695a0bcd&is=6958ba4d&hm=2bbbfcfeff6cf50df8669aaa0f0c178a035b3b9f69ea3cfe4d5574c60e0f8bbb&=&format=webp&quality=lossless&width=491&height=1091)

![Crear Recuerdo 2](https://media.discordapp.net/attachments/1301045138868670495/1456901326658338892/image.png?ex=695a0c98&is=6958bb18&hm=81386528dc35c8ff3480f66832b2bb2b823690d8867bd8c4b4868347f732d296&=&format=webp&quality=lossless)

### Vista de Memorial
![Memorial](https://media.discordapp.net/attachments/1301045138868670495/1456900204631687260/5d4186d4-172b-470e-9c77-31a5e4e763ea.png?ex=695a0b8c&is=6958ba0c&hm=d25a6b8895b114316a0e9f59244554c0e82e3877d23aa492d0de0c7e03d25054&=&format=webp&quality=lossless&width=491&height=1091)

### Creación de Contenido (Capsulas y Documentales)
![Crear Recuerdo](https://media.discordapp.net/attachments/1301045138868670495/1456901539506421861/image.png?ex=695a0cca&is=6958bb4a&hm=25fabed26dab0b81ed1acf22f76a3dc88e1e61d28508d6ab424a410389a61aa1&=&format=webp&quality=lossless)

### Panel Administrativo
![Admin Dashboard](https://media.discordapp.net/attachments/1301045138868670495/1456901738207383694/image.png?ex=695a0cfa&is=6958bb7a&hm=a5f6aa41dd55e2fad7b16363eddf81b9c8129a88980f610084163cfa82dee5de&=&format=webp&quality=lossless)

---

## 🏗️ Arquitectura del Proyecto

```
Lirium-Front-AppMovil/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── app.dart                  # Configuración de la app
│   ├── config/                   # Configuración
│   │   ├── env.dart             # Variables de entorno
│   │   ├── routes.dart          # Rutas de navegación
│   │   └── theme.dart           # Tema y estilos
│   ├── core/                     # Funcionalidades core
│   │   ├── constants/           # Constantes
│   │   ├── errors/              # Manejo de errores
│   │   ├── utils/               # Utilidades
│   │   └── extensions/          # Extensiones de Dart
│   ├── data/                     # Capa de datos
│   │   ├── models/              # Modelos de datos
│   │   ├── repositories/        # Repositorios
│   │   ├── datasources/         # Fuentes de datos
│   │   └── providers/           # Providers de datos
│   ├── domain/                   # Lógica de negocio
│   │   ├── entities/            # Entidades
│   │   ├── usecases/            # Casos de uso
│   │   └── repositories/        # Interfaces de repositorios
│   ├── presentation/             # Capa de presentación
│   │   ├── screens/             # Pantallas
│   │   │   ├── auth/           # Autenticación
│   │   │   ├── home/           # Inicio
│   │   │   ├── memories/       # Recuerdos
│   │   │   ├── memorials/      # Memoriales
│   │   │   ├── profile/        # Perfil
│   │   │   └── admin/          # Admin
│   │   ├── widgets/             # Widgets reutilizables
│   │   │   ├── common/         # Comunes
│   │   │   ├── memory/         # De recuerdos
│   │   │   └── memorial/       # De memoriales
│   │   ├── providers/           # State management
│   │   └── bloc/                # BLoC (si se usa)
│   └── services/                 # Servicios
│       ├── api/                 # API service
│       ├── auth/                # Autenticación
│       ├── storage/             # Almacenamiento
│       └── ai/                  # Servicios de IA
├── assets/                       # Recursos
│   ├── images/                  # Imágenes
│   ├── icons/                   # Iconos
│   ├── fonts/                   # Fuentes
│   └── animations/              # Animaciones Lottie
├── test/                         # Tests unitarios
├── integration_test/             # Tests de integración
├── android/                      # Configuración Android
├── ios/                          # Configuración iOS
├── web/                          # Configuración Web
├── pubspec.yaml                  # Dependencias
└── analysis_options.yaml         # Reglas de análisis
```

---

## 🔨 Build & Deploy

### Android

```bash
# Build APK de debug
flutter build apk --debug

# Build APK de release
flutter build apk --release

# Build App Bundle (recomendado para Play Store)
flutter build appbundle --release

# Los archivos se generan en: 
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build para iOS (requiere macOS)
flutter build ios --release

# Abrir en Xcode para firmar y subir
open ios/Runner.xcworkspace
```

---

<p align="center">
  Hecho con ❤️ por el Equipo Lirium
</p>
