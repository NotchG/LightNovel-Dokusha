import 'dart:io';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:firstflutterproject/classes/NovelItem.dart';
import 'package:http/http.dart';

class LnScrape {

  String url;
  List<String> content = [];
  List<Bs4Element>? chapters = [];
  String Detailimage = '';
  String Title = '';
  String Info = '';
  List<NovelItem> latest = [];
  List<NovelItem> searchRes = [];
  
  LnScrape({required this.url});
  
  Future<void> getContent() async {
    Response response = await get(Uri.https('readlightnovels.net', url), headers: {
      HttpHeaders.userAgentHeader: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
      HttpHeaders.acceptHeader: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      HttpHeaders.acceptLanguageHeader: 'en-US,en;q=0.5',
      HttpHeaders.acceptEncodingHeader: 'gzip',
      HttpHeaders.connectionHeader: 'close',
    });

    BeautifulSoup bs = BeautifulSoup(response.body);
    List<Bs4Element>? res = bs.find('div', class_: 'chapter-content')?.contents;

    res?.forEach((element) {
      if(element.img.toString().startsWith("<img")) {
        content.add(element.img.toString());
      } else {
        content.add(element.toString());
      }
    });
  }
  
  Future<void> getDetails() async {

    List<String> Proxies = ['217.23.69.146:3128'];

    Response response = await get(Uri.https('readlightnovels.net', url), headers: {
      HttpHeaders.userAgentHeader: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
      HttpHeaders.acceptHeader: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      HttpHeaders.acceptLanguageHeader: 'en-US,en;q=0.5',
      HttpHeaders.acceptEncodingHeader: 'gzip',
      HttpHeaders.connectionHeader: 'close',
    });

    BeautifulSoup bs = BeautifulSoup(response.body);
    List<Bs4Element>? res = bs.find('ul', class_: 'list-chapter')?.findAll('a');
    Bs4Element? img = bs.find('div', class_: 'book')?.img;
    Bs4Element? title = bs.find('h3', class_: 'title');
    List<Bs4Element>? info = bs.find('div', class_: 'info')?.find('div', class_: 'info')?.find('div', class_: 'info')?.children;

    chapters = res;
    Detailimage = img!['src'].toString();
    Title = title!.getText();
    info?.forEach((element) {
      Info += element.getText() + '\n';
    });
  }

  void getDetailswithbody(String str) {
    BeautifulSoup bs = BeautifulSoup(str);
    List<Bs4Element>? res = bs.find('ul', class_: 'list-chapter')?.findAll('a');
    Bs4Element? img = bs.find('div', class_: 'book')?.img;
    Bs4Element? title = bs.find('h3', class_: 'title');
    List<Bs4Element>? info = bs.find('div', class_: 'info')?.find('div', class_: 'info')?.find('div', class_: 'info')?.children;

    chapters = res;
    Detailimage = img!['src'].toString();
    Title = title!.getText();
    info?.forEach((element) {
      Info += element.getText() + '\n';
    });
  }

  Future<void> getLatest() async {
    Response response = await get(Uri.https('readlightnovels.net', url), headers: {
      HttpHeaders.userAgentHeader: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
      HttpHeaders.acceptHeader: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      HttpHeaders.acceptLanguageHeader: 'en-US,en;q=0.5',
      HttpHeaders.acceptEncodingHeader: 'gzip',
      HttpHeaders.connectionHeader: 'close',
    });

    BeautifulSoup bs = BeautifulSoup(response.body);
    
    List<Bs4Element>? res = bs.findAll('div', class_: 'col-md-3 col-sm-6 col-xs-6 home-truyendecu');

    for (var element in res) {
      Bs4Element a = element.find('a')!;
      String img = element.find('img')!['src'].toString();
      String url = a['href'].toString();
      String title = a['title'].toString();
      latest.add(NovelItem(title, img, url));
    }
  }

  Future<void> search() async {
    Response response = await get(Uri.https('readlightnovels.net', '/', {
      's' : url,
    }), headers: {
      HttpHeaders.userAgentHeader: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
      HttpHeaders.acceptHeader: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      HttpHeaders.acceptLanguageHeader: 'en-US,en;q=0.5',
      HttpHeaders.acceptEncodingHeader: 'gzip',
      HttpHeaders.connectionHeader: 'close',
    });

    BeautifulSoup bs = BeautifulSoup(response.body);

    List<Bs4Element>? res = bs.findAll('div', class_: 'col-md-3 col-sm-6 col-xs-6 home-truyendecu');

    for (var element in res) {
      Bs4Element a = element.find('a')!;
      String img = element.find('img')!['src'].toString();
      String url = a['href'].toString();
      String title = a['title'].toString();
      String chapter = element.find('small')!.text;
      if(chapter != "No chapter") {
        searchRes.add(NovelItem(title, img, url));
        print(title);
      }
    }
  }

}