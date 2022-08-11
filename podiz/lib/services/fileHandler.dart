import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileHandler {
  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> localFile(String fileName) async {
    final path = await localPath;
    return File('$path/$fileName');
  }

  static Future<File> writeToFile(var obj, String fileName) async {
    String json = jsonEncode(obj);
    File file = await localFile(fileName);

    return file.writeAsString(json);
  }

  static Future<File> saveImgToFile(Uint8List imgBytes, String fileName) async {
    File file = await localFile(fileName);
    return file.writeAsBytes(imgBytes);
  }

  static Future<bool> fileExists(String filename) async {
    return (await localFile(filename)).exists();
  }

  static Future<FileSystemEntity?> deleteFile(String filename) async {
    if (!await fileExists(filename)) return null;
    return (await localFile(filename)).delete();
  }

  static Future<Map<String, dynamic>?> readFromFile(String filename) async {
    try {
      final file = await localFile(filename);

      final contents = await file.readAsString();
      final objMap = jsonDecode(contents);

      return objMap;
    } catch (e) {
      return null;
    }
  }
}
