import 'dart:io';

import 'package:filemanager/providers/_providers.dart';
import 'package:filemanager/bootstrap.dart';
import 'package:filemanager/models/_models.dart';

class StorageFacade {
  //
  static Future<List<StorageModel>> getStorages() async {
    CoreProvider coreProvider = new CoreProvider();
    await coreProvider.checkSpace();

    List<FileSystemEntity> storages = coreProvider.availableStorage;
    List<StorageModel> _storages = [];

    if (storages.length == 0) return [];

    _storages.add(StorageModel(
      name: 'Internal Memory',
      icon: Icons.phone_iphone,
      fullpath: storages[0].parent.parent.parent.parent.path,
      storageInfo: storages[0],
      totalSpace: coreProvider.totalSpace, // in bytes
      usedSpace: coreProvider.usedSpace, // in bytes
      freeSpace: coreProvider.freeSpace, // in bytes
    ));

    for (int i = 1; i < storages.length; i++) {
      var storage = storages[i];
      String name = storage.path.split("/")[2];
      _storages.add(StorageModel(
        name: name,
        storageInfo: storage,
        icon: Icons.sd_card_outlined,
        fullpath: storage.parent.parent.parent.parent.path,
        totalSpace: coreProvider.totalSDSpace, // in bytes
        usedSpace: coreProvider.usedSDSpace, // in bytes
        freeSpace: coreProvider.freeSDSpace, // in bytes
      ));

      // ...
    }

    return _storages;
  }

  static Future<List<DirectoryEntity>> geDirectoryEntities(String path) async {
    Directory dir = Directory(path);

    List<FolderModel> folder = [];
    List<FileModel> fileModel = [];
    List<DirectoryEntity> entities = [];

    Stream<FileSystemEntity> listDirectoryEntities = dir.list();

    await for (var entity in listDirectoryEntities) {
      // Masukkan ke model sesuai dengan tipe entitas
      if (FileSystemEntity.isFileSync(entity.path)) {
        File file = File(entity.path);

        fileModel.add(await FileModel.fromDirectory(file));

        // ...
      } else if (FileSystemEntity.isDirectorySync(entity.path)) {
        Directory directory = Directory(entity.path);

        folder.add(await FolderModel.fromDirectory(directory));

        // ...
      }

      // ...
    }

    folder.sort((de1, de2) {
      return de1.path.toLowerCase().compareTo(de2.path.toLowerCase());
    });

    fileModel.sort((de1, de2) {
      return de1.path.toLowerCase().compareTo(de2.path.toLowerCase());
    });

    entities.addAll(folder);
    entities.addAll(fileModel);

    return entities;

    // ...
  }

  // ...
}
