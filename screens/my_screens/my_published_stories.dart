import 'dart:convert';

import 'package:Taillz/screens/my_screens/my_stories_provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:clean_api/clean_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:Taillz/Localization/t_keys.dart';
import 'package:Taillz/domain/auth/models/user_info.dart';
import 'package:Taillz/domain/story/story_model.dart';
import 'package:Taillz/post_background_image_controller.dart';
import 'package:Taillz/providers/widget_provider.dart';
import 'package:Taillz/utills/api_network.dart';
import 'package:Taillz/utills/constant.dart';
import 'package:Taillz/widgets/story_card.dart';

// ignore: must_be_immutable
class MyPublishedStories extends StatefulWidget {
  UserInfo? userInfo;
  BuildContext context;
  MyPublishedStories({Key? key, this.userInfo, required this.context})
      : super(key: key);

  @override
  State<MyPublishedStories> createState() => _MyPublishedStoriesState();
}

class _MyPublishedStoriesState extends State<MyPublishedStories> {
  int? currentIndex;
  List<StoryModel>? myPublishedStories;
  bool isLoaded = false;
  int index = 0;
  int pageNumber = 0;
  int imageIndex = 0;
  bool hideBottomLoader = false;
  List<bool> isFalse=[];

  final ScrollController _scrollController = ScrollController();

  List<String> consultImages = [
    'assets/images/consult/1.png',
    'assets/images/consult/2.png',
    'assets/images/consult/3.png',
    'assets/images/consult/4.png',
    'assets/images/consult/5.png',
    'assets/images/consult/6.png',
    'assets/images/consult/7.png',
    'assets/images/consult/8.png',
  ];

  List<String> consultGroupNames = [
    'Relationship',
    'Women Talk',
    'Motherhood',
    'Divorced',
    'LGBT',
    'Humanity',
    'Discrimination',
    'Vegan',
  ];

  var globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getMyPublication();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          pageNumber++;
        });

        getMyPublication();
        // _storyProvider.getStoriesbyGroup(context: context, pageNo: '1');
      }
    });
  }


  getMyPublication() async {
    var box = GetStorage();
    Logger.e(box.read('userTokenForAuth'));
    Uri uri = Uri.tryParse(
      '${ApiNetwork.getStories}?Me=1&status=1&page=$pageNumber',
    )!;
    WidgetProvider widgetProvider = Provider.of<WidgetProvider>(
      context,
      listen: false,
    );
    await widgetProvider
        .returnConnection()
        .get(
          uri,
          headers: Constants.authenticatedHeaders(
              context: context, userToken: box.read('userTokenForAuth')),
        )
        .catchError(
      (err) {
        throw err;
      },
    ).then((value) {
      MyStoriesProvider myStoriesProvider=Provider.of<MyStoriesProvider>(context,listen: false);
      var response = json.decode(value.body);
      if (response['errors'] != null && response['errors'].isNotEmpty) {
        BotToast.showText(
          text: '${response['errors'][0]['message']}',
          contentColor: Constants.blueColor,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        );
      } else {
        myPublishedStories ??= [];
        Logger.e(response['payload']);
        response['payload'].forEach(
          (element) {
            myPublishedStories!.add(StoryModel.fromMap(element));

            if (element['story']['title'] == null ||
                element['story']['title'] == '') {
              myPublishedStories![index].category =
                  element['story']['category'];
            } else {
              myPublishedStories![index].category = '1';
            }

            Logger.e(element['story']);
            if (element['story']['title'] == null ||
                element['story']['title'] == '') {
              Logger.w(element['story']['category']);
              int categoryIndex =
                  consultGroupNames.indexOf(element['story']['category']);
              Logger.i(categoryIndex);
              myPublishedStories![index].image = consultImages[categoryIndex];
            } else {
              myPublishedStories![index].image =
                  PostBackgroundImageController.bgImages[imageIndex];
              String title = myPublishedStories![index].story.title;
              if (consultGroupNames.contains(title)) {
                List<String> translatedName = [
                  TKeys.Relationship_text.translate(context),
                  TKeys.Women_talk_text.translate(context),
                  TKeys.Motherhood_text.translate(context),
                  TKeys.Divorced_text.translate(context),
                  TKeys.LGBT_text.translate(context),
                  TKeys.Humanity_text.translate(context),
                  TKeys.Discrimination_text.translate(context),
                  TKeys.Vegan_text.translate(context),
                ];
                int whichIndex = consultGroupNames.indexOf(title);
                myPublishedStories![index].story.title =
                    translatedName[whichIndex];
              }
            }

            index++;
            if (imageIndex ==
                PostBackgroundImageController.bgImages.length - 1) {
              imageIndex = -1;
            }
            imageIndex++;
          },
        );

        if (pageNumber >= 0 && response['payload'].length == 0 ||
            response['payload'].length < 8) {

          Logger.i(response['payload']);
          hideBottomLoader = true;
        }


        for(int i = 0;i<myPublishedStories!.length;i++){
          isFalse.add(myPublishedStories![i].likedByMe);
        }
        myStoriesProvider.isLikeDataFalse(isFalse);
        setState(() {
          isLoaded = true;
        });


      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // UserProvider _userProvider = Provider.of<UserProvider>(context);
    // myPublishedStories = [...myPublishedStories!.where((element) => element.userId == widget.userInfo!.id)];

    return Container(
      child: myPublishedStories == null && isLoaded == false
          ?const Center(
        child: SpinKitFadingFour(
          size: 60,
          color: Color(0xff52527a),
        ),
      ):myPublishedStories!.isEmpty
          ? Center(
            child: Text(TKeys.NoNewPublishedPost.translate(context)),
          )
          : ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: myPublishedStories!.length + 1,
            itemBuilder: (context, index) {
              if (index < myPublishedStories!.length) {
                return StoryCard(
                  isFalse: myPublishedStories?.length ?? 0,
                    isMyStories: true,
                    Index: index,
                    img: myPublishedStories![index].image!,
                    story: myPublishedStories![index],
                    route: 'myPublishedStories',
                    userInfo: widget.userInfo);
              } else {
                return hideBottomLoader
                    ? Container()
                    : const Center(
                  child: SpinKitFadingFour(
                    size: 40,
                    color: Color(0xff52527a),
                  ),
                );
              }
            },
          ),
    );
  }
}
