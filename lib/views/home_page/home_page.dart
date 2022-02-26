import 'dart:async';
import 'dart:io';
import 'package:filemanager/bootstrap.dart';
import 'package:filemanager/facades/_facades.dart';
import 'package:filemanager/views/widgets/_widgets.dart';
import 'package:filemanager/models/_models.dart';
import 'package:filemanager/views/home_page/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:storage_mount_listener/storage_mount_listener.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CommonWidgets.text('File Manager', color: Colors.black87),
      ),
      body: _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    Key? key,
  }) : super(key: key);

  @override
  __BodyState createState() => __BodyState();
}

class __BodyState extends State<_Body> {
  StreamSubscription? storageSubscription;

  @override
  void initState() {
    super.initState();
    checkPermission();
    var strm = StorageMountListener.channel.receiveBroadcastStream();
    storageSubscription = strm.listen((event) => setState(() {}));

    // ...
  }

  checkPermission() async {
    bool hasAccess = false;
    if (Platform.isAndroid) {
      if (await Permission.storage.isPermanentlyDenied) openAppSettings();
      hasAccess = await Permission.storage.isGranted;
      if (!hasAccess) hasAccess = await Permission.storage.request().isGranted;

      if (await Permission.accessMediaLocation.isPermanentlyDenied)
        openAppSettings();
      hasAccess = await Permission.accessMediaLocation.isGranted;
      if (!hasAccess)
        hasAccess = await Permission.accessMediaLocation.request().isGranted;

      if (!await Permission.manageExternalStorage.isRestricted) {
        if (await Permission.manageExternalStorage.isPermanentlyDenied)
          openAppSettings();
        hasAccess = await Permission.manageExternalStorage.isGranted;
        if (!hasAccess) {
          hasAccess =
              await Permission.manageExternalStorage.request().isGranted;
        }
      }

      // if (hasAccess) setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    storageSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StorageModel>>(
      future: StorageFacade.getStorages(),
      builder: (context, data) {
        // cek jika data sudah ada
        if (data.hasData == true) {
          List<StorageModel> storages = data.data ?? [];

          return ListView.builder(
            itemCount: storages.length,
            itemBuilder: (BuildContext ctx, int index) {
              StorageModel storage = storages[index];
              return Column(
                children: [
                  StorageCard(
                    name: storage.name,
                    icon: storage.icon,
                    path: storage.fullpath,
                    usedSpace: storage.usedSpace,
                    freeSpace: storage.freeSpace,
                    totalSpace: storage.totalSpace,
                  ),
                  Divider(
                    height: 0,
                    thickness: 1,
                  ),
                ],
              );
            },
          );
        } else {
          return SizedBox.expand(
            child: Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ...
      },
    );
  }

  // ...
}
