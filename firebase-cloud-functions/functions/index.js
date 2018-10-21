// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase!, InstagramWithFirebase");
});

//Listen for following events.
exports.observeFollowingNode = functions.database.ref('/following/{uid}/{followingId}')
    .onCreate((snapshot, context) => {

      var uid = context.params.uid;
      var followingId = context.params.followingId;

      return admin.database().ref('/users/' + followingId).once('value', snapshot => {

        var userWeAreFollowing = snapshot.val();

        return admin.database().ref('/users/' + uid).once('value', snapshot => {

          var userThatFollowed = snapshot.val();

          var message = {
            notification: {
              title: 'New Follower',
              body: userThatFollowed.username + ' is now following you.'
            },
            data: {
              followerId: uid,
              type: "Follow"
            },
            token: userWeAreFollowing.fcmToken
          };

          admin.messaging().send(message)
            .then((response) => {
              // Response is a message ID string.
              console.log('Successfully sent message:', response);
              return
            })
            .catch((error) => {
              console.log('Error sending message:', error);
              return
            });
        })
      })
    });

exports.sendNotifications = functions.https.onRequest((req, res) => {
  res.send("Attempting to send push notification");
  console.log("LOGGER ___--- Attempting notification");

  var uId = '0TCPJWX0X8YH9klyobQ3K1iDBdj1';

  return admin.database().ref('/users/' + uId).once('value', snapshot => {

    var user = snapshot.val();

    console.log("USER: " + user.username + " fcmToken: " + user.fcmToken);

    var message = {
      notification: {
        title: 'Notification TITLE',
        body: 'Notification BODY'
      },
      data: {
        score: '850',
        time: '2:45'
      },
      token: user.fcmToken
    };

    admin.messaging().send(message)
      .then((response) => {
        // Response is a message ID string.
        console.log('Successfully sent message:', response);
        return
      })
      .catch((error) => {
        console.log('Error sending message:', error);
        return
      });
  })

  // var fcmToken = 'dW0_j55k6fo:APA91bHQ4YGlGahhoB7IMd1vh9uGIRvqGxm8YgE6aVWKOV_eKnzP0cFkFdPP4lgM6dZ84vlFUJydbNYba42S9DpMd3kwVKxl_edA42M1hvijFbLmc_JyHMBoBFGA777XkGjUgFfC5OJw';

  // See documentation on defining a message payload.

  //
  // // Send a message to the device corresponding to the provided
  // // fcmToken.

});
