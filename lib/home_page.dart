import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollCotroller.addListener(_scrollListner);
    fetchPost();
  }

  List posts = [];
  int page= 1;
  bool isLoadingMore = false;

  final scrollCotroller = ScrollController();

  Future<void> fetchPost() async {
     var url =
        'https://techcrunch.com/wp-json/wp/v2/posts?context=embed&per_page=10&page=$page';
    final uri = Uri.parse(url);

    try {
      final resposne = await http.get(uri);

      if (resposne.statusCode == 200) {
        final json = jsonDecode(resposne.body) as List;
        if (kDebugMode) {
          print(resposne.body);
        }

        setState(() {
          posts =  posts +json;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    
  }
  Future<void> _scrollListner() async{
    if(isLoadingMore) return;
    if(scrollCotroller.position.pixels == scrollCotroller.position.maxScrollExtent){
      setState(() {
        isLoadingMore = true;
      });
      page = page +1;
     await fetchPost();
      setState(() {
        isLoadingMore = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagination')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollCotroller,
                itemCount:  isLoadingMore ? posts.length +1 : posts.length,             
                itemBuilder: (context, index) {
                  if(index < posts.length){
                     final post = posts[index];
                   final title = post['title']['rendered'];
                   final description = post['seoDescription'];
                
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index +1}'),),
                        title: Text('$title'),
                      subtitle: Text('$description'),),
                    ),
                  );
                  }
                  else{
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  
                }),
          )
        ],
      ),
    );
  }
}
