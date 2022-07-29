import 'package:dashboard/files.dart';
import 'package:dashboard/objects.dart';
import 'package:dashboard/deck.dart';
import 'package:dashboard/edit_deck.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class Dashboard extends StatefulWidget {
    const Dashboard({super.key});

    @override
    State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
    List<Deck> decks = <Deck>[];
    List<Deck> filteredDecks = <Deck>[];
    TextEditingController search = TextEditingController();
    bool searching = false;
    String imgRoot = "";

    @override
    void initState(){
        super.initState();
        localInit();

        readFile("decks.pocket").then((String deckString){
            if(deckString == ""){ return; }

            List<Deck> loadedDecks = <Deck>[];
            List<dynamic> data = json.decode(deckString);
            for(Map<String, dynamic> deckData in data){
                loadedDecks.add(Deck.fromJson(deckData));
            }

            setState(() { decks = loadedDecks; });
        }).onError((err, trace){});

        localImgRoot.then((value) => setState((){ imgRoot = value; }));
    }

    void writeDecks(){
        List<dynamic> data = <dynamic>[];
        for(Deck deck in decks){ data.add(deck.toJson()); }

        writeFile("decks.pocket", json.encode(data));
    }

    bool createDeck(Deck old, Deck deck){
        if(decks.contains(deck)){ return false; }

        if(deck.localImage && deck.image != ""){
            copyImgFile(deck.image, '${deck.title}_thumbnail.${deck.image.split('.').last}');
            deck.image = '${deck.title}_thumbnail.${deck.image.split('.').last}';
        }

        imageCache.clear();
        imageCache.clearLiveImages();

        setState((){ decks.add(deck); });
        writeDecks();

        //todo: unique id instead of name
        writeFile("${deck.title}.json", json.encode(deck.toJson()));

        return true;
    }

    bool editDeck(Deck old, Deck deck){
        if(old != deck && decks.contains(deck)){ return false; }
        if(old.localImage && old.image != ""){ deleteImgFile(old.image); }

        if(deck.localImage && deck.image != ""){
            copyImgFile(deck.image, '${deck.title}_thumbnail.${deck.image.split('.').last}');
            deck.image = '${deck.title}_thumbnail.${deck.image.split('.').last}';
        }

        imageCache.clear();
        imageCache.clearLiveImages();

        int deckIndex = decks.indexOf(old);
        setState((){ decks[deckIndex] = deck; });

        writeDecks();
        renameFile("${old.title}.json", "${deck.title}.json");

        return true;
    }

    void deleteDeck(Deck deck){
        if(deck.localImage && deck.image != ""){ deleteImgFile(deck.image); }
        setState((){ decks.remove(deck); });

        writeDecks();
        deleteFile("${deck.title}.json");
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: const Text('Campaign Decks'),
                actions: <Widget>[
                    if(searching) ...[
                        Flexible(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                child: TextField(
                                    decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        labelText: 'Search',
                                    ),
                                    controller: search,
                                    onChanged: (String value) async {
                                        if(value != ""){
                                            setState((){ filteredDecks = decks.where((deck) => deck.title.toLowerCase().contains(value.toLowerCase())).toList(); });
                                        }
                                        else {
                                            setState((){ filteredDecks = decks; });
                                        }
                                    },
                                ),
                            ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.close_outlined),
                            onPressed: (){
                                search.clear();
                                setState((){
                                    searching = false;
                                    filteredDecks = decks;
                                });
                            },
                        ),
                    ]
                    else ...[
                        IconButton(
                            icon: const Icon(Icons.search_outlined),
                            tooltip: 'Search',
                            onPressed: (){
                                setState((){
                                    searching = true;
                                    filteredDecks = decks;
                                });
                            },
                        ),
                    ],
                ],
            ),
            body: searching?
                (filteredDecks.isEmpty? const Center(child: Text('No decks match search')) : DashboardDecks(filteredDecks, editDeck, deleteDeck, imgRoot)) :
                (decks.isEmpty? const Center(child: Text('Create a new deck to get started!')) : DashboardDecks(decks, editDeck, deleteDeck, imgRoot)),
            bottomNavigationBar: DashboardBottomBar(createDeck, deleteDeck),
        );
    }
}

class DashboardDecks extends StatelessWidget {
    final List<Deck> decks;
    final Function editDeck;
    final Function deleteDeck;
    final String imgRoot;

    const DashboardDecks(this.decks, this.editDeck, this.deleteDeck, this.imgRoot, {super.key});

    @override
    Widget build(BuildContext context){
        return GridView.extent(
            maxCrossAxisExtent: 250,
            padding: const EdgeInsets.all(5),
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            children: List.generate(decks.length, (i) => GestureDetector(
                onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DeckPage(decks[i])));
                },
                child: Stack(
                    alignment: const Alignment(0.0, 0.0),
                    children: [
                        GridTile(
                            footer: GridTileBar(title: Center(child: Text(decks[i].title)), backgroundColor: Colors.black45),
                            child: decks[i].localImage ?
                                ((decks[i].image == "")? Image.asset('res/img/img_placeholder.png') : Image.file(File('$imgRoot/${decks[i].image}'))) :
                                Image.network(decks[i].image),
                        ),
                        Positioned(
                            left: 5.0,
                            top: 5.0,
                            child: Column(
                                children: [
                                    IconButton(
                                        tooltip: "Edit",
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditDeck(editDeck, deleteDeck, decks[i])));
                                        },
                                        iconSize: 20,
                                    ),
                                    IconButton(
                                        tooltip: "Share (not working currently)",
                                        icon: const Icon(Icons.share_outlined),
                                        onPressed: (){},
                                        iconSize: 20,
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            )),
        );
    }
}

class DashboardBottomBar extends StatelessWidget {
    final Function createDeck;
    final Function deleteDeck;
    const DashboardBottomBar(this.createDeck, this.deleteDeck, {super.key});

    @override
    Widget build(BuildContext context){
        return BottomAppBar(
            child: IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                child: Row(
                    children: <Widget>[
                        IconButton(
                            tooltip: 'Import (not working currently)',
                            icon: const Icon(Icons.download_outlined),
                            onPressed: (){},
                            iconSize: 40,
                        ),
                        const Spacer(),
                        IconButton(
                            tooltip: 'New Deck',
                            icon: const Icon(Icons.add_outlined),
                            onPressed: (){
                                Deck deck = Deck();
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditDeck(createDeck, deleteDeck, deck)));
                            },
                            iconSize: 40,
                        )
                    ],
                )
            )
        );
    }
}