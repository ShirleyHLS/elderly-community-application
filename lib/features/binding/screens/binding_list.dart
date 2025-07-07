import 'package:cached_network_image/cached_network_image.dart';
import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:elderly_community/features/binding/models/binding_model.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/curved_app_bar.dart';
import 'caregiver_send_request.dart';
import 'elderly_accept_request.dart';

class BindingListScreen extends StatelessWidget {
  const BindingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BindingController());

    void showSendRequestModal() {
      Get.bottomSheet(
        SendBindingRequestModal(),
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.white,
      );
    }

    void showAcceptModalDialog(BindingModel binding) {
      Get.dialog(AcceptBindingRequestModal(
        id: binding.id!,
        caregiverId: binding.caregiverId,
        caregiverName: binding.caregiverName!,
      ));
    }

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text("Binding"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.bindingList.isEmpty) {
                  return Center(child: Text("No bindings found"));
                }

                return RefreshIndicator(
                  onRefresh: () async => controller.fetchBingdings(),
                  child: ListView.builder(
                    itemCount: controller.bindingList.length,
                    itemBuilder: (context, index) {
                      final binding = controller.bindingList[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: binding.status ==
                                      BindingStatus.pending
                                          .toString()
                                          .split('.')
                                          .last &&
                                  controller.role == "elderly"
                              ? () => showAcceptModalDialog(binding)
                              : null,
                          child: Card(
                            color: binding.status ==
                                    BindingStatus.pending
                                        .toString()
                                        .split('.')
                                        .last
                                ? Colors.yellow[100]
                                : binding.status ==
                                        BindingStatus.approved
                                            .toString()
                                            .split('.')
                                            .last
                                    ? Colors.grey[100]
                                    : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.only(
                                  left: 15.0,
                                  right: 5.0,
                                  top: 3.0,
                                  bottom: 3.0),
                              leading: SizedBox(
                                width: 40,
                                height: 40,
                                child: controller.role == "elderly"
                                    ? (binding.caregiverProfile != null &&
                                            binding
                                                .caregiverProfile!.isNotEmpty)
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  binding.caregiverProfile!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                child: Icon(Icons.person,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        : const CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            child: Icon(Icons.person,
                                                color: Colors.white),
                                          )
                                    : (binding.elderlyProfile != null &&
                                            binding.elderlyProfile!.isNotEmpty)
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: binding.elderlyProfile!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                child: Icon(Icons.person,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        : const CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            child: Icon(Icons.person,
                                                color: Colors.white),
                                          ),
                              ),
                              title: Text(controller.role == "elderly"
                                  ? binding.caregiverName!
                                  : binding.elderlyName!),
                              trailing: binding.status ==
                                      BindingStatus.approved
                                          .toString()
                                          .split('.')
                                          .last
                                  ? IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: "Delete Confirmation",
                                          middleText:
                                              "Are you sure you want to delete this binding?",
                                          textConfirm: "Yes",
                                          textCancel: "No",
                                          confirmTextColor: Colors.white,
                                          cancelTextColor: Colors.black,
                                          buttonColor: ECColors.error,
                                          onConfirm: () {
                                            controller
                                                .deleteBinding(binding.id!);
                                          },
                                        );
                                      },
                                    )
                                  : Text('Requested'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: controller.role == "caregiver"
          ? FloatingActionButton(
              onPressed: showSendRequestModal,
              shape: CircleBorder(),
              backgroundColor: ECColors.primary,
              child: Icon(
                Icons.add,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
