import 'package:dashboard/objects.dart';
import 'package:flutter/material.dart' hide Card;

class EditCard extends StatefulWidget {
    final Function editCard;
    final Function deleteCard;

    final Card card;

    const EditCard(this.editCard, this.deleteCard, this.card, {super.key});

    @override
    State<EditCard> createState() => EditCardState();
}

class EditCardState extends State<EditCard> {
    TextEditingController name        = TextEditingController();
    TextEditingController description = TextEditingController();

    List<TextEditingController> identifiers = <TextEditingController>[];
    List<TextEditingController> notes       = <TextEditingController>[];
    List<TextEditingController> secretNotes = <TextEditingController>[];

    ScrollController scrollController = ScrollController();

    bool delete = false;

    @override
    void initState(){
        super.initState();

        name        = TextEditingController(text: widget.card.name       );
        description = TextEditingController(text: widget.card.description);

        for(String identifier in widget.card.identifiers){
            identifiers.add(TextEditingController(text: identifier));
        }

        for(Note note in widget.card.notes){
            if(note.private){
                secretNotes.add(TextEditingController(text: note.value));
            }
            else {
                notes.add(TextEditingController(text: note.value));
            }
        }
    }

    @override
    void dispose(){
        name.dispose();
        description.dispose();
        super.dispose();
    }

    bool editCard(){
        String nameStr        = name.text;
        String imageStr       = "";
        String descriptionStr = description.text;

        List<String> identifiersList = <String>[];
        for(TextEditingController identifier in identifiers){
            identifiersList.add(identifier.text);
        }

        List<Note> notesList = <Note>[];
        for(TextEditingController note in notes){
            notesList.add(Note.fromData(false, note.text));
        }
        for(TextEditingController note in secretNotes){
            notesList.add(Note.fromData(true, note.text));
        }

        List<Tag> tagsList = <Tag>[];
        //todo: save seleted tags to tagsList

        Card card = Card.fromData(nameStr, imageStr, descriptionStr, identifiersList, notesList, tagsList); 
        widget.editCard(widget.card, card);

        return true;
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: (widget.card.name == "") ? const Text('Edit Card') : Text(widget.card.name),
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
                                labelText: 'Card Name',
                            ),
                            style: const TextStyle(fontSize: 25),
                            controller: name,
                        ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Column(
                            children: <Widget>[
                                Row(
                                    children: <Widget>[
                                        const Text("Identifiers:"),
                                        IconButton(
                                            onPressed: (){
                                                setState((){ identifiers.add(TextEditingController()); });
                                            },
                                            tooltip: "Add Identifier",
                                            icon: const Icon(Icons.add_outlined),
                                        ),
                                    ],
                                ),
                                ReorderableListView(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                    children: <Widget>[
                                        for(int i = 0; i < identifiers.length; i += 1) ListTile(
                                            key: Key('$i'),
                                            leading: IconButton(
                                                onPressed: (){ setState((){ identifiers.removeAt(i); }); },
                                                tooltip: "",
                                                icon: const Icon(Icons.close_outlined),
                                            ),
                                            title: TextField(
                                                decoration: const InputDecoration(
                                                    border: UnderlineInputBorder(),
                                                    labelText: 'Type note here',
                                                ),
                                                style: const TextStyle(fontSize: 12),
                                                controller: identifiers[i],
                                                maxLines: null,
                                            ),
                                        ),
                                    ],
                                    onReorder: (int old, int current){
                                        setState((){
                                            if(old < current){ current -= 1; }
                                            final TextEditingController identifier = identifiers.removeAt(old);
                                            identifiers.insert(current, identifier);
                                        });
                                    },
                                ),
                            ],
                        )
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: TextField(
                            decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Card Description',
                            ),
                            controller: description,
                            maxLines: null,
                        ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Column(
                            children: <Widget>[
                                Row(
                                    children: <Widget>[
                                        const Text("Notes:"),
                                        IconButton(
                                            onPressed: (){
                                                setState((){ notes.add(TextEditingController()); });
                                            },
                                            tooltip: "Add Note",
                                            icon: const Icon(Icons.add_outlined),
                                        ),
                                    ],
                                ),
                                ReorderableListView(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                    children: <Widget>[
                                        for(int i = 0; i < notes.length; i += 1) ListTile(
                                            key: Key('$i'),
                                            leading: IconButton(
                                                onPressed: (){ setState((){ notes.removeAt(i); }); },
                                                tooltip: "",
                                                icon: const Icon(Icons.close_outlined),
                                            ),
                                            title: TextField(
                                                decoration: const InputDecoration(
                                                    border: UnderlineInputBorder(),
                                                    labelText: 'Type note here',
                                                ),
                                                style: const TextStyle(fontSize: 12),
                                                controller: notes[i],
                                                maxLines: null,
                                            ),
                                        ),
                                    ],
                                    onReorder: (int old, int current){
                                        setState((){
                                            if(old < current){ current -= 1; }
                                            final TextEditingController note = notes.removeAt(old);
                                            notes.insert(current, note);
                                        });
                                    },
                                ),
                            ],
                        )
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Column(
                            children: <Widget>[
                                Row(
                                    children: <Widget>[
                                        const Text("Secret Notes:", style: TextStyle(color: Colors.red)),
                                        IconButton(
                                            onPressed: (){
                                                setState((){ secretNotes.add(TextEditingController()); });
                                            },
                                            tooltip: "Add Secret Note",
                                            color: Colors.red,
                                            icon: const Icon(Icons.add_outlined),
                                        ),
                                    ],
                                ),
                                ReorderableListView(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                    children: <Widget>[
                                        for(int i = 0; i < secretNotes.length; i += 1) ListTile(
                                            key: Key('$i'),
                                            leading: IconButton(
                                                onPressed: (){ setState((){ secretNotes.removeAt(i); }); },
                                                tooltip: "",
                                                icon: const Icon(Icons.close_outlined),
                                            ),
                                            title: TextField(
                                                decoration: const InputDecoration(
                                                    border: UnderlineInputBorder(),
                                                    labelText: 'Type note here',
                                                ),
                                                style: const TextStyle(fontSize: 12),
                                                controller: secretNotes[i],
                                                maxLines: null,
                                            ),
                                        ),
                                    ],
                                    onReorder: (int old, int current){
                                        setState((){
                                            if(old < current){ current -= 1; }
                                            final TextEditingController note = secretNotes.removeAt(old);
                                            secretNotes.insert(current, note);
                                        });
                                    },
                                ),
                            ],
                        )
                    ),
                    if(widget.card.name != "") ...[
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
                                            widget.deleteCard(widget.card);
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
            bottomNavigationBar: EditCardBottomBar(editCard, name),
        );
    }
}

class EditCardBottomBar extends StatelessWidget {
    final Function editCard;
    final TextEditingController name;
    const EditCardBottomBar(this.editCard, this.name, {super.key});

    @override
    Widget build(BuildContext context){
        return BottomAppBar(
            child: IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                child: Row(
                    children: <Widget>[
                        const EditCardBackBtn(),
                        const Spacer(),
                        EditCardSaveBtn(editCard, name),
                    ],
                )
            )
        );
    }
}

class EditCardBackBtn extends StatelessWidget {
    const EditCardBackBtn({super.key});

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

class EditCardSaveBtn extends StatelessWidget {
    final Function editCard;
    final TextEditingController name;
    const EditCardSaveBtn(this.editCard, this.name, {super.key});

    @override
    Widget build(BuildContext context){
        return IconButton(
            onPressed: (){
                if(name.text == ""){
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
                else if(!editCard()){
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