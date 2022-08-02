import 'package:dashboard/objects.dart';
import 'package:flutter/material.dart';

class EditTagsDialog extends StatefulWidget {
    final Deck deck;
    final Function saveTags;

    const EditTagsDialog(this.deck, this.saveTags, {super.key});

    @override
    State<EditTagsDialog> createState() => EditTagsDialogState();
}

class EditTagsDialogState extends State<EditTagsDialog> {
    List<TextEditingController> tagsController = <TextEditingController>[];

    @override
    void initState(){
        super.initState();

        for(Tag tag in widget.deck.tags){
            setState((){ tagsController.add(TextEditingController(text: tag.value)); });
        }
    }

    @override
    Widget build(BuildContext context){
        return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 80.0),
            child: Column(
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: Row(
                            children: <Widget>[
                                const Text('Manage Tags', style: TextStyle(fontSize: 20)),
                                IconButton(
                                    onPressed: (){
                                        setState((){ tagsController.add(TextEditingController()); });
                                    },
                                    tooltip: 'Add Tag',
                                    icon: const Icon(Icons.add_outlined)
                                ),
                                const Spacer(),
                                IconButton(
                                    onPressed: (){ Navigator.pop(context); },
                                    tooltip: 'Close',
                                    icon: const Icon(Icons.close_outlined),
                                ),
                            ],
                        ),
                    ),
                    ReorderableListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        children: <Widget>[
                            for(int i = 0; i < tagsController.length; i++) ListTile(
                                key: Key('$i'),
                                leading: IconButton(
                                    onPressed: (){ setState((){ tagsController.removeAt(i); }); },
                                    tooltip: "",
                                    icon: const Icon(Icons.close_outlined),
                                ),
                                title: TextField(
                                    decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'Type tag here',
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                    controller: tagsController[i],
                                    maxLines: null,
                                ),
                            )
                        ],
                        onReorder: (int old, int current){
                            setState((){
                                if(old < current){ current -= 1; }
                                final TextEditingController tag = tagsController.removeAt(old);
                                setState((){ tagsController.insert(current, tag); });
                            });
                        },
                    ),
                    const Spacer(),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Row(
                            children: <Widget>[
                                const Spacer(),
                                SimpleDialogOption(
                                    onPressed: (){
                                        List<Tag> tags = <Tag>[];
                                        for(TextEditingController tagController in tagsController){
                                            tags.add(Tag.fromData(false, tagController.text));
                                        }
                                        widget.saveTags(tags);
                                        Navigator.pop(context);
                                    },
                                    child: const Text('SAVE', style: TextStyle(fontSize: 15)),
                                ),
                            ],
                        ),
                    ),
                ],
            )
        );
    }
}