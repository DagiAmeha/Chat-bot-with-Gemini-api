import 'dart:developer' as dev;

import 'package:chat_bot/api/api_service.dart';
import 'package:chat_bot/constants.dart';
import 'package:chat_bot/hive/boxes.dart';
import 'package:chat_bot/hive/chat_history.dart';
import 'package:chat_bot/hive/settings.dart';
import 'package:chat_bot/hive/user_model.dart';
import 'package:chat_bot/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:generative_ai_dart/generative_ai_dart.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  // list of messages
  List<ChatHistory> chatHistory = [];

  // pagecontroller
  final PageController pageController = PageController();

  //  images file list
  List<XFile>? _imagesFileList = [];

  int _currentIndex = 0;

  // current chatID
  String _currentChatId = '';

  List<Message>? _inChatMessages = [];

  // initialize generative model
  GenerativeModel? _model;

  // initilize text model
  GenerativeModel? _textModel;

  // initialize image picker
  GenerativeModel? _visionModel;

  // current mode
  String _modelType = 'gemini-1.5-pro-latest';

  // loading bool
  bool isLoading = false;

  // getters
  List<Message>? get inChatMessages => _inChatMessages;
  // PageController get pageController => _pageController;
  List<ChatHistory> get chatHistoryList => chatHistory;
  // PageController get pageController => pageController;
  List<XFile>? get imagesFileList => _imagesFileList;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  // Initialize Hive and register adapters

  // setters
  // set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    // get messages from hive
    final messages = await loadMessagesFromDB(chatId);

    for (var message in messages) {
      if (_inChatMessages!.contains(message)) {
        dev.log('message already exists');
        continue;
      }
      _inChatMessages!.add(message);
    }
    notifyListeners();
  }

  // load the messages from the db
  Future<List<Message>> loadMessagesFromDB(String chatId) async {
    // open messages box
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');
    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = Message.fromJson(
        (Map<String, dynamic>.from(message)),
      );
      return messageData;
    }).toList();
    notifyListeners();

    return newData;
  }

  // set file list
  void setImagesFileList(List<XFile> listView) {
    _imagesFileList = listView;
    notifyListeners();
  }

  // set the current model
  String setCurrentModel(String newModel) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  // function to set the model based on  bool - istextonly
  Future<void> setModel(bool isTextOnly) async {
    if (isTextOnly) {
      _textModel ??= GenerativeModel(
        model: 'gemini-1.5-pro-latest',
        apiKey: ApiService.apiKey,
      );
      _model = _textModel;
    } else {
      _visionModel ??= GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: ApiService.apiKey,
      );
      _model = _visionModel;
    }

    notifyListeners();
  }

  // set current page indes
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // set current chat id
  void setCurrentChatId(String chatId) {
    _currentChatId = chatId;
    notifyListeners();
  }

  // set loading bool
  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  //  prepare chat room

  Future<void> deleteChatMessages({required String chatId}) async {
    // check if the box is open
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    } else {
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    if (currentChatId.isNotEmpty) {
      if (currentChatId == chatId) {
        setCurrentChatId("");
        notifyListeners();
      }
    }
  }

  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatId,
  }) async {
    if (!isNewChat) {
      // load the chat message from the db
      final chatHistory = await loadMessagesFromDB(chatId);

      _inChatMessages?.clear();

      for (var message in chatHistory) {
        _inChatMessages?.add(message);
      }

      setCurrentChatId(chatId);
    } else {
      _inChatMessages?.clear();
      setCurrentChatId(chatId);
    }
  }

  // send message to gemini and get the streamed response
  Future<void> sendMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    await setModel(isTextOnly);
    setLoading(true);

    String chatId = getChatId();

    // list of history messages
    List<Content> history = [];

    // get the chat history
    history = await getHistory(chatId: chatId);

    // get the image urls
    List<String> imageUrls = getImageUrls(isTextOnly: isTextOnly);

    final messagesBox = await Hive.openBox(
      '${Constants.chatMessagesBox}$chatId',
    );
    // user messageId
    final userMessageId = messagesBox.keys.length;

    // assistant messageId
    final assistantMessageId = messagesBox.keys.length + 1;
    // user message
    final userMessage = Message(
      messageId: userMessageId.toString(),
      chatId: chatId,
      role: Role.user.name,
      message: StringBuffer(message),
      imagesUrls: imageUrls,
      timeSent: DateTime.now(),
    );

    // add the user message to the in chat messages
    _inChatMessages!.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(chatId);
    }

    // send message to gemini and wait for the response
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
      modelMessageId: assistantMessageId.toString(),
    );
  }

  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
    required String modelMessageId,
  }) async {
    // start the chat session
    final chatSession = _model?.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );

    //  get content
    final content = await getContent(message: message, isTextOnly: isTextOnly);

    // assistant message
    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      message: StringBuffer(),
      role: Role.assistant.name,
      timeSent: DateTime.now(),
    );

    // add this message to the list on inChatMessages
    _inChatMessages!.add(assistantMessage);
    notifyListeners();

    // wait for stream response
    chatSession!
        .sendMessageStream(content)
        .listen(
          (event) {
            _inChatMessages!
                .firstWhere(
                  (element) =>
                      element.messageId == assistantMessage.messageId &&
                      element.role == Role.assistant.name,
                )
                .message
                .write(event.text);
            notifyListeners();
          },
          onDone: () async {
            // save the message to the db
            final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');
            final messageId = const Uuid().v4();
            assistantMessage.messageId = messageId;
            messageBox.put(messageId, assistantMessage.toJson());

            notifyListeners();

            // set loading to false
            setLoading(false);

            await saveMessagesToDB(
              chatId: chatId,
              userMessage: userMessage,
              assistantMessage: assistantMessage,
              messagesBox: messageBox,
            );
          },
          onError: (error) {
            dev.log('Error: $error');
            setLoading(false);
          },
        )
        .onError((error, stackTrace) {
          dev.log('Error: $error');
          setLoading(false);
        });
  }

  Future<Content> getContent({
    required String message,
    required bool isTextOnly,
  }) async {
    if (isTextOnly) {
      // egenerate text from text only input
      return Content.text(message);
    } else {
      // generate model from image and text input
      final imageFutures = _imagesFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);
      final imageBytes = await Future.wait(imageFutures!);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();
      return Content.multi([prompt, ...imageParts]);
    }
  }

  List<String> getImageUrls({required bool isTextOnly}) {
    List<String> imageUrls = [];
    if (!isTextOnly && _imagesFileList != null) {
      for (var file in _imagesFileList!) {
        imageUrls.add(file.path);
      }
    }
    return imageUrls;
  }

  // save messages to hive db
  Future<void> saveMessagesToDB({
    required String chatId,
    required Message userMessage,
    required Message assistantMessage,
    required Box messagesBox,
  }) async {
    dev.log('*****Saving chat history for $chatId');

    await messagesBox.put(userMessage.messageId, userMessage.toJson());
    await messagesBox.put(
      assistantMessage.messageId,
      assistantMessage.toJson(),
    );

    final chatHistoryBox = Boxes.getChatHistory();

    final chatHistory = ChatHistory(
      chatId: chatId,
      prompt: userMessage.message.toString(),
      response: assistantMessage.message.toString(),
      images: userMessage.imagesUrls,
      timestamp: DateTime.now(),
    );

    await chatHistoryBox.put(chatId, chatHistory);

    // await messagesBox.close();
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);
      for (var message in inChatMessages!) {
        if (message.role == Role.user.name) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }
    return history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    // register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());

      // open the chat history box
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());

      // open the user box
      await Hive.openBox<UserModel>(Constants.userBox);
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());

      // open the settings box
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
