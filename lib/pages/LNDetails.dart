import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:firstflutterproject/classes/Detail.dart';
import 'package:firstflutterproject/classes/NovelItem.dart';
import 'package:firstflutterproject/components/loading.dart';
import 'package:firstflutterproject/services/ln_scrape.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  List<Detail> detail = [];
  String imgUrl = "";
  String Title = '';
  List<String> Info = [];
  String CurrentVolume = '';
  String Url = "";
  Map data = {};
  bool loading = false;
  bool web = true;
  bool canExit = false;
  bool favorite = false;

  void get(String str) async {
    LnScrape scrape = LnScrape(url: Url);
    scrape.getDetailswithbody(str);

    if(scrape.chapters == null) {
      loading = false;
      return;
    }
    if(scrape.chapters!.isEmpty) {
      loading = false;
      return;
    }
    getCurrentVolume();
    List<Detail> finalDetail = [];
    int temp = 0;
    scrape.chapters?.forEach((element) {
      finalDetail.add(Detail(url: element['href'].toString(), title: element['title'].toString(), index: temp));
      temp++;
    });
    loading = false;
    setState(() {
      detail = finalDetail;
      imgUrl = scrape.Detailimage;
      Title = scrape.Title;
      Info = scrape.Info.split('\n');
    });
    canExit = true;
    getFav();
  }

  Future<bool> getFavorite() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<NovelItem> novels = [];
    bool exists = false;
    if (prefs.getString("NovelLibrary") != null) {
      novels = NovelItem.decode(prefs.getString("NovelLibrary") ?? "");
    }
    for (var element in novels) {
      if(element.Title == Title) {
        exists = true;
      }
    }
    setState(() {

    });
    return exists;
  }

  void setFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool favorited = await getFavorite();
    List<NovelItem> novels = [];
    if (prefs.getString("NovelLibrary") != null) {
      novels = NovelItem.decode(prefs.getString("NovelLibrary") ?? "");
    }
    if (favorited) {
      print(Title);
      novels.removeAt(novels.indexWhere((element) => element.Title == Title));
    } else {
      novels.add(NovelItem(Title, imgUrl, data['url']));
    }
    await prefs.setString("NovelLibrary", NovelItem.encode(novels));

    setState(() {
      favorite = !favorite;
    });

  }

  void resetWeb() {
    canExit = false;
    detail = [];
    imgUrl = "";
    Title = "";
    Info = [];
    web = true;
  }

  void getCurrentVolume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      CurrentVolume = prefs.getString(Url) ?? "";
      print(CurrentVolume);
    });
  }

  void setVolume(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (CurrentVolume == "") {
      await prefs.setString(Url, "$index 0");
    } else {
      if (CurrentVolume != detail[index].title && index > (int.tryParse(CurrentVolume.split(' ')[0]) ?? 99)) {
        await prefs.setString(Url, "$index 0");
      }
    }
    getCurrentVolume();
    Navigator.pushNamed(context, '/viewer', arguments: {
      'title': detail[index].title,
      'url': detail[index].url,
      'index': detail[index].index,
      'parentUrl': Url,
    });
  }

  Widget TitleTemplate(BuildContext context) {
    return (
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 100, 25,0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                imgUrl,
                height: 25/100 * MediaQuery.of(context).size.height,
              ),
              const SizedBox(
                width: 20.0,
              ),
              Container(
                width: 40/100 * MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      Title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.large.size,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      Info[0],
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: FontSize.medium.size,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                resetWeb();
                              });
                            },
                            child: const Text("WebView")
                        ),
                        IconButton(
                            onPressed: () {
                              setFavorite();
                            },
                            icon: Icon(
                                favorite ? Icons.favorite : Icons.favorite_border,
                              color: Color(0xffFF5D73),
                            )
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  void getFav() async {
    favorite = await getFavorite();
    print(favorite);
    setState(() {

    });
  }

  String createdViewId = 'map_element';

  @override
  void initState() {
    super.initState();
  }

  late WebViewController wvctrl;


  @override
  Widget build(BuildContext context) {

    if (data.isEmpty) {
      data = ModalRoute.of(context)!.settings.arguments as Map;
      Url = data['url'].toString().replaceAll("https://readlightnovels.net", "");
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: web ?
      AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(Title),
      )
      :
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(Title),
      ),
      body: web ?
      Stack(
        children: [
          kIsWeb ? HtmlElementView(viewType: createdViewId) : WebView(
          initialUrl: data['url'],
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>{
            _extractDataJSChannel(context),
          },
          onWebViewCreated: (WebViewController webViewController) {
            wvctrl = webViewController;
          },
          onPageFinished: (String url) {
            wvctrl.runJavascript("(function(){Flutter.postMessage(window.document.body.innerHTML)})();");
          },

        ),
          loading ? const Loading() : const SizedBox()
        ]
      ) :
      SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(imgUrl),
                            fit: BoxFit.cover
                        )
                    ),
                    height: 350.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      gradient: LinearGradient(
                        begin: FractionalOffset.bottomCenter,
                        end: FractionalOffset.topCenter,
                        colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.7)
                        ],
                        stops: const [
                          0.0,
                          1.0
                        ]
                      )
                    ),
                    height: 360.0,
                  ),
                  TitleTemplate(context)
                ]
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                'Volumes',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize.large.size,
                  color: Colors.white
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                  detail.map((e) => Container(
                    margin: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color(0xffFF5D73)),
                        minimumSize: MaterialStateProperty.all(const Size.fromHeight(40.0)),
                      ),
                onPressed: () {
                    setVolume(e.index);
                },
                child: Text(e.index == (int.tryParse(CurrentVolume.split(' ')[0]) ?? 99) ? "${e.title} (Current)" : e.title)
                ),
                  )).toList()
                ,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: web ? Container(
        width: MediaQuery.of(context).size.width - 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                  onPressed: () {
                    if(canExit) {
                      setState(() {
                        web = false;
                      });
                    } else {
                      Alert(context: context, title: "Loading", desc: "Page is currently Loading").show();
                    }
                  },
                  child: Text(
                    "Display Status: ${canExit ? "Complete (Click Me)" : "Loading"}",
                  )
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      canExit = false;
                    });
                    wvctrl.runJavascript("(function(){Flutter.postMessage(window.document.body.innerHTML)})();");
                  },
                  child: const Text(
                    "Reload"
                  )
              ),
            )
          ],
        ),
      )
          :
      ElevatedButton(
        onPressed: CurrentVolume == "" ? () {
          setVolume(0);
        } : () {
          setVolume(int.parse(CurrentVolume.split(' ')[0]));
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            CurrentVolume == "" ? Icons.play_arrow : Icons.pause,
            size: 25.0,
          ),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0)
          ))
        ),
      ),
    );
  }



  JavascriptChannel _extractDataJSChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Flutter',
      onMessageReceived: (JavascriptMessage message) {
        String pageBody = message.message;
        get(pageBody);
      },
    );
  }
}
