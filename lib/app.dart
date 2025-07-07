import 'package:elderly_community/bindings/general_bindings.dart';
import 'package:elderly_community/features/auth/models/user_model.dart';
import 'package:elderly_community/features/auth/screens/signup/address.dart';
import 'package:elderly_community/features/auth/screens/signup/event_organiser_signup.dart';
import 'package:elderly_community/features/auth/screens/signup/select_role.dart';
import 'package:elderly_community/features/auth/screens/signup/signup.dart';
import 'package:elderly_community/features/auth/screens/signup/upload_profile_picture.dart';
import 'package:elderly_community/features/binding/screens/elderly_accept_request.dart';
import 'package:elderly_community/features/binding/screens/binding_list.dart';
import 'package:elderly_community/features/binding/screens/caregiver_send_request.dart';
import 'package:elderly_community/features/broadcast/models/broadcast_model.dart';
import 'package:elderly_community/features/broadcast/screens/admin_broadcast_detail.dart';
import 'package:elderly_community/features/elderly_management/screen/elderly_management.dart';
import 'package:elderly_community/features/event_management/screens/approved_event_detail.dart';
import 'package:elderly_community/features/event_management/screens/event_approval.dart';
import 'package:elderly_community/features/event_management/screens/event_category_management.dart';
import 'package:elderly_community/features/event_management/screens/event_management.dart';
import 'package:elderly_community/features/events/models/event_model.dart';
import 'package:elderly_community/features/events/screens/participant_event_list.dart';
import 'package:elderly_community/features/events/screens/participant_favorite_screen.dart';
import 'package:elderly_community/features/events/screens/oganiser_event_detail.dart';
import 'package:elderly_community/features/events/screens/event_form.dart';
import 'package:elderly_community/features/events/screens/organiser_event_list.dart';
import 'package:elderly_community/features/feedbacks/screens/feedback_form.dart';
import 'package:elderly_community/features/feedbacks/screens/feedback_list.dart';
import 'package:elderly_community/features/home/screens/admin_home.dart';
import 'package:elderly_community/features/home/screens/caregiver_home.dart';
import 'package:elderly_community/features/home/screens/elderly_home.dart';
import 'package:elderly_community/features/medical_record/models/medical_report_model.dart';
import 'package:elderly_community/common/image_viewer.dart';
import 'package:elderly_community/features/medical_record/screens/medical_record_detail.dart';
import 'package:elderly_community/features/medical_record/screens/medical_record_form.dart';
import 'package:elderly_community/features/medical_record/screens/medical_record_list.dart';
import 'package:elderly_community/common/pdf_viewer.dart';
import 'package:elderly_community/features/navigation_bar/screens/admin_navigation_bar.dart';
import 'package:elderly_community/features/navigation_bar/screens/caregiver_navigation_bar.dart';
import 'package:elderly_community/features/navigation_bar/screens/elderly_navigation_bar.dart';
import 'package:elderly_community/features/navigation_bar/screens/organiser_navigation_bar.dart';
import 'package:elderly_community/features/new_contacts/screens/contact_list.dart';
import 'package:elderly_community/features/profile/screens/description_form.dart';
import 'package:elderly_community/features/profile/screens/name_form.dart';
import 'package:elderly_community/features/profile/screens/organiser_profile_detail.dart';
import 'package:elderly_community/features/profile/screens/phone_number_form.dart';
import 'package:elderly_community/features/profile/screens/profile.dart';
import 'package:elderly_community/features/profile/screens/website_form.dart';
import 'package:elderly_community/features/reminders/models/reminder_model.dart';
import 'package:elderly_community/features/reminders/screens/caregiver_reminder.dart';
import 'package:elderly_community/features/reminders/screens/reminder_form.dart';
import 'package:elderly_community/features/reminders/screens/reminder.dart';
import 'package:elderly_community/features/reminders/screens/reminder_details.dart';
import 'package:elderly_community/features/sos/screens/sos_screen.dart';
import 'package:elderly_community/features/user_management/screens/organiser_form.dart';
import 'package:elderly_community/features/user_management/screens/pending_user_list.dart';
import 'package:elderly_community/features/user_management/screens/user_form.dart';
import 'package:elderly_community/features/user_management/screens/user_list.dart';
import 'package:elderly_community/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import 'features/auth/screens/login/login.dart';
import 'features/auth/screens/onboarding/onboarding.dart';
import 'features/ai_chat/screens/ai_chat.dart';
import 'features/broadcast/screens/admin_broadcast_list.dart';
import 'features/events/screens/elderly_activity_log.dart';
import 'features/events/screens/organiser_participant_list.dart';
import 'features/events/screens/participant_event_detail.dart';
import 'features/home/screens/organiser_home.dart';
import 'features/new_contacts/screens/contact_details.dart';
import 'features/new_contacts/screens/contact_form.dart';
import 'features/broadcast/screens/admin_broadcast_form.dart';
import 'features/notification/screens/notification_list.dart';
import 'features/profile/screens/address_form.dart';
import 'features/profile/screens/profile_detail.dart';
import 'features/profile/screens/profile_picture_form.dart';
import 'features/user_management/screens/organiser_account_approval.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ECAppTheme.lightTheme,
      initialBinding: GeneralBindings(),
      home: Container(),
      navigatorKey: navigatorKey,
      // initialRoute: '/',
      getPages: [
        // GetPage(
        //     name: '/', // This will handle redirection after splash screen
        //     page: () => const Scaffold(
        //       backgroundColor: Colors.transparent, // Prevents black screen
        //       body: SizedBox.shrink(), // Prevents UI from flashing
        //     ),),
        GetPage(name: '/on_boarding', page: () => OnBoardingScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/select_role', page: () => SelectRoleScreen()),
        GetPage(name: '/sign_up', page: () => SignUpScreen()),
        GetPage(
            name: '/organiser_sign_up',
            page: () => EventOrganizerSignUpScreen()),
        GetPage(
            name: '/upload_address',
            page: () => AddressScreen(
                  canSkip: Get.arguments as bool?,
                )),
        GetPage(
            name: '/upload_profile_picture',
            page: () => UploadProfilePictureScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
        GetPage(
            name: '/profile_detail',
            page: () => ProfileDetailScreen(
                  elderlyId: Get.arguments as String?,
                )),
        GetPage(
            name: '/address_form',
            page: () => AddressFormScreen(
                  ownProfile: Get.arguments as bool?,
                )),
        GetPage(
            name: '/phoneNumber_form',
            page: () => PhoneNumberFormScreen(
                  ownProfile: Get.arguments as bool?,
                )),
        GetPage(
            name: '/name_form',
            page: () => NameFormScreen(
                  ownProfile: Get.arguments as bool?,
                )),
        GetPage(
            name: '/profile_picture_form',
            page: () => ProfilePictureFormScreen(
                  ownProfile: Get.arguments as bool?,
                )),
        GetPage(
            name: '/notification_list', page: () => NotificationListScreen()),

        /// Elderly
        GetPage(name: '/elderly_home', page: () => ElderlyHomeScreen()),
        GetPage(
            name: '/elderly_navigation', page: () => ElderlyNavigationBar()),
        GetPage(name: '/contact', page: () => ContactListScreen()),
        GetPage(
            name: '/contact_form',
            page: () => ContactFormScreen(
                  contact: Get.arguments as Contact?,
                )),
        GetPage(
            name: '/contact_details',
            page: () => ContactDetailsScreen(
                  contact: Get.arguments as Contact,
                )),
        // GetPage(name: '/add_new_contact', page: () => AddNewContactScreen()),
        GetPage(name: '/event_list', page: () => ParticipantEventListScreen()),
        GetPage(
            name: '/participant_event_favourite_list',
            page: () => ParticipantFavoriteScreen()),
        GetPage(
            name: '/participant_event_details',
            page: () => ParticipantEventDetailScreen(
                  eventId: Get.arguments as String,
                )),
        GetPage(name: '/ai_chat', page: () => AIChatScreen()),
        GetPage(name: '/reminder', page: () => ReminderScreen()),
        GetPage(
            name: '/reminder_form',
            page: () => ReminderFormScreen(
                  reminder: Get.arguments as ReminderModel?,
                )),
        GetPage(
            name: '/reminder_details',
            page: () => ReminderDetailsScreen(
                  reminder: Get.arguments as ReminderModel,
                )),
        GetPage(name: '/sos_screen', page: () => SOSScreen()),
        GetPage(
            name: '/elderly_accept_request',
            page: () => AcceptBindingRequestModal(
                  id: Get.arguments['id'] as String,
                  caregiverId: Get.arguments['caregiverId'] as String,
                  caregiverName: Get.arguments['caregiverName'] as String,
                )),
        GetPage(
            name: '/medical_record_list',
            page: () => MedicalRecordListScreen()),
        GetPage(
            name: '/medical_record_form',
            page: () => MedicalRecordFormScreen()),
        GetPage(
            name: '/medical_record_detail',
            page: () => MedicalRecordDetailScreen(
                  record: Get.arguments as MedicalReportModel,
                )),
        GetPage(
            name: '/pdf_viewer',
            page: () => PdfViewerScreen(
                  fileUrl: Get.arguments['fileUrl'] as String,
                  title: Get.arguments['title'] as String,
                )),
        GetPage(
            name: '/image_viewer',
            page: () => ImageViewerScreen(
                  fileUrl: Get.arguments['fileUrl'] as String,
                  title: Get.arguments['title'] as String,
                )),
        GetPage(
            name: '/feedback_form',
            page: () => FeedbackFormScreen(
                  event: Get.arguments as EventModel,
                )),

        /// Caregiver
        GetPage(name: '/caregiver_home', page: () => CaregiverHomeScreen()),
        GetPage(
            name: '/caregiver_navigation',
            page: () => CaregiverNavigationBar()),
        GetPage(
            name: '/caregiver_send_request',
            page: () => SendBindingRequestModal()),
        GetPage(name: '/binding', page: () => BindingListScreen()),
        GetPage(
            name: '/elderly_management',
            page: () => ElderlyManagementScreen(
                  bindingIndex: Get.arguments as int,
                )),
        GetPage(
            name: '/caregiver_reminder_list',
            page: () => CaregiverReminderListScreen(
                  bindingIndex: Get.arguments as int,
                )),
        GetPage(
            name: '/elderly_activity_log',
            page: () => ElderlyActivityLogScreen(
                  bindingIndex: Get.arguments as int,
                )),

        /// Admin
        GetPage(name: '/admin_home', page: () => AdminHomeScreen()),
        GetPage(name: '/admin_navigation', page: () => AdminNavigationBar()),
        GetPage(name: '/admin_user_management', page: () => UserListScreen()),
        GetPage(
            name: '/user_form',
            page: () => UserFormScreen(
                  user: Get.arguments['user'] as UserModel?,
                  role: Get.arguments['role'] as String?,
                )),
        GetPage(
            name: '/organiser_form',
            page: () => OrganiserFormScreen(
                  user: Get.arguments as UserModel?,
                )),
        GetPage(
            name: '/organiser_approval',
            page: () => OrganisationAccountApprovalScreen(
                  organiser: Get.arguments as UserModel,
                )),
        GetPage(
            name: '/admin_event_management',
            page: () => EventManagementScreen()),
        GetPage(
            name: '/admin_event_category_management',
            page: () => EventCategoryManagementScreen()),
        GetPage(
            name: '/admin_event_approval',
            page: () => EventApprovalScreen(
                  event: Get.arguments as EventModel,
                )),
        GetPage(
            name: '/admin_approved_event_detail',
            page: () => ApprovedEventDetailScreen(
                  event: Get.arguments as EventModel,
                )),
        GetPage(
            name: '/admin_broadcast_list',
            page: () => AdminBroadcastListScreen()),
        GetPage(
            name: '/admin_broadcast_form',
            page: () => AdminBroadcastFormScreen()),
        GetPage(
            name: '/admin_broadcast_detail',
            page: () => AdminBroadcastDetailScreen(
                  notice: Get.arguments as BroadcastModel,
                )),
        GetPage(
            name: '/admin_pending_user_list',
            page: () => PendingUserListScreen()),

        /// Event Organiser
        GetPage(
            name: '/organiser_profile_detail',
            page: () => OrganiserProfileDetailScreen()),
        GetPage(name: '/website_form', page: () => WebsiteFormScreen()),
        GetPage(name: '/description_form', page: () => DescriptionFormScreen()),
        GetPage(name: '/organiser_home', page: () => OrganiserHomeScreen()),
        GetPage(
            name: '/organiser_navigation',
            page: () => OrganiserNavigationBar()),
        GetPage(
            name: '/event_management', page: () => OrganiserEventListScreen()),
        GetPage(name: '/event_form', page: () => EventFormScreen()),
        GetPage(
            name: '/organiser_event_details',
            page: () => OrganiserEventDetailScreen(
                  event: Get.arguments as EventModel,
                )),
        GetPage(
            name: '/organiser_event_participants_list',
            page: () => OrganiserEventParticipantsListScreen(
                  event: Get.arguments as EventModel,
                )),
        GetPage(
            name: '/organiser_feedback_list',
            page: () => FeedbackListScreen(
                  eventId: Get.arguments as String,
                )),
      ],
    );
  }
}
