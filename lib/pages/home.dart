import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firstflutterproject/classes/NovelItem.dart';
import 'package:firstflutterproject/components/loading.dart';
import 'package:firstflutterproject/services/ln_scrape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIdx = 0;

  List<Widget> Tabs = [];
  
  void initTabs() async {
    LnScrape scrape = LnScrape(url: '/latest');
    await scrape.getLatest();
    LnScrape scrapecomplete = LnScrape(url: '/completed');
    await scrapecomplete.getLatest();

    Tabs.add(HomeTab(latest: scrape.latest, completed: scrapecomplete.latest));
    Tabs.add(LibraryTab());
    Tabs.add(SearchTab());
    Tabs.add(AboutTab());
    setState(() {

    });
  }

  @override
  void initState() {
    initTabs();
    super.initState();
  }

  void _changeTab(int idx) {
    setState(() {
      _selectedIdx = idx;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "RanobeDokusha"
        ),
        backgroundColor: Colors.black,
      ),
      body: Tabs.isEmpty ? Loading() : Tabs[_selectedIdx],
      bottomNavigationBar: Tabs.isEmpty ? null : BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
            backgroundColor: Colors.black
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_library),
            label: "Library",
            backgroundColor: Colors.black
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
            backgroundColor: Colors.black
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: "About",
              backgroundColor: Colors.black
          )
        ],
        currentIndex: _selectedIdx,
        selectedItemColor: Color(0xffFF5D73),
        onTap: _changeTab,
      ),
    );
  }
}


class HomeTab extends StatelessWidget {
  
  List<NovelItem> latest = [];
  List<NovelItem> completed = [];
  
  HomeTab({Key? key, required this.latest, required this.completed}) : super(key: key);

  Widget GridTmplte(NovelItem e, BuildContext context,
      {FontSize Fsize = FontSize.medium}) {
    return(
        SizedBox(
            child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(e.Img),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(e.Img),
                            fit: BoxFit.contain
                        )
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: FractionalOffset.bottomCenter,
                            end: FractionalOffset.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0)
                            ],
                            stops: const [
                              0.0,
                              1.0
                            ]
                        )
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(1.0),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/details', arguments: {
                        'url': e.Url
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.Title,
                          style: TextStyle(
                            fontSize: Fsize.size
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        )
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }

  Widget GridTmplteSmall(NovelItem e, BuildContext context,
      {FontSize Fsize = FontSize.medium}) {
    return(
        SizedBox(
            child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(e.Img),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: FractionalOffset.bottomCenter,
                            end: FractionalOffset.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0)
                            ],
                            stops: const [
                              0.0,
                              1.0
                            ]
                        )
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(1.0),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/details', arguments: {
                        'url': e.Url
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.Title,
                          style: TextStyle(
                              fontSize: Fsize.size
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        )
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    print("Home");


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarouselSlider(
            items: latest.map((e) => GridTmplte(e, context)).toList(),
            options: CarouselOptions(
              height: 40/100 * MediaQuery.of(context).size.height,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 7),
              viewportFraction: 1.0
            ),
          ),
          SizedBox(
            height: 5/100 * MediaQuery.of(context).size.height,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Completed Novels",
              style: TextStyle(
                fontSize: FontSize.xLarge.size,
              ),
            ),
          ),
          Container(
            height: 30/100 * MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(12.0),
            child: GridView.count(
              childAspectRatio: 16 / 9,
              crossAxisCount: 1,
              mainAxisSpacing: 10.0,
              scrollDirection: Axis.horizontal,
              children: completed.map((e) => GridTmplteSmall(e, context, Fsize: FontSize.small)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


class LibraryTab extends StatefulWidget {
  const LibraryTab({Key? key}) : super(key: key);

  @override
  _LibraryTabState createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {

  List<NovelItem> novels = [];

  Widget GridTmplte(NovelItem e, BuildContext context) {
    return(
        SizedBox(
            child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(e.Img),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: FractionalOffset.bottomCenter,
                            end: FractionalOffset.topCenter,
                            colors: [
                              Colors.black.withOpacity(1),
                              Colors.black.withOpacity(0)
                            ],
                            stops: const [
                              0.0,
                              1.0
                            ]
                        )
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(1.0),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/details', arguments: {
                        'url': e.Url
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.Title,
                        ),
                        SizedBox(
                          height: 15.0,
                        )
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }

  void getLibrary() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("NovelLibrary") != null) {
      novels = NovelItem.decode(prefs.getString("NovelLibrary") ?? "");
    }
    setState(() {

    });
  }

  @override
  void initState() {
    getLibrary();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return novels.isEmpty ? Padding(
        padding: EdgeInsets.all(10.0),
      child: Text(
          "Library Empty",
          style: TextStyle(
              fontSize: FontSize.xLarge.size
          ),
      )
    ) : ListView(
      padding: EdgeInsets.all(12.0),
      children: [
        GridView.count(
          primary: false,
          childAspectRatio: 0.6,
          crossAxisSpacing: 30.0,
          mainAxisSpacing: 30.0,
          shrinkWrap: true,
          crossAxisCount: 2,
          children: novels.map((e) => GridTmplte(e, context)).toList(),
        )
      ],
    );
  }
}

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {

  bool loading = false;
  List<NovelItem> search = [];

  Widget GridTmplte(NovelItem e, BuildContext context) {
    return(
        SizedBox(
            child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(e.Img),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: FractionalOffset.bottomCenter,
                            end: FractionalOffset.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0)
                            ],
                            stops: const [
                              0.0,
                              1.0
                            ]
                        )
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(1.0),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/details', arguments: {
                        'url': e.Url
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.Title,
                        ),
                        SizedBox(
                          height: 15.0,
                        )
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }

  void submit(String s) async {
    loading = true;
    if (s.trim() != "") {
      LnScrape scrape = LnScrape(url: s);
      await scrape.search();
      setState(() {
        search = scrape.searchRes;
        loading = false;
      });
    } else {
      setState(() {
        search = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: "Search",
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0)
          ),
          onSubmitted: loading ? null : (String s) {
            print("submit");
            submit(s);
          },
          style: TextStyle(
            fontSize: FontSize.large.size
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: search.isEmpty ? Text(
              "No search results or empty",
            style: TextStyle(
              fontSize: FontSize.xLarge.size
            ),
          ) : GridView.count(
            primary: false,
            childAspectRatio: 0.6,
            crossAxisSpacing: 30.0,
            mainAxisSpacing: 30.0,
            shrinkWrap: true,
            crossAxisCount: 2,
            children: search.map((e) => GridTmplte(e, context)).toList(),
          ),
        )
      ],
    );
  }
}

class AboutTab extends StatefulWidget {
  const AboutTab({Key? key}) : super(key: key);

  @override
  _AboutTabState createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                      "assets/images/AchmedFidel.png",
                    width: 50/100 * MediaQuery.of(context).size.width,
                  ),
                  Text("scraped from https://readlightnovels.net/"),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          SettingsList(
            backgroundColor: Colors.transparent,
            shrinkWrap: true,
            sections: [
              SettingsSection(
                title: "General",
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: FontSize.large.size,
                    fontWeight: FontWeight.w600
                ),
                tiles: [
                  SettingsTile(
                    title: "Settings",
                    onPressed: (BuildContext ctx) {
                      Navigator.pushNamed(context, '/settings');
                    },
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}





