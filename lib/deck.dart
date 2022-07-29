import 'package:dashboard/files.dart';
import 'package:dashboard/objects.dart';
import 'package:dashboard/edit_card.dart';
import 'package:flutter/material.dart' hide Card;
import 'dart:convert';
import 'dart:io';

class DeckPage extends StatefulWidget {
    final Deck thumbnailDeck;
    const DeckPage(this.thumbnailDeck, {super.key});

    @override
    State<DeckPage> createState() => DeckPageState();
}

class DeckPageState extends State<DeckPage> {
    Deck deck = Deck();
    List<Card> sortedCards = <Card>[];
    String imgRoot = "";

    @override
    void initState(){
        super.initState();

        readFile("${widget.thumbnailDeck.title}.json").then((String data){
            Deck tempDeck = Deck.fromJson(json.decode(data));

            deck.title       = widget.thumbnailDeck.title;
            deck.image       = widget.thumbnailDeck.image;
            deck.description = widget.thumbnailDeck.description;

            setState(() {
                deck = tempDeck;
                sortedCards = tempDeck.cards;
            });
        });

        localImgRoot.then((value) => setState((){ imgRoot = value; }));
    }

    void writeDeck(){
        writeFile("${deck.title}.json", json.encode(deck.toJson()));
    }

    bool createCard(Card old, Card card){
        if(deck.cards.contains(card)){ return false; }

        if(card.localImage && card.image != ""){
            copyImgFile(card.image, '${deck.title}_${card.name}_img.${card.image.split('.').last}');
            card.image = '${deck.title}_${card.name}_img.${card.image.split('.').last}';
        }

        imageCache.clear();
        imageCache.clearLiveImages();

        setState((){ deck.cards.add(card); });
        writeDeck();

        return true;
    }

    bool editCard(Card old, Card card){
        if(old != card && deck.cards.contains(card)){ return false; }
        if(old.localImage && old.image != ""){ deleteImgFile(old.image); }

        if(card.localImage && card.image != ""){
            copyImgFile(card.image, '${deck.title}_${card.name}_img.${card.image.split('.').last}');
            card.image = '${deck.title}_${card.name}_img.${card.image.split('.').last}';
        }

        imageCache.clear();
        imageCache.clearLiveImages();

        int deckIndex = deck.cards.indexOf(old);
        setState((){ deck.cards[deckIndex] = card; });
        writeDeck();

        return true;
    }

    void deleteCard(Card card){
        if(card.localImage && card.image != ""){ deleteImgFile(deck.image); }
        setState((){ deck.cards.remove(card); });
        writeDeck();
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: Text(widget.thumbnailDeck.title),
                actions: <Widget>[
                    IconButton(
                        icon: const Icon(Icons.search_outlined),
                        tooltip: 'Search (not working currently)',
                        onPressed: (){},
                    ),
                ],
            ),
            body: ReorderableListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                children: <Widget>[
                    for(int i = 0; i < sortedCards.length; i += 1) GestureDetector(
                        key: Key('$i'),
                        onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditCard(editCard, deleteCard, sortedCards[i])));
                        },
                        child: Row(
                            children: [
                                if(sortedCards[i].image != "") ...[
                                    sortedCards[i].localImage?
                                        Image.file(File('$imgRoot/${sortedCards[i].image}'), height: 50) :
                                        Image.network(sortedCards[i].image, height: 50),
                                ],
                                Flexible(
                                    child: ListTile(
                                        title: Text(sortedCards[i].name),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
                onReorder: (int old, int current){
                    setState((){
                        if(old < current){ current -= 1; }
                        final Card card = sortedCards.removeAt(old);
                        sortedCards.insert(current, card);
                        writeDeck();
                    });
                },
            ),
            bottomNavigationBar: DeckPageBottomBar(createCard, deleteCard),
        );
    }
}

class DeckPageBottomBar extends StatelessWidget {
    final Function createCard;
    final Function deleteCard;
    const DeckPageBottomBar(this.createCard, this.deleteCard, {super.key});

    @override
    Widget build(BuildContext context){
        return BottomAppBar(
            child: IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                child: Row(
                    children: <Widget>[
                        IconButton(
                            tooltip: 'New Card',
                            icon: const Icon(Icons.add_outlined),
                            onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditCard(createCard, deleteCard, Card())));
                            },
                            iconSize: 40,
                        ),
                        const Spacer(),
                        IconButton(
                            tooltip: 'Filter (not working currently)',
                            icon: const Icon(Icons.sort_outlined),
                            onPressed: (){
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => EditDeck(createDeck, deleteDeck, '', '')));
                            },
                            iconSize: 40,
                        )
                    ],
                )
            )
        );
    }
}