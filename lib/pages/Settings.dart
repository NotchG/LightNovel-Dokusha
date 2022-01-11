import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool loading = true;

  bool darkMode = false;
  int fontSize = 0;

  void getOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dm = prefs.getBool("DarkMode") ?? false;
    int fs = prefs.getInt("FontSize") ?? 0;
    setState(() {
      darkMode = dm;
      fontSize = fs;
    });
  }

  void SetDarkMode(bool bool) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("DarkMode", bool);
    setState(() {
      darkMode = bool;
    });
  }

  void SetFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("FontSize", fontSize);
    setState(() {
      fontSize = fontSize;
    });
  }

  @override
  void initState() {
    super.initState();
    getOptions();
  }

  String fontSizeText() {
    switch(fontSize) {
      case 0: {
        return "xxSmall";
      }
      case 1: {
        return "xSmall";
      }
      case 2: {
        return "Small";
      }
      case 3: {
        return "Medium";
      }
      case 4: {
        return "Large";
      }
      case 5: {
        return "xLarge";
      }
      case 6: {
        return "xxLarge";
      }
      default: {
        return "Medium";
      }
    }
  }

  FontSize fontSizeCount() {
    switch(fontSize) {
      case 0: {
        return FontSize.xxSmall;
      }
      case 1: {
        return FontSize.xSmall;
      }
      case 2: {
        return FontSize.small;
      }
      case 3: {
        return FontSize.medium;
      }
      case 4: {
        return FontSize.large;
      }
      case 5: {
        return FontSize.xLarge;
      }
      case 6: {
        return FontSize.xxLarge;
      }
      default: {
        return FontSize.medium;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Settings"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            titlePadding: EdgeInsets.fromLTRB(15, 20, 0, 0),
            title: "Reader",
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: FontSize.large.size,
              fontWeight: FontWeight.w600
            ),
            tiles: [
              SettingsTile.switchTile(
                title: "Dark Mode",
                leading: Icon(Icons.dark_mode),
                switchValue: darkMode,
                onToggle: SetDarkMode,
              ),
              SettingsTile(
                titleWidget: Row(
                  children: [
                    Expanded(
                      flex: 2,
                        child: Text(
                            "Font Size",
                          style: TextStyle(
                            fontSize: FontSize.medium.size,
                          ),
                        )
                    ),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if(fontSize != 0) {
                                fontSize--;
                                SetFontSize();
                              }
                            });
                          },
                          child: Text("-"),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xffFF5D73)),
                        ),
                        ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (fontSize != 6) {
                                fontSize++;
                                SetFontSize();
                              }
                            });
                          },
                          child: Text("+"),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xffFF5D73)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        fontSizeText(),
                        style: TextStyle(
                          fontSize: FontSize.medium.size,
                        ),
                      ),
                    )
                  ],
                ),
                leading: Icon(Icons.text_fields),
                subtitleWidget: Text(
                  "Preview: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam nec ex ante.",
                  style: TextStyle(
                    fontSize: fontSizeCount().size,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
