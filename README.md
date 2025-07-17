# prueba3appmoviles


# 📋 App de Lista de Tareas (To-Do) con Flutter y Firebase

Esta aplicación móvil permite a los usuarios gestionar sus tareas personales y tareas compartidas, con autenticación segura mediante correo electrónico y contraseña usando Firebase. Incluye subida de imágenes, verificación de correo, y una interfaz moderna y responsiva.

## 🚀 Características principales

- **Autenticación de usuarios:** Registro, inicio de sesión y verificación de correo electrónico con Firebase Auth.
- **Gestión de tareas:** Visualiza tus tareas y tareas compartidas en una sola interfaz.
- **Creación de tareas:** 
  - Título
  - Estado (pendiente o completada)
  - Foto (desde galería o cámara, almacenada como base64)
  - Fecha de publicación (automática o seleccionada)
- **Actualización de tareas:** Marca tareas como completadas y registra quién las completó.
- **Interfaz moderna:** Diseño responsivo, colores personalizados, tarjetas y botones estilizados.
- **Cierre de sesión seguro.**

## 🛠️ Tecnologías usadas

- [Flutter](https://flutter.dev/)
- [Firebase Auth](https://firebase.google.com/products/auth)
- [Cloud Firestore](https://firebase.google.com/products/firestore)
- [image_picker](https://pub.dev/packages/image_picker)

## 📱 Capturas de pantalla

Registro 

> _Registro ._
> 
> <img width="1904" height="681" alt="image" src="https://github.com/user-attachments/assets/df1737c0-a407-4c8b-9a76-9a7a1e1cf028" />


<img width="1896" height="669" alt="image" src="https://github.com/user-attachments/assets/887ba946-f9d7-4732-b818-9694746568da" />


<img width="1901" height="590" alt="image" src="https://github.com/user-attachments/assets/46635c5a-8781-4f87-be1e-2c7d8eb074e9" />


<img width="776" height="130" alt="image" src="https://github.com/user-attachments/assets/a4fd3dcb-fa86-4ee3-8d07-0938adb1f9e5" />


<img width="393" height="208" alt="image" src="https://github.com/user-attachments/assets/7d4ef83a-644b-48be-85cb-12f3d99d8b34" />


<img width="946" height="165" alt="image" src="https://github.com/user-attachments/assets/3dc58a28-aed9-43e8-8c21-805f7a1fc05b" />


> _Login._
> <img width="1911" height="681" alt="image" src="https://github.com/user-attachments/assets/9bffff17-330f-4301-8ce0-703aec7a1f83" />

> _ Page Tareas._
><img width="1904" height="951" alt="image" src="https://github.com/user-attachments/assets/97ef6681-13ec-4917-b8e4-478a622d3d4a" />

<img width="1901" height="949" alt="image" src="https://github.com/user-attachments/assets/a0b687b5-bfc3-4a76-9db2-e5bb15932824" />





> _Formulario Tareas._
> 
> <img width="694" height="624" alt="image" src="https://github.com/user-attachments/assets/8159aaaa-51ca-4e02-b86c-2959bac81be0" />

> _Transacciones en Firebase._
Id del usuario 
><img width="927" height="91" alt="image" src="https://github.com/user-attachments/assets/c797b667-8f09-4902-b5f9-fb1eaf0de0a0" />

Creacion de los campos necesarios en la BDD en Firebase

> _BDD Firebase._
><img width="1523" height="387" alt="image" src="https://github.com/user-attachments/assets/b7bb02e1-89a7-493e-8efb-a7b6fe94df6f" />

## ⚙️ Instalación y ejecución

1. **Clona el repositorio:**
   ```sh
   [git clone https://github.com/tuusuario/tu-repo-tareas.git](https://github.com/GuamanFrancis/Prueba-TO-DO-.git)
   cd tu-repo-tareas
   ```

2. **Instala las dependencias:**
   ```sh
   flutter pub get
   ```

3. **Configura Firebase:**
   - Descarga tu archivo `google-services.json` (Android) y/o `GoogleService-Info.plist` (iOS) desde la consola de Firebase y colócalos en las carpetas correspondientes.
   - Asegúrate de tener el archivo `lib/firebase_options.dart` generado por FlutterFire CLI.

4. **Ejecuta la app:**
   ```sh
   flutter run
   ```

5. **Para generar el APK:**
   ```sh
   flutter build apk --release
   ```
   El archivo estará en `build/app/outputs/flutter-apk/app-release.apk`.

## 📝 Notas

- El proyecto está listo para ejecutarse en Android, iOS y Web.
- Para probar la autenticación por correo, debes verificar tu email antes de poder acceder a las tareas.
- Las imágenes de las tareas se almacenan en base64 en Firestore.

## 👨‍💻 Autor

- [Francis Guaman
](https://github.com/GuamanFrancis
)

---

¡Gracias por probar esta app!
