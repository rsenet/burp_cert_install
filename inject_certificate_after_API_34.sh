# Link : https://httptoolkit.com/blog/android-14-install-system-ca-certificate/

# Get Burp Certificate (Burp need to be launched and listing on port 8080)
curl -s -o cacert.der --proxy 127.0.0.1:8080 http://burp/cert

# Convert DER format to PEM
openssl x509 -inform DER -in cacert.der -out cacert.pem

# Local path of the certificate you want to add
CERTIFICATE_PATH=cacert.pem

# Allow to write on /system
adb root >/dev/null 2>&1 && sleep 2 && adb remount >/dev/null 2>&1 

# Create a temporary directory for certificates on the device
adb shell "mkdir -p -m 700 /data/local/tmp/tmp-ca-copy"

# Copy the existing certificates to the temporary directory
adb shell "cp /apex/com.android.conscrypt/cacerts/* /data/local/tmp/tmp-ca-copy/"

# Mount a temporary file system on the system certificate folder
adb shell "mount -t tmpfs tmpfs /system/etc/security/cacerts"

# Copy the existing certificates into the tmpfs to retain their trust
adb shell "mv /data/local/tmp/tmp-ca-copy/* /system/etc/security/cacerts/"

# Push the new certificate to the device
adb push "$CERTIFICATE_PATH" /data/local/tmp/tmp-cert.pem
adb shell "mv /data/local/tmp/tmp-cert.pem /system/etc/security/cacerts/"

# Update permissions and SELinux labels
adb shell "chown root:root /system/etc/security/cacerts/*"
adb shell "chmod 644 /system/etc/security/cacerts/*"
adb shell "chcon u:object_r:system_file:s0 /system/etc/security/cacerts/*"

# Handle APEX replacements in namespaces

# Retrieve the PIDs of Zygote processes
ZYGOTE_PID=$(adb shell "pidof zygote" | tr -d '\r')
ZYGOTE64_PID=$(adb shell "pidof zygote64" | tr -d '\r')

# Inject the mount into Zygote namespaces
for Z_PID in "$ZYGOTE_PID" "$ZYGOTE64_PID"; do
    if [ -n "$Z_PID" ]; then
        adb shell "nsenter --mount=/proc/$Z_PID/ns/mnt -- mount --bind /system/etc/security/cacerts /apex/com.android.conscrypt/cacerts"
    fi
done

# Retrieve the PIDs of all already launched applications
APP_PIDS=$(adb shell "ps -o PID -P $ZYGOTE_PID $ZYGOTE64_PID | grep -v PID" | tr -d '\r')

# Inject the mount into the namespaces of each application process
for PID in $APP_PIDS; do
    adb shell "nsenter --mount=/proc/$PID/ns/mnt -- mount --bind /system/etc/security/cacerts /apex/com.android.conscrypt/cacerts" &
done
wait

echo "System certificate injected"
