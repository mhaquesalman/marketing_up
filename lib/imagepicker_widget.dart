import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  bool clearImage;
  bool singleImage;
  bool? isEdit = false;
  List<String>? imageFromFirestore;
  Function(List<File>) savedImages;

  ImagePickerWidget(
      {required this.savedImages,
      required this.clearImage,
      required this.singleImage,
        this.isEdit, this.imageFromFirestore});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<File> myImageFile = [];
  ImagePicker? picker;
  int index = 0;

  Future<void> handleImage() async {
    if (widget.singleImage && myImageFile.length == 1) return;
    if (!widget.singleImage && myImageFile.length == 4) return;
    showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                width: double.infinity,
                height: 120,
                child: Column(
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, "GALLERY"),
                        child: Text("Gallery")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, "CAMERA"),
                        child: Text("Camera")),
                  ],
                ),
              );
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            barrierColor: Colors.black87.withOpacity(0.5))
        .then((option) async {
      if (option == null) return;
      final pickedFile = await ImagePicker().pickImage(
          source: option == "CAMERA" ? ImageSource.camera : ImageSource.gallery,
          preferredCameraDevice: CameraDevice.front);
      // print("file: ${file?.path}");
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final croppedFile = await ImageCropper().cropImage(
            sourcePath: file.path,
            cropStyle: CropStyle.rectangle,
            maxWidth: 300,
            maxHeight: 300,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
        if (croppedFile != null) {
          if (widget.isEdit == true) {
            if (widget.imageFromFirestore != null && widget.imageFromFirestore!.isNotEmpty) {
              widget.imageFromFirestore!.clear();
            }
          }
          setState(() {
            myImageFile.add(File(croppedFile.path));
          });
          widget.savedImages(myImageFile);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print("image picker: ${widget.clearImage}");
    if (widget.clearImage) {
      if (myImageFile.isNotEmpty)
        myImageFile.clear();
      if(widget.imageFromFirestore != null && widget.imageFromFirestore!.isNotEmpty)
        widget.imageFromFirestore!.clear();
      widget.clearImage = false;
    }

    return Column(
      children: [
        Container(
          width: 150,
          height: 50,
          child: ElevatedButton(
              onPressed: () {
                handleImage();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text(widget.imageFromFirestore!.isNotEmpty ? "Change Photo" : "Add Photo",
                style: TextStyle(color: Colors.white),)
          ),
        ),
        myImageFile.isNotEmpty ?
        Container(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (index = 0; index < myImageFile.length; index++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(myImageFile[index]),
                )
            ],
          ),
        ) : widget.imageFromFirestore!.isNotEmpty ?
        Container(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (index = 0; index < widget.imageFromFirestore!.length; index++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.memory(base64Decode(widget.imageFromFirestore![index])),
                )
            ],
          ),
        ) : SizedBox.shrink(),
        myImageFile.isNotEmpty
            ? Container(
                width: 150,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        myImageFile.clear();
                      });
                      widget.savedImages(myImageFile);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                    child: Text("Clear", style: TextStyle(color: Colors.white),)
                ),
              ) : Text(""),
      ],
    );
  }
}
