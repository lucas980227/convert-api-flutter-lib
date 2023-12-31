import 'package:clean_api/clean_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:Taillz/Localization/t_keys.dart';
import 'package:Taillz/application/story/get/create/create_story_provider.dart';
import 'package:Taillz/application/story/get/create/create_story_state.dart';
import 'package:Taillz/application/story/get/create/topic_provider.dart';
import 'package:Taillz/application/story/get/story_provider.dart';
import 'package:Taillz/providers/story_provider.dart';
import 'package:Taillz/screens/thoughts/components/thought_detail_text_field.dart';
import 'package:Taillz/screens/thoughts/components/thought_title_textfield.dart';
import 'package:Taillz/screens/thoughts/controller.dart/autogenerated_background.dart';
import 'package:Taillz/utills/constant.dart';
import 'package:Taillz/widgets/custom_flushbar.dart';

class CreateThoughtPostScreen extends HookConsumerWidget {
  CreateThoughtPostScreen({Key? key}) : super(key: key);

  final generate = Get.find<AutoGenBackground>();

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(TKeys.do_you_want.translate(context),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: Text(TKeys.discard_post.translate(context),
                  style: const TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(TKeys.continue_to_write.translate(context),
                  style: const TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    StoryProvider localStoryProvider = StoryProvider();
    // TODO
    // final topics = ref.watch(topicProvider);
    useEffect(() {
      Future.delayed(const Duration(milliseconds: 100), () {
        ref.read(topicProvider.notifier).getTopics();
        return const Center(
          child: CircularProgressIndicator(),
        );
      });
      return null;
    }, []);
    final TextEditingController titleController = useTextEditingController();
    final TextEditingController thoughtsController = useTextEditingController();
    // TODO
    // final commentStatus = useState(1);

    final isLoading = useState(false);
    // TODO
    // bool isLoad = false;
    // final ValueNotifier topic = useState(null);

    ref.listen<CreateStoryState>(createStoryProvider, (previous, next) {
      if (previous?.loading != true && next.loading) {
        isLoading.value = true;
      } else if (previous?.loading == true && !next.loading) {
        isLoading.value = false;
      }
      if (next.failure != CleanFailure.none()) {
        // Navigator.pop(context);
      }
      if (!next.loading && next.failure == CleanFailure.none()) {
        ref.read(storyProvider.notifier).getStories();
        Navigator.pop(context);
        isLoading.value = false;
      }
    });

    return WillPopScope(
      onWillPop: () async {
        if (titleController.text.isNotEmpty ||
            thoughtsController.text.isNotEmpty) {
          await _showDialog(context);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            isLoading.value == true
                ? const SafeArea(
                    child: Center(
                      child: LinearProgressIndicator(
                        color: Color(0xff19334D),
                        minHeight: 2,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
                : SafeArea(
                    child: Container(
                      height: 70,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              generate.generate(0);
                              if (titleController.text.isNotEmpty ||
                                  thoughtsController.text.isNotEmpty) {
                                await _showDialog(context);
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Icon(
                              Icons.arrow_back_ios,
                              size: 27,
                              color: Color(0xff19334D),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                if (titleController.text.isEmpty) {
                                  showFlushBar(context,
                                      TKeys.title_should.translate(context));
                                } else if (titleController.text.length < 5) {
                                  showFlushBar(context,
                                      TKeys.title_should.translate(context));
                                } else if (titleController.text.length > 25) {
                                  showFlushBar(context,
                                      TKeys.title_should.translate(context));
                                } else if (thoughtsController.text.isEmpty) {
                                  showFlushBar(
                                      context,
                                      TKeys.minimum_for_personal
                                          .translate(context));
                                } else if (thoughtsController.text.length <
                                    300) {
                                  showFlushBar(
                                      context,
                                      TKeys.minimum_for_personal
                                          .translate(context));
                                } else {
                                  isLoading.value = true;
                                  localStoryProvider
                                      .createStory(
                                          context: context,
                                          consultGroup: titleController.text,
                                          storyBody: thoughtsController.text,
                                          image: localStoryProvider
                                              .consultImage.first,
                                          whichPage: 'thought',
                                          storyStatus: 2,
                                          isEditMode: false)
                                      .whenComplete(() {
                                    debugPrint('controller data ');
                                    debugPrint(titleController.value.text);
                                    debugPrint(thoughtsController.value.text);
                                    isLoading.value = false;
                                  });
                                }
                              },
                              child: Text(
                                TKeys.Save_as.translate(context),
                                style: TextStyle(
                                    color: Constants.editTextColor,
                                    fontSize: 14,
                                    fontFamily: Constants.fontFamilyName),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              debugPrint('object');
                              if (titleController.text.isEmpty) {
                                showFlushBar(context,
                                    TKeys.title_should.translate(context));
                              } else if (thoughtsController.text.length >
                                  3000) {
                                showFlushBar(context,
                                    TKeys.ToughtsPostLimit.translate(context));
                              } else if (titleController.text.length < 5) {
                                showFlushBar(context,
                                    TKeys.title_should.translate(context));
                              } else if (titleController.text.length > 25) {
                                showFlushBar(context,
                                    TKeys.title_should.translate(context));
                              } else if (thoughtsController.text.isEmpty) {
                                showFlushBar(
                                    context,
                                    TKeys.minimum_for_personal
                                        .translate(context));
                              } else if (thoughtsController.text.length < 300) {
                                showFlushBar(
                                    context,
                                    TKeys.minimum_for_personal
                                        .translate(context));
                              } else {
                                isLoading.value = true;
                                localStoryProvider
                                    .createStory(
                                  context: context,
                                  consultGroup: titleController.value.text,
                                  storyBody: thoughtsController.value.text,
                                  image: localStoryProvider.consultImage.first,
                                  storyStatus: 0,
                                  whichPage: 'thought',
                                )
                                    .whenComplete(() {
                                  debugPrint('controller data ');
                                  debugPrint(titleController.value.text);
                                  debugPrint(thoughtsController.value.text);
                                  isLoading.value = false;
                                });
                              }
                            },
                            child: Text(
                              TKeys.Publish_text.translate(context),
                              style: TextStyle(
                                color: Constants.blueColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: Constants.fontFamilyName,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Constants.editTextBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.only(top: 10, left: 10),
                          height: 50,
                          width: 200,
                          child: ThoughtTitleTextField(
                            textEditingController: titleController,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, left: 5, right: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Constants.editTextBackgroundColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ThoughtDetailTextField(
                                    textEditingController: thoughtsController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
