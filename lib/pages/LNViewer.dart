import 'package:firstflutterproject/components/loading.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ln_scrape.dart';
import 'package:flutter_html/flutter_html.dart';

class Viewer extends StatefulWidget {
  const Viewer({Key? key}) : super(key: key);

  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {

  final dataKey = GlobalKey();

  List<String> html = [''];
  List<String> finalhtml = [];
  double counter = 0;
  int startCounter = -1;
  int maxCount = 3;
  int fontSize = 0;
  bool updatePage = false;
  bool loading = true;
  bool DarkMode = false;

  Map data = {};

  void getCurrPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (int.parse(prefs.getString(data['parentUrl'])!.split(' ')[0]) == data['index']) {
        counter = double.parse(prefs.getString(data['parentUrl'])!.split(' ')[1]);
        updatePage = true;
      } else {
        counter = 0;
      }
    });
    loading = false;
    Future.delayed(Duration.zero, () => setListener());
  }

  void GetData(String url) async {
    LnScrape scrape = LnScrape(url: url.replaceAll("https://readlightnovels.net/", ""));
    await scrape.getContent();
    html = scrape.content;
    if (html.length <= 500) {
      setState(() {
        finalhtml.add(html.join("\n"));
        maxCount = 0;
      });
    } else {
      int temp = 100;
      while (html.length % temp != 0) {
        if (temp == 1) {
          break;
        }
        temp -= 1;
      }
      print(html.length);

      int temp2 = 0;
      int currCount = 1;

      List<String> res = [];

      if (temp > 10) {
        while (currCount != temp + 1) {
          String finalstr = '';
          for (int i = temp2; i < html.length / temp * currCount; i++) {
            finalstr += html[i] + '\n';
          }
          res.add(finalstr);
          temp2 = (html.length / temp * currCount).toInt();
          currCount += 1;
        }
      } else {
        String finalstr = '';
        int fullsect = html.length;
        int sections = html.length ~/ 10;
        int temps = 1;
        while (sections * temps < fullsect) {
          for (int i = sections * (temps - 1); i < sections * temps; i++) {
            finalstr += html[i] + '\n';
          }
          res.add(finalstr);
          finalstr = "";
          temps++;
        }
      }
      setState(() {
        finalhtml = res;
        maxCount = finalhtml.length - 1;
      });
    }
    getCurrPage();
  }
  
  Widget readerWidget(int page) {
    return (
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 150.0,
                color: Colors.black,
                child: Center(
                  child: Text(
                    "${data['title']} : Page ${page + 1}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: FontSize.xLarge.size,
                    ),
                  ),
                ),
              ),
              Html(
                data: finalhtml[page],
                style: {
                  'p' : Style(
                      fontSize: fontSizeCount(),
                      color: DarkMode ? Colors.white : Colors.black
                  ),
                  'img' : Style(
                      width: MediaQuery.of(context).size.width
                  )
                },
              ),
            ],
          )
    );
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

  final _controller = ScrollController();

  Future scrollItem() {
    print("jump $counter");
    _controller.jumpTo(counter);
    return Future.delayed(Duration.zero);
  }

  void _setPage(int index) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(data['parentUrl'], "${data['index']} $index");
    print("${data['index']} $index");
  }

  void savePos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(data['parentUrl'], "${data['index']} ${_controller.position.pixels}");
  }

  void setListener() {
    if (!updatePage) {
      return;
    }
    scrollItem();
  }

  void getOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DarkMode = prefs.getBool("DarkMode") ?? false;
    fontSize = prefs.getInt("FontSize") ?? 0;
  }

  @override
  void initState() {
    getOptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (data.isEmpty) {
      data = ModalRoute.of(context)!.settings.arguments as Map;
      GetData(data['url']);
    }


    return Scaffold(
      backgroundColor: DarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff000000),
        title: Text(data['title']),
        actions: [
          updatePage ? IconButton(
              onPressed: () {
                savePos();
              },
              icon: Icon(Icons.save)
          ) : SizedBox(),
          IconButton(
              onPressed: () {
                setState(() {
                  Navigator.pushNamed(context, "/settings");
                });
              },
              icon: Icon(Icons.settings)
          )
        ],
      ),
      body: loading ? const Loading() :
      ListView.builder(
      itemBuilder: (context, index) => readerWidget(index),
      itemCount: finalhtml.length,
        controller: _controller,
        ),
    );
  }
}

