import 'package:dashboard/files.dart';
import 'package:dashboard/objects.dart';
import 'package:dashboard/deck.dart';
import 'package:dashboard/edit_deck.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Dashboard extends StatefulWidget {
    const Dashboard({super.key});

    @override
    State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
    List<Deck> decks = <Deck>[];

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
    }

    void writeDecks(){
        List<dynamic> data = <dynamic>[];
        for(Deck deck in decks){ data.add(deck.toJson()); }

        writeFile("decks.pocket", json.encode(data));
    }

    bool createDeck(Deck old, Deck deck){
        if(decks.contains(deck)){ return false; }

        setState((){ decks.add(deck); });
        writeDecks();

        //todo: unique id instead of name
        writeFile("${deck.title}.json", json.encode(deck.toJson()));

        return true;
    }

    bool editDeck(Deck old, Deck deck){
        if(old == deck){ return true; }
        if(decks.contains(deck)){ return false; }

        int deckIndex = decks.indexOf(old);
        setState((){ decks[deckIndex] = deck; });

        writeDecks();
        renameFile("${old.title}.json", "${deck.title}.json");

        return true;
    }

    void deleteDeck(Deck deck){
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
                    IconButton(
                        icon: const Icon(Icons.search_outlined),
                        tooltip: 'Search (not working currently)',
                        onPressed: (){},
                    ),
                ],
            ),
            body: (decks.isEmpty)? const Center(child: Text('Create a new deck to get started!')) : DashboardDecks(decks, editDeck, deleteDeck),
            bottomNavigationBar: DashboardBottomBar(createDeck, deleteDeck),
        );
    }
}

class DashboardDecks extends StatelessWidget {
    final List<Deck> decks;
    final Function editDeck;
    final Function deleteDeck;
    const DashboardDecks(this.decks, this.editDeck, this.deleteDeck, {super.key});

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
                                ((decks[i].image == "")? Image.asset('res/img/img_placeholder.png') : Image.asset(decks[i].image)) :
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