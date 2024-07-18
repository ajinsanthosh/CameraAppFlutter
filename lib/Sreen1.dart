import 'dart:io';

import 'package:camera/db_camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Sreen1 extends StatefulWidget {
  const Sreen1({super.key});

  @override
  State<Sreen1> createState() => _Sreen1State();
}

File? selectedImage;
List<Map<String, dynamic>> imageList = [];
List<File> recentimage = [];

class _Sreen1State extends State<Sreen1> {
  @override
  void initState() {
    initializeSelectedimage();
    super.initState();
  }

  Future<void> initializeSelectedimage() async {
    File? image = await selectImageFromGallery(context);
    setState(() {
      selectedImage = image;
    });
    if (selectedImage != null) {
      addImageToDB(selectedImage!.path);
      recentimage.add(selectedImage!);
    }
    fetchImage();
  }

  Future<void> fetchImage() async {
    List<Map<String, dynamic>> listFromDB = await getImageFromDB();
    setState(() {
      imageList = listFromDB;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("CAMPIC"),
          centerTitle: true,
          bottom: const TabBar(tabs: [
            Tab(
              text: "RECENT",
            ),
            Tab(
              text: "GALLERY",
            )
          ]),
        ),
        body: TabBarView(children: [
          recentimage.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, crossAxisSpacing: 10),
                      itemCount: recentimage.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            showSelectedImageDialogue(
                                context, recentimage[index]);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(recentimage[index]),
                          ),
                        );
                      }),
                )
              : const Center(
                  child: Text("Take a Photo"),
                ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 10),
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  final imagemap = imageList[index];
                  final imageFile = File(imagemap['imagesrc']);
                  final id = imagemap['id'];
                  return InkWell(
                    onTap: () {
                      showSelectedImageDialogue(context, imageFile);
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(imageFile),
                        ),
                        Positioned(
                            bottom: 2,
                            right: 40,
                            child: CircleAvatar(
                              radius: 25,
                              child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("DELETE"),
                                            content: const Text(
                                                "Are you sure you want to delete?"),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Cancel")),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    deleteImageFromDB(id);
                                                    fetchImage();
                                                    Navigator.of(context).pop();
                                                    showsnackbar(
                                                        context,
                                                        "Sucessfully Deleted",
                                                        Colors.green);
                                                  },
                                                  child: const Text("OK")),
                                            ],
                                          );
                                        });
                                  },
                                  icon: const Icon(
                                      Icons.delete_forever_outlined)),
                            ))
                      ],
                    ),
                  );
                }),
          )
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await initializeSelectedimage();
          },
         tooltip: 'Take a Photo',
          backgroundColor: const Color(
            (0xff176dab),
          ),
          child: const Icon(Icons.camera_alt_outlined),
        ),
      ),
    );
  }
}

Future<File?> selectImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickImage != null) {
      image = File(pickImage.path);
    }
  } catch (e) {
    showsnackbar(context, e.toString(), Colors.red);
  }
  return image;
}

void showsnackbar(BuildContext context, String content, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: (Text(content)),
    backgroundColor: color,
  ));
}

void showSelectedImageDialogue(BuildContext context, File imageFile) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            child: Image.file(imageFile),
          ),
        );
      });
}
