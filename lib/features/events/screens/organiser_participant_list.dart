import 'package:cached_network_image/cached_network_image.dart';
import 'package:elderly_community/data/repositories/user/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/curved_app_bar.dart';
import '../../contacts/screens/widgets/shimmer_loading_item.dart';
import '../../profile/controllers/user_controller.dart';
import '../models/event_model.dart';

class OrganiserEventParticipantsListScreen extends StatelessWidget {
  const OrganiserEventParticipantsListScreen({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Participants"),
        ),
      ),
      body: ListView.builder(
        itemCount: event.registrations.length,
        itemBuilder: (context, index) {
          String userId = event.registrations[index];
          return FutureBuilder(
            future: UserRepository.instance.fetchUserDetails(userId: userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ShimmerLoadingItem();
              }
              if (!snapshot.hasData) {
                return ListTile(title: Text("User not found"));
              }
              final user = snapshot.data!;
              return ListTile(
                leading: (user.profilePicture.isNotEmpty)
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.profilePicture,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 25,
                            child: Icon(Icons.person,
                                color: Colors.white, size: 50),
                          ),
                        ),
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 25,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 25),
                      ),
                title: Text(user.name),
                subtitle: Text(user.email),
              );
            },
          );
        },
      ),
    );
  }
}
