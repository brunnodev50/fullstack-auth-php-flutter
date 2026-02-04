import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  // ============================================================
  // CONFIGURAÇÃO - Altere aqui sua URL base
  // ============================================================
  static const String baseUrl = 'https://bruteste.cloud';
  static const String apiUrl = '$baseUrl/api';
  
  // Timeout para requisições
  static const Duration timeout = Duration(seconds: 30);

  // Headers padrão para JSON
  Map<String, String> get _jsonHeaders => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // ============================================================
  // LOGIN
  // ============================================================
  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiUrl/login.php'),
            headers: _jsonHeaders,
            body: jsonEncode({"email": email, "senha": senha}),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================
  Future<Map<String, dynamic>> register(String nome, String email, String senha) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiUrl/register.php'),
            headers: _jsonHeaders,
            body: jsonEncode({"nome": nome, "email": email, "senha": senha}),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ============================================================
  // ESQUECI SENHA
  // ============================================================
  Future<Map<String, dynamic>> esqueciSenha(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiUrl/esqueci_senha.php'),
            headers: _jsonHeaders,
            body: jsonEncode({"email": email}),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ============================================================
  // REDEFINIR SENHA
  // ============================================================
  Future<Map<String, dynamic>> redefinirSenha(String email, String codigo, String senha) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiUrl/redefinir_senha.php'),
            headers: _jsonHeaders,
            body: jsonEncode({"email": email, "codigo": codigo, "senha": senha}),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ============================================================
  // GET USER
  // ============================================================
  Future<Map<String, dynamic>> getUser(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl/get_user.php?id=$id'))
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ============================================================
  // UPDATE PROFILE (COM FOTO) - CORRIGIDO
  // ============================================================
  Future<Map<String, dynamic>> updateProfile({
    required String id,
    required String nome,
    required String email,
    String? senha,
    XFile? image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/update_profile.php'),
      );

      // Campos obrigatórios
      request.fields['id'] = id;
      request.fields['nome'] = nome;
      request.fields['email'] = email;

      // Senha (opcional)
      if (senha != null && senha.isNotEmpty) {
        request.fields['senha'] = senha;
      }

      // Foto (opcional) - CORREÇÃO PRINCIPAL
      if (image != null) {
        final file = File(image.path);
        
        if (await file.exists()) {
          // Obtém extensão e define MIME type
          final ext = image.path.split('.').last.toLowerCase();
          MediaType? mediaType;
          
          switch (ext) {
            case 'jpg':
            case 'jpeg':
              mediaType = MediaType('image', 'jpeg');
              break;
            case 'png':
              mediaType = MediaType('image', 'png');
              break;
            case 'gif':
              mediaType = MediaType('image', 'gif');
              break;
            case 'webp':
              mediaType = MediaType('image', 'webp');
              break;
            default:
              mediaType = MediaType('image', 'jpeg');
          }

          // Adiciona o arquivo com nome e content-type corretos
          request.files.add(
            await http.MultipartFile.fromPath(
              'foto', // IMPORTANTE: deve ser igual ao $_FILES['foto'] no PHP
              image.path,
              filename: 'foto_${id}_${DateTime.now().millisecondsSinceEpoch}.$ext',
              contentType: mediaType,
            ),
          );
        }
      }

      // Envia a requisição
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> 
          ? data 
          : {"success": false, "message": "Resposta inválida do servidor"};
    } catch (e) {
      return {"success": false, "message": "Erro ao processar resposta: ${response.body}"};
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    if (error is SocketException) {
      return {"success": false, "message": "Sem conexão com a internet"};
    } else if (error.toString().contains('TimeoutException')) {
      return {"success": false, "message": "Tempo de conexão esgotado"};
    }
    return {"success": false, "message": "Erro de conexão: $error"};
  }
}
