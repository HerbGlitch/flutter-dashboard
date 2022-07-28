import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get localRoot async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/pocket';
}

Future<String> get localImgRoot async {
    final root = await localRoot;
    return '$root/img';
}

Future<File> localFile(String path) async {
    final root = await localRoot;
    return File('$root/$path');
}

Future<File> localImgFile(String path) async {
    final root = await localImgRoot;
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

Future<File> copyImgFile(String originalPath, String copyPath) async {
    final file = await localImgFile(copyPath);
    return file.writeAsBytes(File(originalPath).readAsBytesSync());
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

Future deleteImgFile(String path) async {
    final file = await localImgFile(path);
    file.delete();
}

Future localInit() async {
    final root = await localRoot;

    Directory directory = Directory(root);
    if(!await directory.exists()){
        await directory.create();
    }

    final imgRoot = await localImgRoot;
    Directory imgDirectory = Directory(imgRoot);
    if(!await imgDirectory.exists()){
        await imgDirectory.create();
    }

    final file = await localFile('decks.pocket');
    if(!await file.exists()){
        file.create();
    }
}