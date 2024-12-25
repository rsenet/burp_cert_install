# About Burp Cert Install

## inject certificate before API 34

Since Android 7.0 (API 24 - Nougat), intercepting SSL/TLS requests has become more difficult due to changes in certificate management.

Android Nougat now separates certificate stores into two categories:

- **User Certificate Store**: Contains certificates manually installed by the user (e.g., Burp certificates).
- **System Certificate Store**: Contains certificates provided by the manufacturer or the Android system.

By default, applications only trust certificates from the **System Certificate Store**. This means that user-installed certificates (like those from Burp) are not automatically recognized by applications.

## inject certificate after API 34

In the latest Android 14 release, a change has been made to how the system handles trusted Certificate Authority (CA) certificates.

Previously, these certificates were stored in `/system/etc/security/cacerts/`, a location accessible and modifiable by users with root privileges, allowing immediate system-wide application.

However, with Android 14, the storage location has been moved to `/apex/com.android.conscrypt/cacerts`, a directory within the `/apex` path, which is inherently immutable.