<div align ="center">

## Autovitae - Sistema de gestion de talleres y servicios de mantenimiento para clientes y gerentes

</div>

A new Flutter project.

## Instalacion

En esta sección se explica el proceso de instalación de todas las dependencias necesarias para ejecutar el proyecto.

### 📦 Requerimientos de Instalacion

- [Git](https://git-scm.com)
- [Visual Studio Code](https://code.visualstudio.com)
- [Flutter](https://docs.flutter.dev/install/manual)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio)

### 📝 Clonar Repositorio

```sh
git clone https://github.com/RicardoVillamar/autovitae_flutter.git
cd autovitae_flutter
```

o tambien puedes decargar el zip de la ultima release/Commit del Repositorio

### 📲 Instalacion de Dependencia

```sh
flutter pub get
```

### Iniciarlizar Firebase

```sh

  dart pub global activate flutterfire_cli
  flutterfire configure --project=nombre-de-tu-proyecto
```

### 🖥️ Variables de Entorno .env

Actualmente tenemos un archivo `.env-template` copie el archivo y cambie el nombre por `.env`

ejemplo del contenido del archivo `.env`

### Generar el Report del Gradlew

```
  cd android && ./gradlew signingReport
```

### Modulos

- auth: Modulo de autenticacion de usuarios []
- cliente: Modulo de gestion de clientes []
- gerentes: Modulo de gestion de gerentes []
- talleres: Modulo de gestion de talleres []
- vehiculos: Modulo de gestion de vehiculos de los clientes []
- servicios: Modulo de gestion de servicios en el taller [.]
- mantenimiento: Modulo de gestion de mantenimiento de vehiculos [.]
- facturacion: Modulo de gestion de facturacion [.]
