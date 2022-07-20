import 'package:dashboard/objects.dart';
import 'package:flutter/material.dart';

class EditDeck extends StatefulWidget {
    final Function editDeck;
    final Function deleteDeck;

    final Deck deck;

    const EditDeck(this.editDeck, this.deleteDeck, this.deck, {super.key});

    @override
    State<EditDeck> createState() => EditDeckState();
}

class EditDeckState extends State<EditDeck> {
    TextEditingController title       = TextEditingController();
    TextEditingController description = TextEditingController();

    ScrollController scrollController = ScrollController();

    bool delete = false;

    @override
    void initState(){
        super.initState();

        title       = TextEditingController(text: widget.deck.title      );
        description = TextEditingController(text: widget.deck.description);
    }

    @override
    void dispose(){
        title.dispose();
        description.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: (widget.deck.title == "") ? const Text('Edit Deck') : Text(widget.deck.title),
                automaticallyImplyLeading: false,
                actions: <Widget>[
                    IconButton(
                        icon: const Icon(Icons.search_outlined),
                        tooltip: 'Search',
                        onPressed: (){},
                    ),
                ],
            ),
            body: ListView(
                controller: scrollController,
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Image.asset('res/img/img_placeholder.png'),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: TextField(
                            decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Title',
                            ),
                            style: const TextStyle(fontSize: 25),
                            controller: title,
                            maxLines: null,
                        ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: TextField(
                            decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Description',
                            ),
                            controller: description,
                            maxLines: null,
                        ),
                    ),
                    if(widget.deck.title != "") ...[
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                            child: Row(
                                children: [
                                    const Text("Delete campaign deck?", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                                    Switch(
                                        onChanged: (value){
                                            setState((){ delete = value; });
                                            if(delete && scrollController.hasClients){
                                                final position = scrollController.position.maxScrollExtent;
                                                scrollController.jumpTo(position);
                                            }
                                        },
                                        value: delete,
                                        activeColor: Colors.red,
                                    ),
                                ],
                            ),
                        ),
                    ],
                    Opacity(
                        opacity: (delete)? 1.0 : 0.0,
                        child: Stack(
                            children: <Widget>[
                                Positioned.fill(
                                    child: Container(
                                        decoration: const BoxDecoration(color: Colors.red),
                                    ),
                                ),
                                TextButton(
                                    style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        textStyle: const TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                    onPressed: (){
                                        if(delete){
                                            widget.deleteDeck(widget.deck);
                                            Navigator.pop(context);
                                        }
                                    },
                                    child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                        child: Center(child: Text("DELETE")),
                                    )
                                ),
                            ],
                        ),
                    ),
                ],
            ),
            bottomNavigationBar: EditDeckBottomBar(widget.editDeck, title, description, widget.deck),
        );
    }
}

class EditDeckBottomBar extends StatelessWidget {
    final Function editDeck;
    final TextEditingController title;
    final TextEditingController description;
    final Deck oldDeck;
    const EditDeckBottomBar(this.editDeck, this.title, this.description, this.oldDeck, {super.key});

    @override
    Widget build(BuildContext context){
        return BottomAppBar(
            child: IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                child: Row(
                    children: <Widget>[
                        const EditDeckBackBtn(),
                        const Spacer(),
                        EditDeckSaveBtn(editDeck, title, description, oldDeck)
                    ],
                )
            )
        );
    }
}

class EditDeckBackBtn extends StatelessWidget {
    const EditDeckBackBtn({super.key});

    @override
    Widget build(BuildContext context){
        return IconButton(
            onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                    content: const Text('Discard changes and go back?'),
                    actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('STAY'),
                        ),
                        TextButton(
                            onPressed: (){
                                Navigator.pop(context);
                                Navigator.pop(context);
                            },
                            child: const Text('GO BACK'),
                        ),
                    ],
                )
            ),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_outlined),
            iconSize: 40,
        );
    }
}

class EditDeckSaveBtn extends StatelessWidget {
    final Function editDeck;
    final TextEditingController title;
    final TextEditingController description;
    final Deck oldDeck;
    const EditDeckSaveBtn(this.editDeck, this.title, this.description, this.oldDeck, {super.key});

    @override
    Widget build(BuildContext context){
        return IconButton(
            onPressed: (){
                if(title.text == ""){
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                            content: const Text('Error: Title empty!'),
                            actions: <Widget>[
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('GO BACK')
                                ),
                            ],
                        ),
                    );
                }
                else if(!editDeck(oldDeck, Deck.fromData(title.text, "", description.text))){
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                            content: const Text('Error: Title already in use!'),
                            actions: <Widget>[
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('GO BACK')
                                ),
                            ],
                        ),
                    );
                }
                else {
                    Navigator.pop(context);
                }
            },
            tooltip: 'Save',
            icon: const Icon(Icons.save_outlined),
            iconSize: 40,
        );
    }
}