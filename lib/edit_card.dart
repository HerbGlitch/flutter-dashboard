import 'package:dashboard/files.dart';
import 'package:dashboard/objects.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditCard extends StatefulWidget {
    final Function editCard;
    final Function deleteCard;
    final Function editTags;

    final Card card;
    final List<Tag> tags;

    const EditCard(this.editCard, this.deleteCard, this.editTags, this.card, this.tags, {super.key});

    @override
    State<EditCard> createState() => EditCardState();
}

enum EditDeckImgDropdown { editImage, enterAddress, browseFiles, removeImage }

class EditCardState extends State<EditCard> {
    TextEditingController name        = TextEditingController();
    TextEditingController description = TextEditingController();

    List<TextEditingController> identifiers = <TextEditingController>[];
    List<TextEditingController> notes       = <TextEditingController>[];
    List<TextEditingController> secretNotes = <TextEditingController>[];

    ScrollController scrollController = ScrollController();

    List<Tag> tags     = <Tag>[];
    List<Tag> deckTags = <Tag>[];

    String imgPath = "";

    bool localImage = true;

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

        if(localImage && widget.card.image != ""){
            localImgRoot.then((imgRoot) => setState((){ imgPath = '$imgRoot/${widget.card.image}'; }));
        }

        tags = widget.tags;
    }

    @override
    void dispose(){
        name.dispose();
        description.dispose();
        super.dispose();
    }

    bool editCard(){
        String nameStr        = name.text;
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

        Card card = Card.fromData(nameStr, imgPath, descriptionStr, localImage, identifiersList, notesList, tags);
        return widget.editCard(widget.card, card, deckTags);
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
                        child: PopupMenuButton<EditDeckImgDropdown>(
                            child: localImage?
                                ((imgPath == "")? Image.asset('res/img/img_placeholder.png') : Image.file(File(imgPath))) :
                                Image.network(imgPath),
                            onSelected: (EditDeckImgDropdown item){
                                switch(item){
                                    case EditDeckImgDropdown.editImage:
                                        break;
                                    case EditDeckImgDropdown.enterAddress:
                                        break;
                                    case EditDeckImgDropdown.browseFiles:
                                        FilePicker.platform.pickFiles(type: FileType.image).then((result){
                                            if(result != null && result.files.first.path != null){
                                                setState((){
                                                    localImage = true;
                                                    imgPath = result.files.first.path.toString();
                                                });
                                            }
                                        });
                                        break;
                                    case EditDeckImgDropdown.removeImage:
                                        setState((){ imgPath = ""; });
                                        break;
                                }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<EditDeckImgDropdown>>[
                                const PopupMenuItem<EditDeckImgDropdown>(
                                    value: EditDeckImgDropdown.editImage,
                                    child: Text('Edit image (not working currently)'),
                                ),
                                const PopupMenuItem<EditDeckImgDropdown>(
                                    value: EditDeckImgDropdown.enterAddress,
                                    child: Text('Enter address (not working currently)'),
                                ),
                                const PopupMenuItem<EditDeckImgDropdown>(
                                    value: EditDeckImgDropdown.browseFiles,
                                    child: Text('Browse files'),
                                ),
                                const PopupMenuItem<EditDeckImgDropdown>(
                                    value: EditDeckImgDropdown.removeImage,
                                    child: Text('Remove image'),
                                ),
                            ],
                        ),
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
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Column(
                            children: <Widget>[
                                Row(
                                    children: <Widget>[
                                        const Text("Tags:"),
                                        IconButton(
                                            onPressed: (){
                                                widget.editTags();
                                            },
                                            tooltip: "Edit Tags",
                                            icon: const Icon(Icons.edit_outlined),
                                        ),
                                    ],
                                ),
                                for(int i = 0; i < tags.length; i++) CheckboxListTile(
                                    value: tags[i].selected,
                                    title: Text(tags[i].value),
                                    onChanged: (bool? value){
                                        setState((){ tags[i].selected = value!; });
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