import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/feed/components/buttonPlay.dart';
import 'package:podiz/home/feed/components/cardButton.dart';
import 'package:podiz/profile/followerProfilePage.dart';

class DiscussionCard extends StatefulWidget {
  DiscussionCard({Key? key}) : super(key: key);

  @override
  State<DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<DiscussionCard> {
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        color: theme.colorScheme.surface,
        width: kScreenWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: ()=> Navigator.pushNamed(context, FollowerProfilePage.route) ,
                      child: CircleAvatar(
                          backgroundColor: theme.primaryColor, radius: 20)),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Tonny Anderson",
                            style: discussionCardProfile(),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text("907 followers",
                                style: discussionCardFollowers())),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ButtonPlay(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Laoreet scelerisque nibh dictum aliquet. Sociis vitae, massa lectus pharetra ante morbi sed. Lectus tortor, ut pellentesque magna netus enim lectus auctor feugiat. Maecenas at ultricies augue et eu.",
                  style: discussionCardComment(),
                  textAlign: TextAlign.left,),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 249,
                    height: 31,
                    child: const TextField(
                      // controller: commentController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText:
                              "Comment on Tonny's insight..."), //TODO change this
                    ),
                  ),
                  const Spacer(),
                  CardButton(
                    const Icon(
                      Icons.save_alt_rounded,
                      color: Color(0xFF9E9E9E),
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 16),
                  CardButton(
                    const Icon(
                      Icons.share,
                      color: Color(0xFF9E9E9E),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
