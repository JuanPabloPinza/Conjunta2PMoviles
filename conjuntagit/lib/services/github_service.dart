import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GithubService {
  final String repoOwner = "JuanPabloPinza"; // Reemplaza con tu usuario
  final String repoName = "verduras-crud"; // Reemplaza con tu repositorio
  final String branch = "main"; // Rama del repositorio
  final String filePath = "verduras.json"; // Ruta del archivo JSON en el repo
  final String personalAccessToken =
      "PONERAQUÍDIRECCION DE TOKEN"; // Tu token personal

  // URL del archivo crudo en GitHub
  String get rawFileUrl =>
      "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch/$filePath";

  // Obtener el contenido actual del archivo
  Future<List<dynamic>> fetchVerduras() async {
    final response = await http.get(Uri.parse(rawFileUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("No se pudo cargar el archivo JSON");
    }
  }

  // Actualizar el archivo en GitHub
  Future<void> updateJsonFile(List<dynamic> verduras) async {
    final apiUrl =
        "https://api.github.com/repos/$repoOwner/$repoName/contents/$filePath";

    // Obtener el SHA del archivo actual para poder actualizarlo
    final getFileResponse = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $personalAccessToken",
      },
    );

    if (getFileResponse.statusCode != 200) {
      throw Exception("No se pudo obtener el archivo en GitHub");
    }

    final fileData = json.decode(getFileResponse.body);
    final sha = fileData['sha'];

    // Preparar el contenido actualizado
    final newContent = base64.encode(utf8.encode(json.encode(verduras)));

    // Realizar la actualización
    final updateResponse = await http.put(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $personalAccessToken",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "message": "Actualizar verduras.json desde la app",
        "content": newContent,
        "sha": sha,
      }),
    );

    if (updateResponse.statusCode != 200) {
      throw Exception("No se pudo actualizar el archivo en GitHub");
    }
  }
}
