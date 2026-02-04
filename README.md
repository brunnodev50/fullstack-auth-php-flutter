# 🔐 Fullstack Auth - PHP + Flutter

Sistema completo de autenticação com backend em **PHP** e aplicativo mobile em **Flutter**.

![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)

---

## 📱 Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/72376198-89f6-467c-a3bd-252b1fbb1908" width="200" alt="Login">
  <img src="https://github.com/user-attachments/assets/c82b060b-66c2-4448-9723-b54a9404cb5c" width="200" alt="Cadastro">
  <img src="https://github.com/user-attachments/assets/0595813e-33cf-4637-a397-a7af61e86fbc" width="200" alt="Dashboard">
  <img src="https://github.com/user-attachments/assets/3422f0ac-7a17-4c31-9cf5-c4f43e2fda63" width="200" alt="Perfil">
</p>

---

## ✨ Funcionalidades

### 🔑 Autenticação
- Login com e-mail e senha
- Cadastro de novos usuários
- Recuperação de senha por e-mail (código de 6 dígitos)
- Redefinição de senha

### 👤 Perfil do Usuário
- Visualização de dados do perfil
- Edição de nome e e-mail
- Alteração de senha
- Upload de foto de perfil (câmera ou galeria)

### 📊 Dashboard
- Contador de acessos
- Status da conta (ativo/inativo)
- Menu de navegação

---

## 🏗️ Estrutura do Projeto

```
fullstack-auth-php-flutter/
├── api/                          # Backend PHP
│   ├── config_api.php            # Configuração do banco de dados
│   ├── login.php                 # Endpoint de login
│   ├── register.php              # Endpoint de cadastro
│   ├── get_user.php              # Endpoint para buscar usuário
│   ├── update_profile.php        # Endpoint para atualizar perfil
│   ├── esqueci_senha.php         # Endpoint para solicitar código
│   ├── redefinir_senha.php       # Endpoint para redefinir senha
│   └── PHPMailer/                # Biblioteca para envio de e-mails
│
├── flutter_app/                  # Frontend Flutter
│   └── lib/
│       ├── main.dart             # Entrada do app
│       ├── core/
│       │   └── theme/
│       │       ├── app_colors.dart
│       │       └── app_theme.dart
│       ├── services/
│       │   └── api_service.dart  # Comunicação com API
│       ├── widgets/
│       │   ├── app_text_field.dart
│       │   ├── app_button.dart
│       │   └── app_widgets.dart
│       └── screens/
│           ├── login_screen.dart
│           ├── register_screen.dart
│           ├── dashboard_screen.dart
│           ├── profile_screen.dart
│           ├── forgot_password_screen.dart
│           └── reset_password_screen.dart
│
├── database/
│   └── schema.sql                # Script do banco de dados
│
└── README.md
```

---

## 🗄️ Banco de Dados

### Criar o banco de dados

```sql
CREATE DATABASE IF NOT EXISTS `seu_banco` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `seu_banco`;

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `foto` varchar(255) DEFAULT 'assets/default.png',
  `token_reset` varchar(10) DEFAULT NULL,
  `token_expira_em` datetime DEFAULT NULL,
  `acessos` int(11) DEFAULT 0,
  `status` varchar(20) DEFAULT 'ativo',
  `criado_em` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## ⚙️ Configuração

### Backend (PHP)

1. **Copie a pasta `api/` para seu servidor web**

2. **Configure o banco de dados** em `api/config_api.php`:
```php
$host = 'localhost';
$db   = 'seu_banco';
$user = 'root';
$pass = 'sua_senha';
```

3. **Configure o envio de e-mail** em `api/esqueci_senha.php`:
```php
$mail->Host       = 'smtp.seuhost.com';
$mail->Username   = 'seu@email.com';
$mail->Password   = 'sua_senha';
```

4. **Crie a pasta para fotos de perfil**:
```bash
mkdir -p perfil/fotos
chmod 777 perfil/fotos
```

### Frontend (Flutter)

1. **Clone o repositório**:
```bash
git clone https://github.com/brunnodev50/fullstack-auth-php-flutter.git
cd fullstack-auth-php-flutter/flutter_app
```

2. **Instale as dependências**:
```bash
flutter pub get
```

3. **Configure a URL da API** em `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://sua-url.com';
```

4. **Execute o app**:
```bash
flutter run
```

---

## 📱 Configurações Android

### AndroidManifest.xml
Adicione as permissões em `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    
    <application
        android:requestLegacyExternalStorage="true"
        ...
```

### build.gradle.kts
Configure o SDK em `android/app/build.gradle.kts`:

```kotlin
android {
    compileSdk = 36
    
    defaultConfig {
        minSdk = 21
        targetSdk = 36
    }
}
```

---

## 🍎 Configurações iOS

Adicione em `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Necessário para foto de perfil</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necessário para foto de perfil</string>
```

---

## 📦 Dependências Flutter

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  http_parser: ^4.0.2
  image_picker: ^1.0.4
  cupertino_icons: ^1.0.6
```

---

## 🔌 Endpoints da API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | `/api/login.php` | Autenticação do usuário |
| POST | `/api/register.php` | Cadastro de novo usuário |
| GET | `/api/get_user.php?id={id}` | Buscar dados do usuário |
| POST | `/api/update_profile.php` | Atualizar perfil (multipart) |
| POST | `/api/esqueci_senha.php` | Solicitar código de recuperação |
| POST | `/api/redefinir_senha.php` | Redefinir senha com código |

### Exemplos de Requisição

**Login:**
```json
POST /api/login.php
{
  "email": "usuario@email.com",
  "senha": "123456"
}
```

**Resposta:**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "nome": "João Silva",
    "email": "usuario@email.com",
    "foto": "perfil/fotos/1/foto.jpg",
    "acessos": 5,
    "status": "ativo"
  }
}
```

---

## 🎨 Customização

### Cores
Edite `lib/core/theme/app_colors.dart`:

```dart
class AppColors {
  static const primary = Color(0xFF6366F1);    // Cor principal
  static const secondary = Color(0xFF10B981);  // Cor de sucesso
  static const danger = Color(0xFFEF4444);     // Cor de erro
  // ...
}
```

---

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

**Brunno Henrique Vilas Boas**

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/brunnodev50)

---

## ⭐ Apoie o Projeto

Se este projeto te ajudou, deixe uma ⭐ no repositório!
