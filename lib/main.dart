import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:developer';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

Future<Result> fetchPesq(String StrPesq) async {
  Map<String, String> headers = {
    "Access-Control-Allow-Origin": "*",
    'Content-Type': 'application/json',
    'Accept': '*/*'
  };

  Uri url = Uri.http("localhost:8080", '/search', {'grp': StrPesq});
  http.Response res = await http.get(
    url,
    headers: headers,
  );

  if (res.statusCode == 200) {
    return Result(title: res.body);
  } else {
    throw Exception('Falha ao retornar dados do webservice.');
  }
}

class Result {
  final String title;

  const Result({
    required this.title,
  });

  get gtitle {
    return title;
  }

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      title: json['title'],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TextEditingController _controller = TextEditingController();
  late String xmlContent; //=

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  updStrPesq() {
    setState(() => null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPesq Rest Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('GPesq Rest Client'),
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              Container(
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                          textAlign: TextAlign.left,
                          controller: _controller,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Digite aqui algo...",
                              icon: Icon(Icons.search),
                              hintText: 'flutter')),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ElevatedButton(
                          onPressed: () => updStrPesq(),
                          child: Text("Pesquisar")),
                    )
                  ],
                ),
              ),
              ListRest(_controller.text)
            ]),
          )),
    );
  }
}

class ListRest extends StatefulWidget {
  final String strPesq;
  const ListRest(this.strPesq, {super.key});

  @override
  ListState createState() {
    return ListState();
  }
}

class ListState extends State<ListRest> {
  @override
  build(BuildContext context) {
    if (widget.strPesq.isNotEmpty) {
      final Future<Result> futurePesq = fetchPesq(widget.strPesq);

      return Container(
        child: SingleChildScrollView(
          child: Center(
            child: FutureBuilder<Result>(
              future: futurePesq,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //por hora tem que ser dinamico pois resultado pode ser diferente de string
                  Map<String, dynamic> mapResult =
                      json.decode(snapshot.data!.gtitle);
                  if (mapResult.isEmpty) {
                    return Text(
                      "Não foram encontrados dados para a palavra pesquisada.\n"
                      "Tente uma palavra diferente.",
                      textAlign: TextAlign.center,
                    );
                  } else {
                    final List<Widget> listWidgets = mapResult.entries
                        .map((t) => Butao(t.key, t.value))
                        .toList();

                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        children: <Widget>[...listWidgets],
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // Adicionado um indicador de progresso.
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      );
    } else {
      return Text(
        "Por favor, informe uma palavra pra realizar a pesquisa.",
        textAlign: TextAlign.center,
      );
    }
  }
}

class Butao extends StatelessWidget {
  final String url;
  final String titulo;
  const Butao(this.url, this.titulo, {super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(children: <Widget>[
      Text(titulo),
      TextButton(
          onPressed: () async {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            } else {
              throw 'Could not launch $url';
            }
          },
          child: Text(
            url,
            textAlign: TextAlign.center,
          )),
    ]));
  }
}
