import * as functions from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import moment from "moment";

admin.initializeApp();

export const checkAndSendReminderNotifications = functions.onSchedule(
  "*/5 * * * *",
  async () => {
    const db = admin.firestore();
    const now = moment().utc(); // Get current UTC time
    const oneHourAgo = moment().utc().subtract(1, "hour");

    console.log(`🔄 Checking reminders... ${oneHourAgo}`);

    const remindersSnapshot = await db.collection("Reminders").get();
    const batch = db.batch();
    const tasks: Promise<void>[] = [];

    for (const doc of remindersSnapshot.docs) {
      const reminder = doc.data();
      const reminderTime = moment(reminder.reminder_time.toDate()).utc(); // Convert Firestore timestamp
      const lastCompletedDate = reminder.last_completed_date
        ? moment(reminder.last_completed_date.toDate()).utc()
        : null;
      let shouldSendMissedNotification = false;

      // Fetch user device token from "users" collection
      const userSnapshot = await db
        .collection("Users")
        .doc(reminder.elderly_id)
        .get();
      const user = userSnapshot.data();
      if (!user || !user.deviceToken) {
        console.log(`❌ No device token for user ${reminder.elderly_id}`);
        continue;
      }

      // Send reminder notification
      if (reminder.is_recurring) {
        if (
          now.hour() === reminderTime.hour() &&
          now.minute() === reminderTime.minute()
        ) {
          console.log(`🔔 Sending recurring notification: ${reminder.title}`);
          tasks.push(
            sendFCMNotification(
              user.deviceToken,
              `🔔 ${reminder.title}`,
              reminder.description,
              {
                reminderId: doc.id,
                elderlyId: reminder.elderly_id,
                type: "elderlyReminder",
              }
            )
          );
        } else if (
          (!lastCompletedDate &&
            reminderTime.hour() === oneHourAgo.hour() &&
            reminderTime.minute() === oneHourAgo.minute()) ||
          (lastCompletedDate &&
            !lastCompletedDate.isSame(now, "day") &&
            reminderTime.hour() === oneHourAgo.hour() &&
            reminderTime.minute() === oneHourAgo.minute())
        ) {
          shouldSendMissedNotification = true;
        }
      } else {
        if (now.isSame(reminderTime, "minute")) {
          console.log(
            `📌 Checking reminder for ${
              reminder.title
            }: now=${now.format()} reminderTime=${reminderTime.format()}`
          );
          console.log(`🔔 Sending one-time notification: ${reminder.title}`);
          tasks.push(
            sendFCMNotification(
              user.deviceToken,
              `🔔 ${reminder.title}`,
              reminder.description,
              {
                reminderId: doc.id,
                elderlyId: reminder.elderly_id,
                type: "elderlyReminder",
              }
            )
          );
        } else if (
          (!lastCompletedDate && reminderTime.isSame(oneHourAgo, "minute")) ||
          (lastCompletedDate &&
            !lastCompletedDate.isSame(now, "day") &&
            reminderTime.isSame(oneHourAgo, "minute"))
        ) {
          shouldSendMissedNotification = true;
        }
      }

      if (shouldSendMissedNotification) {
        console.log(`📌 Sending missed notification for ${reminder.title}`);
        const bindingsSnapshot = await db
          .collection("Bindings")
          .where("elderly_id", "==", reminder.elderly_id)
          .where("status", "==", "approved")
          .get();

        for (const bindingDoc of bindingsSnapshot.docs) {
          const binding = bindingDoc.data();

          // Fetch caregiver's device token
          const caregiverSnapshot = await db
            .collection("Users")
            .doc(binding.caregiver_id)
            .get();
          const caregiver = caregiverSnapshot.data();

          if (caregiver && caregiver.deviceToken) {
            console.log(
              `🔔 Sending missed reminder to caregiver: ${caregiver.deviceToken}`
            );
            tasks.push(
              sendFCMNotification(
                caregiver.deviceToken,
                "Missed Reminder",
                `Your elderly (${user.name}) missed: ${reminder.title}`,
                {
                  reminderId: doc.id,
                  elderlyId: reminder.elderly_id,
                  type: "missedReminder",
                }
              )
            );

            // Save notification in Firestore
            const notificationRef = db.collection("Notifications").doc();
            batch.set(notificationRef, {
              userId: binding.caregiver_id,
              title: "Missed Reminder",
              body: `Your elderly (${user.name}) missed: ${reminder.title}`,
              createdAt: admin.firestore.Timestamp.now(),
              type: "missedReminder",
              read: false,
              data: { reminderId: doc.id, elderlyId: reminder.elderly_id },
            });
          }
        }
      }
    }

    await Promise.all(tasks);
    await batch.commit();
    console.log("✅ Reminder check completed");
  }
);

// Function to send FCM notification
async function sendFCMNotification(
  deviceToken: string,
  title: string,
  body: string,
  data: object
) {
  const payload = {
    notification: { title, body },
    token: deviceToken,
    data: { ...data },
  };

  try {
    await admin.messaging().send(payload);
    console.log(`✅ Notification sent: ${title}`);
  } catch (error) {
    console.error("❌ Error sending notification:", error);
  }
}
