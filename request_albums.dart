import 'package:photo_manager/photo_manager.dart';

Future requestAlbums(RequestType type) async {
  final List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(type: type);

  return albums;
}
