import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/screen/sleep/audio_player_screen.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with SingleTickerProviderStateMixin {
  int? currentPlayingIndex;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List listArr = [
    {
      "image": "assets/img/mu1.png",
      "title": "Night Island",
      "subtitle": "45 MIN . SLEEP MUSIC",
      "audio": "assets/audio/music1.mp3"
    },
    {
      "image": "assets/img/mu2.png",
      "title": "Sweet Sleep",
      "subtitle": "45 MIN . SLEEP MUSIC",
      "audio": "assets/audio/music2.mp3"
    },
    {
      "image": "assets/img/mu3.png",
      "title": "Good Night",
      "subtitle": "45 MIN . SLEEP MUSIC",
      "audio": "assets/audio/music3.mp3"
    },
    {
      "image": "assets/img/mu4.png",
      "title": "Moon Clouds",
      "subtitle": "45 MIN . SLEEP MUSIC",
      "audio": "assets/audio/music4.mp3"
    },
    {
      "image": "assets/img/mu2.png",
      "title": "Night Island",
      "subtitle": "45 MIN . SLEEP MUSIC",
      "audio": "assets/audio/music5.mp3"
    },
    {
      "image": "assets/img/mu1.png",
      "title": "Sweet Sleep",
      "subtitle": "45 MIN . SLEEP MUSIC",
      "audio": "assets/audio/music1.mp3"
    },
    {
      "image": "assets/img/mu4.png",
      "title": "Good Night",
      "subtitle": "45 MIN . SLEEP MUSIC",
      "audio": "assets/audio/music2.mp3"
    },
    {
      "image": "assets/img/mu3.png",
      "title": "Moon Clouds",
      "subtitle": "45 MIN . SLEEP MUSIC",
      "audio": "assets/audio/music3.mp3"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TColor.primary.withOpacity(0.2),
            Colors.white,
          ],
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.08),
        itemBuilder: (context, index) {
          var cObj = listArr[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioPlayerScreen(
                    moodName: cObj["title"],
                    assetImagePath: cObj["image"],
                    audioPath:
                        cObj["audio"].toString().replaceAll("assets/", ""),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          cObj["image"],
                          width: double.maxFinite,
                          height: context.width * 0.29,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black12,
                              Colors.black45,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: TColor.primary,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cObj["title"],
                    maxLines: 1,
                    style: TextStyle(
                        color: TColor.sleepText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cObj["subtitle"],
                    maxLines: 1,
                    style: TextStyle(
                      color: TColor.sleepText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: listArr.length,
      ),
    );
  }
}
