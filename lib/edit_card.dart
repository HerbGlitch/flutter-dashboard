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

    ScrollController scrollController = ScrollController();

    bool delete = false;

    @override
    void initState(){
        super.initState();

        name        = TextEditingController(text: widget.card.name       );
        description = TextEditingController(text: widget.card.description);
    }

    @override
    void dispose(){
        name.dispose();
        description.dispose();
        super.dispose();
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
                        child: Row(
                            children: [
                                const Text("Identifiers:", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                                IconButton(
                                    onPressed: (){},
                                    tooltip: "Add Identifier",
                                    icon: const Icon(Icons.add_outlined),
                                )
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
            bottomNavigationBar: EditCardBottomBar(widget.editCard, name, description, widget.card),
        );
    }
}

class EditCardBottomBar extends StatelessWidget {
    final Function editCard;
    final TextEditingController title;
    final TextEditingController description;
    final Card oldCard;
    const EditCardBottomBar(this.editCard, this.title, this.description, this.oldCard, {super.key});

    @override
    Widget build(BuildContext context){
        return BottomAppBar(
            child: IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                child: Row(
                    children: <Widget>[
                        const EditCardBackBtn(),
                        const Spacer(),
                        EditCardSaveBtn(editCard, title, description, oldCard)
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
    final TextEditingController title;
    final TextEditingController description;
    final Card oldCard;
    const EditCardSaveBtn(this.editCard, this.title, this.description, this.oldCard, {super.key});

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
                else if(!editCard(oldCard, Deck.fromData(title.text, "", description.text))){
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