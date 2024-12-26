# Get Burp Certificate (Burp needs to be launched and listening on port 8080)
curl -s -o cacert.der --proxy 127.0.0.1:8080 http://burp/cert

# Allow to write on /system
adb root >/dev/null 2>&1 && sleep 2 && adb remount >/dev/null 2>&1 

# Convert DER format to PEM
openssl x509 -inform DER -in cacert.der -out cacert.pem

# Get certificate name
CERTHASHNAME="`openssl x509 -inform PEM -subject_hash_old -in cacert.pem | head -1`.0"

# Rename certificate
mv cacert.pem $CERTHASHNAME

# Upload certificate
adb push $CERTHASHNAME /data/misc/user/0/cacerts-added/$CERTHASHNAME

# Assign needed permission
adb shell chmod 644 /data/misc/user/0/cacerts-added/$CERTHASHNAME

# Reboot the device
adb reboot