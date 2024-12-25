# Get Burp Certificate (Burp need to be launched and listing on port 8080)
curl -s -o cacert.der --proxy 127.0.0.1:8080 http://burp/cert

# Convert DER format to PEM
openssl x509 -inform DER -in cacert.der -out cacert.pem

# Get certificate name
CERTHASHNAME="`openssl x509 -inform PEM -subject_hash_old -in cacert.pem | head -1`.0"

# Rename certificate
mv cacert.pem $CERTHASHNAME

# Allow to write on /system
adb root >/dev/null 2>&1 && sleep 2 && adb remount >/dev/null 2>&1 

# Upload certificate
adb push $CERTHASHNAME /sdcard/ 

# Move certificate to correct location
adb shell mv /sdcard/$CERTHASHNAME /system/etc/security/cacerts/ 

# Assign needed permission
adb shell chmod 644 /system/etc/security/cacerts/$CERTHASHNAME

# Reboot the device
adb reboot