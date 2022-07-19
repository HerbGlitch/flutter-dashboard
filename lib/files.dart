import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get localRoot async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/pocket';
}

Future<File> localFile(String path) async {
    final root = await localRoot;
    return File('$root/$path');
}

Future<String> readFile(String path) async {
    final file = await localFile(path);
    return file.readAsString();
}

Future<File> writeFile(String path, String data) async {
    final file = await localFile(path);
    return file.writeAsString(data);
}

Future<File> renameFile(String oldPath, String path) async {
    final file = await localFile(oldPath);
    final root = await localRoot;
    return await file.rename('$root/$path');
}

Future deleteFile(String path) async {
    final file = await localFile(path);
    file.delete();
}

Future localInit() async {
    final root = await localRoot;

    Directory directory = Directory(root);
    if(!await directory.exists()){
        await directory.create();
    }

    final file = await localFile('decks.pocket');
    if(!await file.exists()){
        file.create();
    }
}