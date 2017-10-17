# grandstream-provisioner
Mods to the GrandStream Provisioning script

I have added an extra column to the MAC.csv file for Accounts/Account 1/General Settings/Name and used it in the script

I have amended the script for the GPX2170

This adds:

Bluetooth ID name, Hostname and Username

It reads the username to make 'sip-user' and the mac number to create a bluetooth id gxp2170-aabbccddeeff

This ONLY works where it finds <P35> SIP User ID in the config.txt file

-e "/^<P35>/s:.*:<P35>$user</P35>:g"
-e "/^<P34>/s:.*:<P34>$password</P34>:g"
-e "/^<P36>/s:.*:<P36>$authid</P36>:g"
-e "/^<P146>/s:.*:<P146>sip-$user</P146>:g"
-e "/^<P3>/s:.*:<P3>$username</P3>:g"
-e "/^<P8364>/s:.*:<P8364>gxp2170_$mac-0</P8364>:g"
