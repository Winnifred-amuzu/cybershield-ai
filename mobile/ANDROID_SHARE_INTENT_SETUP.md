# Android Share-to-Cyber-Shield Setup

The Flutter source supports incoming shared text and shared screenshots/images. After running `flutter create .`, update `android/app/src/main/AndroidManifest.xml` so the main activity can receive Android shares.

Inside the `<activity>` for `MainActivity`, add:

```xml
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
</intent-filter>

<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="image/*" />
</intent-filter>

<intent-filter>
    <action android:name="android.intent.action.SEND_MULTIPLE" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="image/*" />
</intent-filter>
```

Set the activity launch mode to `singleTask` so an already-running app can receive new share intents.

The app deliberately follows a review-before-analysis workflow:

- Shared text is inserted into the message field.
- Shared screenshots are OCR-processed and the extracted text is inserted into the message field.
- The user must press **Analyze** to send content to the detection API.

This prevents external content from being analysed silently.
