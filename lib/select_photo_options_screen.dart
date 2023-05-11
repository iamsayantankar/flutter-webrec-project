import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectPhotoOptionsScreen extends StatelessWidget {
  final Function(ImageSource source) onTap;

  const SelectPhotoOptionsScreen({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(20),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -35,
            child: Container(
              width: 50,
              height: 6,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.5),
                color: Colors.deepPurpleAccent,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Column(children: [
            ElevatedButton(
              onPressed: () {
                // print("browser");
                onTap(ImageSource.gallery);
              },
              style: ElevatedButton.styleFrom(
                elevation: 10,
                primary: Colors.deepPurple.shade200,
                shape: const StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Icon(
                      Icons.image,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    Text(
                      'Browse Gallery',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Center(
              child: Text(
                'OR',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => onTap(ImageSource.camera),
              style: ElevatedButton.styleFrom(
                elevation: 10,
                primary: Colors.deepPurple.shade200,
                shape: const StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    Text(
                      'Use a Camera',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }
}
