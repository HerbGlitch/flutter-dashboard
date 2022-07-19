import 'dart:convert';

import 'package:dashboard/files.dart';
import 'package:dashboard/objects.dart';
import 'package:dashboard/edit_card.dart';
import 'package:flutter/material.dart' hide Card;

class DeckPage extends StatefulWidget {
    final Deck thumbnailDeck;
    const DeckPage(this.thumbnailDeck, {super.key});

    @override
    State<DeckPage> createState() => DeckPageState();
}

class DeckPageState extends State<DeckPage> {
    Deck deck = Deck();

    @override
    void initState(){
        super.initState();

        readFile("${widget.thumbnailDeck.title}.json").then((String data){
            Deck tempDeck = Deck.fromJson(json.decode(data));

            deck.title       = widget.thumbnailDeck.title;
            deck.image       = widget.thumbnailDeck.image;
            deck.description = widget.thumbnailDeck.description;

            setState(() { deck = tempDeck; });
        });
    }

    void writeDeck(){
        writeFile("${deck.title}.json", json.encode(deck.toJson()));
    }

    bool createCard(Card old, Card card){
        if(deck.cards.contains(card)){ return false; }

        setState((){ deck.cards.add(card); });
        writeDeck();

        return true;
    }

    bool editCard(Card old, Card card){
        if(old == card){ return true; }
        if(deck.cards.contains(card)){ return false; }

        int deckIndex = deck.cards.indexOf(old);
        setState((){ deck.cards[deckIndex] = card; });
        writeDeck();

        return true;
    }

    void deleteCard(Card card){
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