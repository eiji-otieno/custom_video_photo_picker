import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tutorials_eocode99/custom_media_picker/request_album_assets.dart';
import 'package:tutorials_eocode99/custom_media_picker/request_albums.dart';

class PickVideoPhoto extends StatefulWidget {
  const PickVideoPhoto({super.key});

  @override
  State<PickVideoPhoto> createState() => _PickVideoPhotoState();
}

class _PickVideoPhotoState extends State<PickVideoPhoto> {
//CHECK LOADING STATUS
  bool isLoading = false;

  @override
  void initState() {
    //RETRIEVE MEDIA WHEN THIS SCREEN IS OPENED
    getVideoPhoto(RequestType.common);
    super.initState();
  }

  //RETRIEVE MEDIA FOR THE FIRST ALBUM
  AssetPathEntity? currentAlbum;

  //HOLD RETRIEVED ASSETS
  List<AssetEntity> assets = [];

  //STORE SELECTED ASSETS
  List<AssetEntity> selectedAssets = [];

  List<AssetPathEntity> albums = [];
  getVideoPhoto(RequestType type) async {
    setState(() {
      isLoading = true;
    });
    //CHECK IF STORAGE PERMISSION IS GRANTED
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth == false) {
      await PhotoManager.openSetting();
    } else {
      //NOW GET ALBUMS THAT HAVE MEDIA IN THEM THEN GET ALL MEDIA IN THEM
      await requestAlbums(type).then(
        (allAlbums) async {
          setState(() {
            albums = allAlbums;
            currentAlbum = allAlbums.first;
          });
          //GET MEDIA FOR THE FIRST ALBUM
          if (currentAlbum != null) {
            await requestAlbumAssets(currentAlbum!).then(
              (allAssets) {
                setState(() {
                  assets = allAssets;
                  //STOP LOADING
                  if (assets.isNotEmpty) {
                    isLoading = false;
                  }
                });
              },
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          //REDUCE APPBAR ELEVATION
          elevation: 0,
          backgroundColor: Colors.white,
          leading: const CloseButton(
            color: Colors.black,
          ),

          //CREATE A DROPDOWN MENU TO DISPLAY ALL ALBUMS
          title: DropdownButton<AssetPathEntity>(
            value: currentAlbum,
            items: albums.map((AssetPathEntity _albums) {
              return DropdownMenuItem(
                value: _albums,
                child: Text(_albums.name == ''
                    ? '0'
                    : "${_albums.name} (${_albums.assetCount})"),
              );
            }).toList(),
            onChanged: (AssetPathEntity? newAlbum) async {
              setState(() {
                //UPDATE CURRENT ALBUM TO NEW ALBUM
                currentAlbum = newAlbum!;
              });
              if (currentAlbum != null) {
                //RETRIEVE ASSETS FOR THE NEW ALBUM
                await requestAlbumAssets(currentAlbum!).then(
                  (value) {
                    setState(() {
                      //UPDATE 'ASSETS LIST' FOR THE NEW ALBUM
                      assets = value;
                      if (assets.isNotEmpty) {
                        isLoading = false;
                      }
                    });
                  },
                );
              }
            },
          ),
          actions: [
            if (selectedAssets.isNotEmpty)
              IconButton(
                onPressed: () {
                  //RETURN THE SELECTED ASSETS TO THE PREVIOUS SCREEN
                  Navigator.pop(context, selectedAssets);
                },
                icon: const Icon(
                  Icons.check,
                  color: Colors.black,
                ),
              ),
          ],
        ),
        //DISPLAY THE ASSETS OF THE CURRENT ALBUM
        body: Column(
          children: [
            if (assets.isEmpty && isLoading == false)
              const Flexible(
                child: Center(
                  child: Text("Album is empty"),
                ),
              ),
            if (isLoading == true)
              const Flexible(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (assets.isNotEmpty)
              Flexible(
                child: GridView.custom(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entity = assets[index];
                      return GestureDetector(
                        onTap: () {
                          if (selectedAssets.contains(entity)) {
                            setState(() {
                              selectedAssets.remove(entity);
                            });
                          } else {
                            setState(() {
                              selectedAssets.add(entity);
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: assetMediaWidget(entity, selectedAssets),
                        ),
                      );
                    },
                    childCount: assets.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //ASSET MEDIA DISPLAY WIDGET
  Widget assetMediaWidget(entity, selectedAssets) => Stack(
        children: [
          Positioned.fill(
            child: AssetEntityImage(
              entity,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize.square(250),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.black38,
                  ),
                );
              },
            ),
          ),
          if (entity.type == AssetType.video)
            const Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.video_call,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          //ADD AN ICON FOR SELECTED ASSETS
          if (selectedAssets.contains(entity))
            Positioned.fill(
              child: Container(
                color: Colors.blueAccent.withOpacity(0.3),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      );
}
