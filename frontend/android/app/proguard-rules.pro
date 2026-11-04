# O SDK de anúncios (AdMob) usa WorkManager/Room; o R8 removia as classes
# geradas (WorkDatabase_Impl) e o app fechava ao abrir em release.
-keep class androidx.work.** { *; }
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.startup.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class com.android.billingclient.** { *; }
-dontwarn com.google.android.gms.**
