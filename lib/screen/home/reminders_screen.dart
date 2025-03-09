import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/common/common_widget/circle_button.dart';
import 'package:meditation/common/common_widget/round_button.dart';
import 'package:meditation/common/show_snackbar_extension.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/moods_model.dart';
import 'package:meditation/screen/main_tabview/main_tabview_screen.dart';

class RemindersScreen extends StatefulWidget {
  final String moodName;
  final String assetImagePath;
  final String audioPath;
  const RemindersScreen(
      {super.key,
      required this.assetImagePath,
      required this.moodName,
      required this.audioPath});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List dayArr = [
    {"name": "SU", "is_select": false},
    {"name": "M", "is_select": false},
    {"name": "T", "is_select": false},
    {"name": "W", "is_select": false},
    {"name": "TH", "is_select": false},
    {"name": "F", "is_select": false},
    {"name": "S", "is_select": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(minHeight: context.height - 180),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "What time would you\nlike to meditate?",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Any time you can choose but We recommend\nfirst thing in th morning.",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                        color: const Color(0xffF5F5F9),
                        borderRadius: BorderRadius.circular(20)),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      onDateTimeChanged: (DateTime newDate) {},
                      use24hFormat: false,
                      minuteInterval: 1,
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Text(
                    "What day would you\nlike to meditate?",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Everyday is best, but we recommend picking\nat least five.",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: dayArr.map((dObj) {
                      return CircleButton(
                          title: dObj["name"],
                          isSelect: dObj["is_select"],
                          onPressed: () {
                            setState(() {
                              dayArr[dayArr.indexOf(dObj)]["is_select"] =
                                  !(dObj["is_select"] as bool? ?? false);
                            });
                          });
                    }).toList(),
                  )
                ],
              ),
            ),
            RoundButton(
                title: "SAVE",
                onPressed: () async {
                  MoodsModel newMood = MoodsModel(
                    name: widget.moodName,
                    assetImagePath: widget.assetImagePath,
                  );
                  await AppDatabase.instance.createMoods(newMood);
                  context.showSnackbar(
                    message: 'Mood Saved Successfully',
                    type: SnackbarMessageType.success,
                  );
                  context.push(const MainTabViewScreen());
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      context.push(const MainTabViewScreen());
                    },
                    child: Text(
                      "NO THANKS",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ))
              ],
            )
          ],
        )),
      ),
    );
  }
}
