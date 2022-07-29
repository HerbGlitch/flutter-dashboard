class Deck {
    String title       = "";
    String image       = "";
    String description = "";

    bool localImage = true;

    List<Card> cards = <Card>[];
    List<Tag>  tags  = <Tag >[];

    @override
    bool operator ==(Object other) => identical(this, other) || other is Deck && title == other.title;

    Deck();

    Deck.fromData(this.title, this.image, this.description, this.localImage);

    Deck.fromJson(Map<String, dynamic> data){
        title       = data['title'      ];
        image       = data['image'      ];
        description = data['description'];
        localImage  = data['localImage' ];

        if(data.containsKey('cards')){
            for(Map<String, dynamic> subData in data['cards']){
                cards.add(Card.fromJson(subData));
            }
        }

        if(data.containsKey('tags')){
            for(Map<String, dynamic> subData in data['tags']){
                tags.add(Tag.fromJson(subData));
            }
        }
    }

    Map<String, dynamic> toJson(){
        Map<String, dynamic> data = <String, dynamic>{};

        data['title'      ] = title;
        data['image'      ] = image;
        data['description'] = description;
        data['localImage' ] = localImage;

        if(cards.isNotEmpty){ data['cards'] = <dynamic>[]; }
        for(Card card in cards){ data['cards'].add(card.toJson()); }

        if(tags.isNotEmpty){ data['tags'] = <dynamic>[]; }
        for(Tag tag in tags){ data['tags'].add(tag.toJson()); }

        return data;
    }

    @override
    int get hashCode => title.hashCode;
}

class Card {
    String name        = "";
    String image       = "";
    String description = "";

    bool localImage = true;

    List<String> identifiers = <String>[];
    List<Note  > notes       = <Note  >[];
    List<Tag   > tags        = <Tag   >[];

    @override
    bool operator ==(Object other) => identical(this, other) || other is Card && name == other.name;

    Card();

    Card.fromData(this.name, this.image, this.description, this.localImage, this.identifiers, this.notes, this.tags);

    Card.fromJson(Map<String, dynamic> data){
        name        = data['name'       ];
        image       = data['image'      ];
        description = data['description'];
        localImage  = data['localImage' ];

        if(data.containsKey('identifiers')){
            for(String identifier in data['identifiers']){
                identifiers.add(identifier);
            }
        }

        if(data.containsKey('notes')){
            for(Map<String, dynamic> subData in data['notes']){
                notes.add(Note.fromJson(subData));
            }
        }

        if(data.containsKey('tags')){
            for(Map<String, dynamic> subData in data['tags']){
                tags.add(Tag.fromJson(subData));
            }
        }
    }

    Map<String, dynamic> toJson(){
        Map<String, dynamic> data = <String, dynamic>{};

        data['name'       ] = name;
        data['image'      ] = image;
        data['description'] = description;
        data['localImage' ] = localImage;

        if(identifiers.isNotEmpty){ data['identifiers'] = <dynamic>[]; }
        for(String identifier in identifiers){
            data['identifiers'].add(identifier);
        }

        if(notes.isNotEmpty){ data['notes'] = <dynamic>[]; }
        for(Note note in notes){ data['notes'].add(note.toJson()); }

        if(tags.isNotEmpty){ data['tags'] = <dynamic>[]; }
        for(Tag tag in tags){ data['tags'].add(tag.toJson()); }

        return data;
    }

    @override
    int get hashCode => name.hashCode;
}

class Note {
    bool   private = true;
    String value   = ""  ;

    Note.fromData(this.private, this.value);

    Note.fromJson(Map<String, dynamic> data){
        private = data['private'];
        value   = data['value'  ];
    }

    Map<String, dynamic> toJson(){
        Map<String, dynamic> data = <String, dynamic>{};

        data['private'] = private;
        data['value'  ] = value;

        return data;
    }
}

class Tag {
    bool   selected = false;
    String value    = "";

    Tag.fromData(this.selected, this.value);

    Tag.fromJson(Map<String, dynamic> data){
        selected = data['selected'];
        value    = data['value'   ];
    }

    Map<String, dynamic> toJson(){
        Map<String, dynamic> data = <String, dynamic>{};

        data['selected'] = selected;
        data['value'   ] = value;

        return data;
    }
}