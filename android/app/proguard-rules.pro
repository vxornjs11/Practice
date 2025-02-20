# Gson TypeToken 문제 해결
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }

# flutter_local_notifications 관련 문제 해결
-keep class com.dexterous.** { *; }

# Firebase 관련 문제 해결
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# JSON 직렬화 문제 해결
-keep class com.google.gson.** { *; }
-keep class com.fasterxml.jackson.** { *; }