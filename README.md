# ⚠️ ATENCIÓN: NO HACER PUSH DIRECTO AL MAIN ⚠️

**¡MUY IMPORTANTE!**

- **NUNCA HAGAS PUSH DIRECTO A `main`**
- **SIEMPRE TRABAJA EN RAMAS `feature/...` O `develop`**
- **Crea tu rama feature desde `develop`**

---

# Guía de Despliegue Flutter — dispensxcore

Esta guía cubre todo el proceso para clonar, configurar y ejecutar la aplicación Flutter **dispensxcore**, desde los requisitos previos hasta las buenas prácticas de desarrollo y ramas.

## 1. Requisitos Previos

Antes de comenzar, asegúrate de tener instaladas las siguientes herramientas:

- **Flutter SDK** — [flutter.dev](https://flutter.dev/docs/get-started/install)  
  Añade la carpeta `flutter/bin` a la variable de entorno PATH y reinicia tu terminal.
- **VS Code** con las extensiones `Flutter` y `Dart`.
- **Git** para clonar el repositorio y gestionar ramas.
- **Android Studio** (opcional) para emuladores Android, o **Xcode** para simuladores iOS.
- **Node.js** para correr el mock con json-server.

## 2. Clonar el Repositorio

```bash
git clone https://github.com/1ASI0572-2610-17755-G4-DispenXCore/DispenXCore-Mobile-FrontEnd.git
cd dispensxcore
```

## 3. Instalar Dependencias

```bash
flutter pub get
```

## 4. Verificar el Entorno

```bash
flutter doctor
```

Resuelve cualquier advertencia antes de continuar.

## 5. Correr el Mock (json-server)

En este caso por ahora funciona con el db.json que esta en el frontend del proyecto en la carpeta server

El propio db.json esta siendo desplegado en render simplemente ejecute el proyecto que ya debe contener el link del render
```bash
'https://dispenxcore-web-frontend.onrender.com'
```

El proyecto usa **json-server** como backend mock mientras no haya backend real.  
Asegúrate de tenerlo corriendo antes de lanzar la app:

```bash
npx json-server --watch db.json --routes routes.json --port 3000
```

> El json-server puede ser compartido con el frontend web — ambos apuntan al mismo `db.json`.

## 6. Configurar la URL Base

Abre `lib/core/constants.dart` y descomenta la línea que corresponda a tu entorno:

```dart

// Actual db.json
const String BASE_URL = 'https://dispenxcore-web-frontend.onrender.com';
// Emulador Android
// const String BASE_URL = 'http://10.0.2.2:3000';

// Dispositivo físico (reemplaza con tu IP local — ejecuta `ipconfig` en Windows)
// const String BASE_URL = 'http://192.168.1.XXX:3000';

// iOS Simulator o Web
// const String BASE_URL = 'http://localhost:3000';
```

> **Importante:** `localhost` no funciona en emulador Android. Usa siempre `10.0.2.2`.

## 7. Ejecutar el Proyecto

```bash
flutter run
```

## 8. Actualizar Dependencias

```bash
flutter pub upgrade
```

## 9. Ramas y Buenas Prácticas

```bash
# Cambiar a develop
git checkout develop

# Crear tu rama feature
git checkout -b feature/nombre-de-la-funcionalidad

# Subir la rama al remoto
git push -u origin feature/nombre-de-la-funcionalidad
```

### Ramas por funcionalidad - EJEMPLOS DE ANTERIOR PROYECTO

ESTO ES UN EJEMPLO DEL PROYECTO ANTERIOR, NO SON LOS NOMBRES DEFINITIVOS

| Funcionalidad | Rama sugerida | Descripción |
|---|---|---|
| Auth | `feature/auth` | Login, registro y sesiones |
| Home | `feature/home` | Página principal |
| Chat | `feature/chat` | Mensajes en tiempo real |
| Plans & Benefits | `feature/plans-benefits` | Planes y suscripciones |
| Process | `feature/process` | Flujos de procesos internos |
| Profile | `feature/profile` | Perfil de usuario |
| Search | `feature/search` | Búsqueda de contenidos |

---

# Arquitectura del Proyecto

El proyecto sigue **Clean Architecture**, separando el código en capas con responsabilidades bien definidas. La regla principal es que las capas internas no conocen las externas.

```
lib/
├── main.dart
├── app/                      ← composición de la app
│   ├── router/
│   │   └── app_router.dart
│   └── pages/
│       └── main_page.dart
├── core/                     ← infraestructura transversal
│   ├── api/
│   │   └── api_client.dart
│   ├── constants.dart
│   ├── di/
│   │   └── injector.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── storage/
│       ├── token_storage.dart
│       └── token_storage_impl.dart
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
            ├── blocs/
            ├── pages/
            └── widgets/
```

## Capas de Clean Architecture

### Domain (centro — sin dependencias externas)
Es el núcleo de la app. No importa Flutter, ni http, ni ningún paquete externo.

- **entities/** — modelos de negocio puros (`User`, `Session`).
- **repositories/** — interfaces (contratos) que definen qué operaciones existen, sin implementarlas.
- **usecases/** — cada caso de uso es una clase con un solo método `call()`. Representan una acción concreta del usuario.

```
LoginUser.call(email, password) → Session
RegisterUser.call(email, password, ...) → User
```

### Data (implementa el domain)
Conecta la app con el mundo exterior (API, base de datos, storage).

- **datasources/** — hace las llamadas HTTP reales. Sabe del backend.
- **repositories/** — implementa los contratos del domain, orquesta datasources y storage.

### Presentation (lo que ve el usuario)
- **pages/** — pantallas completas.
- **widgets/** — componentes reutilizables dentro de una feature.
- **blocs/** — manejo de estado con BLoC/Cubit.

### Por qué esta separación importa
Si mañana cambia el backend, solo tocas `datasources/`. Si cambia el diseño, solo tocas `presentation/`. El `domain` nunca cambia.

---

# Core — Componentes Importantes

## ApiClient (`core/api/api_client.dart`)

Cliente HTTP centralizado. Todos los datasources lo usan para hacer requests.

- Construye URLs de forma segura (evita doble `/`).
- Adjunta el token `Bearer` automáticamente cuando `requiresAuth: true`.
- Incluye timeout de 30 segundos en todos los métodos.
- Métodos disponibles: `get`, `post`, `put`, `patch`, `delete`.

```dart
// Uso básico en un datasource
final response = await apiClient.get('/users', requiresAuth: true);
final response = await apiClient.post('/users', body: {...}, requiresAuth: false);
```

## TokenStorage (`core/storage/`)

Almacena de forma persistente los datos de sesión usando `SharedPreferences`.  
Es la única fuente de verdad para saber si el usuario está logueado.

Guarda: `token`, `userId`, `role`, `status`.

```dart
await tokenStorage.saveToken(token);
await tokenStorage.saveRole('ADMIN');

final role = await tokenStorage.getRole();  // 'ADMIN' | 'USER' | null
await tokenStorage.clearAll();              // logout
```

> El resto de datos del usuario (nombre, email) se piden al backend cuando se necesitan, no se guardan local.

## Injector (`core/di/injector.dart`)

Maneja la inyección de dependencias de forma manual y simple, sin librerías externas.  
Todas las instancias se crean una sola vez (singletons) al iniciar la app.

```dart
// Obtener cualquier dependencia registrada desde cualquier parte
final loginUser = injector<LoginUser>();
final apiClient = injector<ApiClient>();
```

**Para agregar una nueva dependencia** cuando incorpores un feature nuevo:

```dart
// 1. Crea las instancias en el bloque del feature correspondiente
final NuevoRemoteDataSource nuevoDataSource = NuevoRemoteDataSource(apiClient: apiClient);
final NuevoRepository nuevoRepository = NuevoRepositoryImpl(remoteDataSource: nuevoDataSource);
final NuevoUseCase nuevoUseCase = NuevoUseCase(nuevoRepository);

// 2. Regístrala en la función injector<T>()
if (T == NuevoUseCase) return nuevoUseCase as T;
```

---

# App — Navegación y Rutas

## AppRouter (`app/router/app_router.dart`)

Centraliza todas las rutas de la app. Cada pantalla nueva requiere:
1. Agregar un `case` en el `switch` con la ruta.
2. Importar la página correspondiente.

```dart
// Rutas actuales
'/login'    → LoginPage
'/register' → RegisterPage
'/main'     → MainPage (con bottom nav)
```

**Para agregar una ruta nueva:**

```dart
// En app_router.dart, dentro del switch:
case '/mi_nueva_ruta':
  return MaterialPageRoute(
    builder: (_) => MiNuevaPagina(
      miUseCase: injector<MiUseCase>(),
    ),
  );
```

**Para navegar desde cualquier pantalla:**

```dart
// Ir a una ruta (apilando)
Navigator.pushNamed(context, '/mi_nueva_ruta');

// Ir a una ruta reemplazando la actual (sin poder volver)
Navigator.pushReplacementNamed(context, '/main');

// Pasar argumentos
Navigator.pushNamed(context, '/detalle', arguments: {'id': 123});

// Recibirlos en la ruta
final args = settings.arguments as Map<String, dynamic>;
```

## MainPage (`app/pages/main_page.dart`)

Shell principal de la app con bottom navigation bar de 5 tabs.  
Actualmente las pantallas están en blanco (`SizedBox.shrink()`).  
Cada equipo reemplaza el `SizedBox.shrink()` correspondiente con su página.

```dart
List<Widget> _buildScreens() {
  return [
    // Reemplaza cada SizedBox.shrink() con tu página
    const HomePage(),      // Tab 0 — Home
    const SearchPage(),    // Tab 1 — Search
    const ProcessPage(),   // Tab 2 — Process
    const RewardsPage(),   // Tab 3 — Rewards
    const ProfilePage(),   // Tab 4 — Profile
  ];
}
```

---

# Feature: Auth

## Flujo de Login (mock con json-server)

```
LoginPage
  → LoginUser (usecase)
    → AuthRepository (contrato)
      → AuthRepositoryImpl
          → AuthRemoteDataSource → GET /users (json-server)
                                   filtra por email + password
                                   genera token: base64(email:role:timestamp)
          → TokenStorage → guarda token, userId, role, status
  → navega a /main según role
```

Cuando haya backend real, solo se cambia `AuthRemoteDataSource`: reemplaza el GET `/users` por un POST `/auth/sign-in` y listo. El resto de la cadena no se toca.

## Roles

El backend devuelve `role: 'ADMIN' | 'USER'`. La app lo lee del `TokenStorage` para tomar decisiones de navegación o mostrar/ocultar secciones.

```dart
final role = await tokenStorage.getRole();
if (role == 'ADMIN') { /* mostrar panel admin */ }
```

## Estructura de archivos

```
features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_data_source.dart   ← llama al backend
│   └── repositories/
│       └── auth_repository_impl.dart      ← orquesta datasource + storage
├── domain/
│   ├── entities/
│   │   ├── user.dart                      ← id, firstName, lastName, email, role, status
│   │   └── session.dart                   ← token + user
│   ├── repositories/
│   │   └── auth_repository.dart           ← contrato (interfaz)
│   └── usecases/
│       ├── login_user.dart
│       └── register_user.dart
└── presentation/
    ├── blocs/
    │   └── register_bloc.dart
    ├── pages/
    │   ├── login_page.dart
    │   └── register_page.dart
    └── widgets/
        └── text_field.dart                ← campo de texto reutilizable
```

## Nota sobre el botón "Acceso directo (dev)"

`login_page.dart` incluye un botón de acceso rápido que rellena las credenciales del admin del `db.json` y hace login automáticamente. **Solo aparece en debug mode** (`flutter run`), no en builds de producción.

Antes de presentar o hacer release, eliminar:
1. El método `_quickAccess()`
2. El import de `package:flutter/foundation.dart`
3. El bloque `if (kDebugMode)` en el `build()` — está marcado con comentarios en el archivo