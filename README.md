# RedFugio · Frontend en Flutter

RedFugio es un proyecto cuyo objetivo es facilitar la búsqueda de recursos cercanos para personas sin hogar: comedores sociales, albergues, duchas, roperos, atención sanitaria, orientación laboral y puntos de carga de móvil.

La aplicación está pensada para las propias personas usuarias, ciudadanos que quieran ayudar y profesionales o entidades sociales. El proyecto completo contempla un mapa con OpenStreetMap, búsqueda por necesidad y proximidad, información de horarios y plazas, y funciones de emergencia. El diseño previsto prioriza la facilidad de uso y el bajo consumo de datos.

Este directorio contiene el **frontend de la primera entrega**, centrado en el registro, la autenticación por roles y la administración de usuarios mediante una API REST.

## Funcionalidades implementadas

### Registro e inicio de sesión

- Registro con nombre, correo electrónico, contraseña y confirmación de contraseña.
- Selección del tipo de cuenta: usuario, profesional/entidad o voluntario.
- Campo obligatorio de organización para las cuentas profesionales.
- Validación de campos, formato del correo, contraseña de al menos ocho caracteres y coincidencia de contraseñas.
- Inicio de sesión con mensajes de error y estado de carga.
- Navegación según el rol: el administrador accede a la gestión de usuarios y los demás perfiles a una pantalla de inicio básica.
- Almacenamiento del token mediante `flutter_secure_storage` y cierre de sesión con eliminación del token local.

El registro no inicia sesión automáticamente. El acceso está condicionado a la confirmación del correo y a la activación administrativa que comprueba el backend. La aplicación informa de estos estados cuando la API rechaza el login.

### Panel de administración

- Listado de usuarios, excluyendo las cuentas administradoras.
- Activación y desactivación de cuentas.
- Confirmación de la verificación de una entidad antes de activar una cuenta profesional. La comprobación de la entidad es manual.
- Eliminación de usuarios con un diálogo de confirmación previo.
- Edición del nombre del usuario, que es el campo admitido por el endpoint de actualización documentado.
- Acciones accesibles al deslizar cada fila mediante `flutter_slidable`.
- Actualización del listado después de las operaciones y mensajes con su resultado.

### Roles

| Código | Perfil | Comportamiento en esta entrega |
| --- | --- | --- |
| `u` | Persona usuaria | Registro y acceso a la pantalla de inicio. |
| `p` | Profesional o entidad colaboradora | Registro con organización y verificación manual antes de la activación. |
| `v` | Persona viandante | En el formulario actual aparece como «Voluntario» y se envía con el código `v`. |
| `a` | Administrador | Acceso al panel de gestión de usuarios. No se ofrece en el formulario de registro. |

## Tecnologías utilizadas

| Tecnología | Uso |
| --- | --- |
| Flutter y Dart | Interfaz, formularios y navegación. |
| Provider y `ChangeNotifier` | Gestión del estado de autenticación y de usuarios. |
| Dio | Peticiones HTTP a la API REST. |
| `flutter_secure_storage` | Almacenamiento local del token de acceso. |
| `flutter_slidable` | Acciones deslizables del listado de administración. |
| Git y GitHub | Control de versiones, ramas e integración mediante pull requests. |
| Trello | Tablero de organización del proyecto. |

## Estructura del frontend

```text
lib/
├── main.dart                         # Inicio, providers y navegación por rol
├── Front-end/
│   ├── login_page.dart               # Inicio de sesión
│   ├── sign_up.dart                  # Registro
│   ├── admin_page.dart               # Gestión de usuarios
│   └── home.dart                     # Inicio básico y cierre de sesión
├── core/
│   └── storage/
│       └── token_storage.dart        # Guardar, leer y eliminar el token
└── features/
    ├── authentication/
    │   ├── models/user_model.dart    # Modelo de usuario y roles
    │   ├── providers/auth_provider.dart
    │   └── services/api_service.dart # Comunicación HTTP con la API
    └── users/
        └── providers/user_provider.dart
```

Hemos separado las pantallas, el estado de la aplicación y la comunicación con el servidor. Las vistas recogen los datos e invocan a los providers; estos coordinan las operaciones con `ApiService` y notifican los cambios para actualizar la interfaz.

`AuthProvider` gestiona el login, el registro, el usuario actual y el token. `UserProvider` mantiene el listado de usuarios y coordina las acciones administrativas. `UserModel` convierte los datos JSON del servidor en objetos Dart.

## API REST y conexión con el backend

El frontend utiliza la API REST de RedFugio v1.0 proporcionada para el proyecto. La aplicación accede a los datos a través de esta API; el backend se encarga de procesar las operaciones y comunicarse con la base de datos.

La URL base se configura en `lib/features/authentication/services/api_service.dart`:

```dart
final Dio _dio = Dio(
  BaseOptions(
    baseUrl: 'https://redfugioapi.iaknowhow.es/public/api',
    headers: {'Accept': 'application/json'},
  ),
);
```

Todas las rutas de la tabla se añaden a esa URL base:

| Método | Ruta | Datos enviados | Uso del token en el frontend |
| --- | --- | --- | --- |
| `POST` | `/register` | `name`, `email`, `password`, `c_password`, `role`, `organization_name` | Sin token. |
| `POST` | `/login` | `email`, `password` | Sin token; obtiene el token de acceso. |
| `GET` | `/users` | Sin cuerpo. | Token del administrador. |
| `POST` | `/activate` | `id` | Token del administrador. |
| `POST` | `/deactivate` | `id` | Token del administrador. |
| `POST` | `/deleteUser` | `id` | Token del administrador. |
| `POST` | `/updateUser` | `id`, `name` | Token del administrador. |

En el registro, la interfaz comprueba que las contraseñas coincidan y el servicio envía la contraseña también como `c_password`. El nombre de organización se envía para el perfil `p`; en los demás casos se envía una cadena vacía.

### Flujo de autenticación

1. La persona introduce sus credenciales y la pantalla valida el formulario.
2. `AuthProvider` llama a `ApiService`, que realiza `POST /login` mediante Dio.
3. Si la respuesta contiene `success: true`, se obtiene el token de `data.token` y se construye el usuario actual a partir de `data`.
4. El token se guarda mediante `AlmacenamientoToken` y `flutter_secure_storage`.
5. La interfaz se actualiza según el rol recibido. Las operaciones de gestión incluyen el token en la cabecera de autorización:

```dart
options: Options(
  headers: {'Authorization': 'Bearer $token'},
),
```

Por ejemplo, el listado de usuarios se solicita con `GET /users`. El servicio convierte los elementos de `data` en una lista de `UserModel`, el provider guarda esa lista y la pantalla de administración la muestra.

La API utiliza los campos `success`, `data` y `message` en sus respuestas. El frontend comprueba el resultado y transforma errores de acceso como credenciales incorrectas, correo sin confirmar, cuenta pendiente de activación o cuenta eliminada en mensajes para la persona usuaria. También captura errores de conexión mediante `DioException`.

Al cerrar sesión se eliminan el token guardado y el usuario en memoria. Aunque al abrir la aplicación se recupera el token almacenado, todavía no se reconstruye el usuario actual desde el servidor; por ello, guardar el token no supone restaurar automáticamente una sesión completa.

**Diferencias entre documentación e implementación:** el PDF de la API v1.0 incluye una cabecera de autorización en la descripción de `/register`, pero el frontend actual realiza el registro sin token. Además, la primera entrega contempla el rol `v`, utilizado por el formulario, aunque no aparece entre los roles enumerados en ese apartado del PDF de la API. Estas diferencias deben tenerse en cuenta al comprobar la compatibilidad con el servidor.

## Cómo hemos organizado el trabajo

Hemos desarrollado el frontend de forma progresiva: primero incorporamos la comunicación con la API y los providers; después añadimos las pantallas de registro y login, conectamos los formularios con el servidor y completamos la gestión de usuarios. El historial también recoge ajustes de conexión, resolución de conflictos y limpieza del código.

Para integrar los cambios hemos utilizado ramas y pull requests en [GitHub](https://github.com/ncruzcordon-blip/RedFugio). El repositorio contiene estas ramas:

| Rama | Papel observado en el repositorio |
| --- | --- |
| `main` | Rama principal en la que se han integrado cambios mediante pull requests. |
| `Entrega1` | Rama de trabajo de la primera entrega, integrada repetidamente en `main`. También ha recibido cambios de `main` para sincronizar el trabajo. |
| `rama_ayuda` | Rama utilizada para correcciones y ajustes de conexión, integrados mediante pull requests. |
| `API`, `providers`, `vistas` | Ramas cuyos nombres corresponden a áreas del frontend. En la revisión del repositorio, las tres apuntan al mismo commit. |

El historial muestra, por ejemplo, la integración de ajustes desde `rama_ayuda` en las pull requests #7 y #8 y sucesivas integraciones de `Entrega1` en `main`. Este proceso nos ha permitido reunir los cambios del equipo y resolver los problemas que surgían al conectar la interfaz, los providers y la API.

El tablero del proyecto está disponible en [Trello](https://trello.com/b/6afea682077201544506ba66/redfugio-programacion).

## Instalación y ejecución

### Requisitos

- Flutter instalado y configurado para el dispositivo o plataforma de destino.
- Un SDK de Flutter que incluya Dart compatible con `^3.13.3`, según `pubspec.yaml`. El archivo `pubspec.lock` actual requiere Flutter `>=3.47.0`.
- Un dispositivo, emulador o navegador compatible y conexión con la API.

Desde una terminal:

```bash
git clone https://github.com/ncruzcordon-blip/RedFugio.git
cd RedFugio
git switch Entrega1
cd redfugio_frontend2
flutter doctor
flutter pub get
flutter run
```

Para elegir un destino, consulta `flutter devices` y ejecuta `flutter run -d <id_del_dispositivo>`.

La URL del backend está definida directamente en `ApiService`; actualmente no se configura mediante un archivo `.env`. Para utilizar otro servidor hay que modificar `baseUrl` en ese archivo. La cuenta utilizada para acceder deberá cumplir las condiciones de verificación y activación del backend; el panel administrativo requiere una cuenta con rol `a`.

## Estado y siguientes fases

La primera entrega proporciona la base de autenticación y administración. La pantalla `Home` de los perfiles no administradores es todavía una vista básica con cierre de sesión.

El mapa con OpenStreetMap, la geolocalización, el filtrado y mantenimiento de recursos, el modo sin conexión, las derivaciones, las notificaciones y los reportes forman parte del alcance general previsto y todavía no están implementados en este frontend.

El directorio `test/` conserva la prueba de contador de la plantilla inicial de Flutter; aún no hay una suite de pruebas adaptada a las funcionalidades de RedFugio.

## Organización del trabajo en Trello

Hemos utilizado Trello para organizar las tareas y reflejar el avance del proyecto. Las tareas finalizadas corresponden al frontend desarrollado en Flutter durante esta primera entrega, centrada en el registro, el inicio de sesión, la conexión con la API REST y la gestión de usuarios.

Las listas situadas a la izquierda recogen la planificación de las próximas fases de la aplicación. Estas tareas representan trabajo pendiente y sirven como guía para continuar incorporando las funcionalidades previstas de RedFugio. Así, el tablero permite distinguir lo que ya hemos completado de los siguientes pasos del desarrollo.

Enlace a trello: https://trello.com/invite/b/6afea682077201544506ba66/ATTI93bf8ce8864d6a0d203e3f1fb58c3001EE77C799/redfugio-programacion .