//LET US RETRIEVE ALL ASSETS AVAILABLE IN A SPECIFIC ALBUM

import 'package:photo_manager/photo_manager.dart';

Future requestAlbumAssets(AssetPathEntity album) async {
  //SET THE 'END' TO THE HIGHEST NUMBER POSSIBLE
  final List<AssetEntity> assets = await album.getAssetListRange(
    start: 0,
    end: 1000000000000,
  );

  return assets;
}
