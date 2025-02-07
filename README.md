# About Burp Cert Install

Burp Cert Install is a collection of bash script allowing to automate deployment of the Burp certificate based on the Android API version.

To know your exact API version:

```
$ adb shell getprop ro.build.version.sdk
30
```

## Usage

### Inject certificate (API <= 23)

Before Android 7.0 (API ≤ 23, up to Marshmallow), certificate management was more lenient, making it easier to intercept SSL/TLS requests for debugging purposes with tools like Burp Suite.

In these versions, Android did not strictly separate user-installed certificates from system certificates:

- **Single Certificate Store**: Android relied on a unified certificate store that included both system certificates (pre-installed by the manufacturer or Android) and user-installed certificates.
- **Automatic Trust**: All certificates, whether system or user-added, were automatically trusted by applications unless a specific app explicitly defined a different policy.


### Inject certificate (API < 34)

Since Android 7.0 (API 24 - Nougat), intercepting SSL/TLS requests has become more difficult due to changes in certificate management.

Android Nougat now separates certificate stores into two categories:

- **User Certificate Store**: Contains certificates manually installed by the user (e.g., Burp certificates).
- **System Certificate Store**: Contains certificates provided by the manufacturer or the Android system.

By default, applications only trust certificates from the **System Certificate Store**. This means that user-installed certificates (like those from Burp) are not automatically recognized by applications.

### Inject certificate (>= 34)

In the latest Android 14 release, a change has been made to how the system handles trusted Certificate Authority (CA) certificates.

Previously, these certificates were stored in `/system/etc/security/cacerts/`, a location accessible and modifiable by users with root privileges, allowing immediate system-wide application.

However, with Android 14, the storage location has been moved to `/apex/com.android.conscrypt/cacerts`, a directory within the `/apex` path, which is inherently immutable.

## Author

Régis SENET ([rsenet](https://github.com/rsenet))


## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/rsenet/burp_cert_install).

## License

The project is available as open source under the terms of the [GPLv3](https://www.gnu.org/licenses/quick-guide-gplv3.en.html)
