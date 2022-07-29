import 'package:dashboard/objects.dart';
import 'package:dashboard/files.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditDeck extends StatefulWidget {
    final Function editDeck;
    final Function deleteDeck;

    final Deck deck;

    const EditDeck(this.editDeck, this.deleteDeck, this.deck, {super.key});

    @override
    State<EditDeck> createState() => EditDeckState();
}

enum EditDeckImgDropdown { editImage, enterAddress, browseFiles, removeImage }

class EditDeckState extends State<EditDeck> {
    TextEditingController title       = TextEditingController();
    TextEditingController description = TextEditingController();

    String imgPath = "";

    bool localImage = true;

    ScrollController scrollController = ScrollController();

    bool delete = false;

    @override
    void initState(){
        super.initState();

        title       = TextEditingController(text: widget.deck.title      );
        description = TextEditingController(text: widget.deck.description);

        setState((){ localImage = widget.deck.localImage; });
        if(localImage && widget.deck.image != ""){
            localImgRoot.then((imgRoot) => setState((){ imgPath = '$imgRoot/${widget.deck.image}'; }));
        }
    }

    @override
    void dispose(){
        title.dispose();
        description.dispose();
        super.dispose();
    }

    bool editDeck(){
        String titleStr       = title.text;
        String descriptionStr = description.text;

        Deck deck = Deck.fromData(titleStr, imgPath, descriptionStr, localImage);
        return widget.editDeck(widget.deck, deck);
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
                                        setState((){
                                            localImage = true;
                                            imgPath = "";
                                        });
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
            bottomNavigationBar: EditDeckBottomBar(editDeck, title),
        );
    }
}

class EditDeckBottomBar extends StatelessWidget {
    final Function editDeck;
    final TextEditingController title;
    const EditDeckBottomBar(this.editDeck, this.title, {super.key});

    @override
    Widget build(BuildContext context){
        return BottomAppBar(
            child: IconTheme(
                data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                child: Row(
                    children: <Widget>[
                        const EditDeckBackBtn(),
                        const Spacer(),
                        EditDeckSaveBtn(editDeck, title)
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
    const EditDeckSaveBtn(this.editDeck, this.title, {super.key});

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
                else if(!editDeck()){
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