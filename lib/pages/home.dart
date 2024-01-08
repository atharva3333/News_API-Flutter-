import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> headlines = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const apiKey =
        "b91aa92bd41d4973a4b4ee7e27efc6f9"; // Replace with your News API key
    const url =
        "https://newsapi.org/v2/top-headlines?country=in&apiKey=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          headlines = data['articles'];
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trending Headlines"),
      ),
      body: ListView.builder(
        itemCount: headlines.length,
        itemBuilder: (context, index) {
          final article = headlines[index];
          return ListTile(
            title: Text(article['title'] ?? ''),
            subtitle: Text(article['description'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailArticle(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailArticle extends StatelessWidget {
  final dynamic article;

  const DetailArticle({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title'] ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['urlToImage'] != null)
              Image.network(
                article['urlToImage'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(
              article['description'] ?? '',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              article['content'] ?? '',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                launchURL(article['url']);
              },
              child: Text("Read More"),
            ),
          ],
        ),
      ),
    );
  }
}

void launchURL(String? url) async {
  if (url != null && await canLaunch(url)) {
    await launch(url);
  } else {
    print("Could not launch $url");
  }
}
