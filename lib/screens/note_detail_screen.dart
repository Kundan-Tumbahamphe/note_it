import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:noteit/configs/configs.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:noteit/helpers/helpers.dart';
import 'package:noteit/models/models.dart';
import 'package:noteit/services/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteDetailScreen extends StatefulWidget {
  final DatabaseService databaseService;
  final StorageService storageService;
  final Note note;

  NoteDetailScreen(
      {@required this.databaseService,
      @required this.storageService,
      this.note});

  static Widget create({@required BuildContext context, Note note}) {
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);

    return NoteDetailScreen(
      databaseService: databaseService,
      storageService: storageService,
      note: note,
    );
  }

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen>
    with SingleTickerProviderStateMixin {
  final _contentFocusNode = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _urlFormKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _isLoading = false;

  AnimationController _animationController;
  Animation _curve;
  Animation<double> _sizeAnimation;

  final List<HexColor> _noteColors = [
    HexColor('#FFAB91'),
    HexColor('#FFCC7F'),
    HexColor('#80DEEA'),
    HexColor('#CF93D9'),
    HexColor('#F48FB1'),
  ];

  final List<String> _imageSources = [
    Constants.sourceCamera,
    Constants.sourceGallery,
  ];

  bool _isFavourite = false;
  TextEditingController _titleController = TextEditingController();
  DateTime _createdOn = DateTime.now();
  TextEditingController _subtitleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  List<dynamic> _links = [];
  Color _colorSelected = HexColor('#FFAB91');
  List<dynamic> _images = [];

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final Note note = widget.note;

      _isFavourite = note.isFavourite;
      _titleController.text = note.title;
      _createdOn = note.timestamp;
      _subtitleController.text = note.subtitle;
      _contentController.text = note.content;
      _links = note.links;
      _colorSelected = note.color;
      _images = note.imageUrls;
    } else {
      SchedulerBinding.instance.addPostFrameCallback(
          (_) => FocusScope.of(context).requestFocus(_contentFocusNode));
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _curve =
        CurvedAnimation(parent: _animationController, curve: Curves.slowMiddle);

    _sizeAnimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 24.0, end: 44.0),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 44.0, end: 24.0),
          weight: 50.0,
        ),
      ],
    ).animate(_curve);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFavourite = true;
        });
      }
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _isFavourite = false;
        });
      }
    });

    if (_isFavourite) {
      _animationController.forward();
    }
  }

  Future<List<String>> _uploadImage() async {
    List<String> imageUrls = [];

    for (dynamic image in _images) {
      if (image is File) {
        String url =
            await widget.storageService.uploadNoteImageAndGetDownloadUrl(image);
        imageUrls.add(url);
      } else if (image is String) {
        imageUrls.add(image);
      }
    }

    return imageUrls;
  }

  Future<void> _setNote() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final Note note = Note(
        id: _isEditing ? widget.note.id : null,
        title: _titleController.text,
        timestamp: DateTime.now(),
        subtitle: _subtitleController.text,
        color: _colorSelected,
        isFavourite: _isFavourite,
        content: _contentController.text,
        links: _links,
        imageUrls: await _uploadImage(),
      );

      if (_isEditing) {
        await widget.databaseService.updateNote(note: note);
      } else {
        await widget.databaseService.addNote(note: note);
        Navigator.of(context).pop();
      }
    } on Failure catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(e.message);
    }
  }

  Future<void> _deleteNote() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await widget.databaseService.deleteNote(note: widget.note);
      for (dynamic image in _images) {
        if (image is String) {
          await _deleteImage(image);
        }
      }
      Navigator.of(context).pop();
    } on Failure catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(e.message);
    }
  }

  Future<bool> _updateNote() async {
    if (_isEditing) {
      if (!_validatetitleSubtitle()) {
        return Future.value(false);
      } else {
        await _setNote();
      }
    }

    return Future.value(true);
  }

  Future<void> _deleteImage(String imageUrl) async {
    await widget.storageService.deleteImage(imageUrl);
  }

  bool _validatetitleSubtitle() {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Title cannot be empty.');
      return false;
    } else if (_subtitleController.text.trim().isEmpty) {
      _showSnackBar('Subtitle cannot be empty');
      return false;
    }
    return true;
  }

  Future<void> _launchUrlInApp(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceWebView: true,
        enableJavaScript: true,
        enableDomStorage: true,
      );
    } else {
      _showSnackBar('Cannot launch url.');
    }
  }

  Future<void> _handleImage(ImageSource source) async {
    PickedFile pickedFile = await ImagePicker().getImage(source: source);

    if (pickedFile != null) {
      File image = File(pickedFile.path);

      File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'NoteIt',
          activeControlsWidgetColor: Constants.mainDesignColor,
        ),
      );

      if (croppedImage != null) {
        setState(() {
          _images.add(croppedImage);
        });
      } else {
        _showSnackBar('Couldnot crop image');
      }
    } else {
      _showSnackBar('Couldnot pick image');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, size: 22.0),
          const SizedBox(width: 5.0),
          Text(message),
        ],
      ),
    );

    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _updateNote,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0.0,
          actions: <Widget>[
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return IconButton(
                  icon: Icon(
                    _isFavourite ? Icons.star : Icons.star_border,
                    size: _sizeAnimation.value,
                  ),
                  onPressed: () {
                    _isFavourite
                        ? _animationController.reverse()
                        : _animationController.forward();
                  },
                );
              },
            ),
            _buildImageButton(),
            _buildLinkButton(),
            SizedBox(width: 10.0),
            Container(
              width: 122.0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: FlatButton(
                onPressed: () {
                  if (_isEditing) {
                    _deleteNote();
                  } else if (_validatetitleSubtitle()) {
                    _setNote();
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(
                    width: 2.0,
                    color: Constants.mainDesignColor,
                  ),
                ),
                child: Text(
                  _isEditing ? 'Delete' : 'Save',
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _isLoading ? LinearProgressIndicator() : const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 10.0,
                  bottom: 80.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: _titleController,
                      keyboardType: TextInputType.text,
                      decoration:
                          const InputDecoration.collapsed(hintText: 'Title'),
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    Text(
                      DateFormat.yMMMMEEEEd().add_jm().format(_createdOn),
                      style: const TextStyle(fontSize: 12.0),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 15.0),
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: _colorSelected, width: 4.0),
                        ),
                      ),
                      child: TextField(
                        controller: _subtitleController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration.collapsed(
                            hintText: 'Subtitle'),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                      ),
                    ),
                    _images.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 15.0),
                            height: 120.0,
                            child: ListView.builder(
                              physics: ClampingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                final dynamic image = _images[index];
                                return _buildImage(image);
                              },
                            ),
                          )
                        : SizedBox.shrink(),
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Write note here :)',
                      ),
                      style: const TextStyle(
                        fontSize: 16.0,
                        height: 1.2,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                    ),
                    SizedBox(height: 2.0),
                    _links.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildLinks(),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          height: 45.0,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildColorPicker(),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Icon(Icons.arrow_left),
                      Text(
                        'Pick Color',
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildImageButton() {
    return PopupMenuButton(
      icon: const Icon(Icons.photo_camera),
      onSelected: (value) {
        if (value == Constants.sourceCamera) {
          _handleImage(ImageSource.camera);
        } else if (value == Constants.sourceGallery) {
          _handleImage(ImageSource.gallery);
        }
      },
      itemBuilder: (context) {
        return _imageSources.map((choice) {
          return PopupMenuItem(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  _buildImage(dynamic image) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Stack(
        children: <Widget>[
          image is File
              ? Image.file(image, fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                ),
          Positioned(
            top: -10.0,
            right: -10.0,
            child: IconButton(
              icon: const Icon(
                Icons.remove_circle,
                color: Constants.mainDesignColor,
              ),
              iconSize: 22.0,
              onPressed: () {
                if (image is String) {
                  _deleteImage(image);
                }
                setState(() {
                  _images.remove(image);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildLinkButton() {
    return IconButton(
      icon: const Icon(Icons.insert_link),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              title: Text('Add Url'),
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
                letterSpacing: 1.0,
                color: Constants.mainDesignColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              content: Form(
                key: _urlFormKey,
                autovalidate: _autoValidate,
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  style: const TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(5.0),
                    hintText: 'Enter url',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Constants.mainDesignColor,
                      ),
                    ),
                  ),
                  validator: (inputValue) {
                    if (inputValue.trim().isEmpty) {
                      return 'Url is required';
                    } else if (!Validator.validUrl(inputValue)) {
                      return 'Please enter valid url';
                    }

                    return null;
                  },
                  onSaved: (inputValue) {
                    setState(() {
                      _links.add(inputValue.trim());
                    });
                  },
                ),
              ),
              contentPadding: const EdgeInsets.all(15.0),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Cancel',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Constants.mainDesignColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text(
                    'Done',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Constants.mainDesignColor,
                    ),
                  ),
                  onPressed: () {
                    if (_urlFormKey.currentState.validate()) {
                      _urlFormKey.currentState.save();
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        _autoValidate = true;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  _buildLinks() {
    return _links.map((url) {
      return Row(
        children: <Widget>[
          GestureDetector(
            child: Text(
              url,
              style: const TextStyle(
                decoration: TextDecoration.underline,
                height: 2.0,
              ),
            ),
            onTap: () {
              _launchUrlInApp(url);
            },
          ),
          const SizedBox(width: 14.0),
          GestureDetector(
            onTap: () {
              setState(() {
                _links.remove(url);
              });
            },
            child: const Icon(
              Icons.delete,
              size: 18.0,
              color: Constants.mainDesignColor,
            ),
          ),
        ],
      );
    }).toList();
  }

  _buildColorPicker() {
    return _noteColors.map((color) {
      bool isSelected = _colorSelected == color;

      return GestureDetector(
        onTap: () {
          setState(() {
            _colorSelected = color;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(2.0),
          width: 26.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Stack(
            children: <Widget>[
              Container(
                width: 24.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: isSelected
                      ? Border.all(
                          width: 2.0,
                          color: Colors.black87,
                        )
                      : null,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 15.0,
                        color: Colors.black87,
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _contentFocusNode.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
