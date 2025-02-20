import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class FullScreenImage extends StatefulWidget {
  final AssetEntity assetEntity;
  final List<AssetEntity> selectedAssetList;
  final Function(List<AssetEntity>) updateSelectedAssetList;
  final int maxCount;
  final List<AssetEntity> assetList;
  final int selectedIndex;

  FullScreenImage(
      {required this.assetEntity,
      required this.selectedAssetList,
      required this.updateSelectedAssetList,
      required this.maxCount,
      required this.assetList,
      required this.selectedIndex});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(

        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 22.0),
            child: Row(
              children: [
                Text(
                  '${widget.selectedAssetList.length}',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
                SizedBox(
                  width: 10.0,
                ),
                GestureDetector(
                  child: Text('전송',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0)),
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          PageView.builder(
            controller: _pageController,
              itemCount: widget.assetList.length,
              itemBuilder: (context, index) {
                final assetEntity = widget.assetList[index];
            return Stack(
              children: [
                Container(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.85,
                      ),
                      child: AssetEntityImage(
                        assetEntity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        selectAsset(assetEntity: assetEntity);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 5.0, 22.0, 0.0),
                        child: Container(
                          width: 48.0,
                          height: 48.0,
                          decoration: BoxDecoration(
                            color:
                            widget.selectedAssetList.contains(assetEntity) == true
                                ? Colors.blue
                                : Colors.white70,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.selectedAssetList.contains(assetEntity)
                                  ? Colors.transparent
                                  : Colors.black54,
                              width: 3.5,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "${widget.selectedAssetList.indexOf(assetEntity) + 1}",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: widget.selectedAssetList.contains(assetEntity)
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),



    );
  }

  void selectAsset({required AssetEntity assetEntity}) {
    if (widget.selectedAssetList.contains(assetEntity)) {
      setState(() {
        widget.updateSelectedAssetList(
            widget.selectedAssetList..remove(assetEntity));
      });
    } else if (widget.selectedAssetList.length < widget.maxCount) {
      setState(() {
        widget.updateSelectedAssetList(
            widget.selectedAssetList..add(assetEntity));
      });
    }
  }
}
