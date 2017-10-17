#!/bin/bash
#--------------------------------------------------------------------------------------------
#       Program name: GS_Config_Txt_to_XML_v1.8.sh
#       Version: 1.8    Author: Shawn Deng
#       Date: 2015/11/16
#
#       1. This program is used to transfer config-template files from TXT format into XML format.
#       2. Before execute this program, please put the TXT and CSV file at the same path,
#          then execute the .sh with three passed parameter S1 $2 $3:
#          S1 is the location of the TXT file with a '/'at the end, as '/home/user/work/'
#          $2 is the full name of the TXT file, as 'xxxx.txt'
#          $3 is the full name of the CSV fle, as 'XXXX.csv'
#       3. It will generate different XML files named by every MAC address named as cfgMAC.xml use
#          the same TXT config-template, and he XML files will be outputed at the same location
#          of the TXT file and named as cfgMAC.xml
#
#       Copyright: Grandstream Network Inc
#--------------------------------------------------------------------------------------------

# check if the user has input $1 $2 $3 If not, quit and give a hint.
if [ ! -n "$1" ] || [ ! -n "$2" ] || [ ! -n "$3" ] ; then
    echo "    you have not input the \$1 or \$2 or \$3"
    echo "        Please input \$1 as the path of the txt, end with '/'"
    echo "        Please input \$2 as the name of the txt, end with '.txt'"
    echo "        Please input \$3 as the name of the csv, end with '.csv'"
    exit 1
else

# after command is input correctly, create a tmp file.
touch $1tmp1.xml

# add the XML declaration
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" >> $1tmp1.xml
echo "<!-- BroadSoft XML Provisioning Configuration -->" >> $1tmp1.xml
echo "<gs_provision version=\"1\">" >> $1tmp1.xml
echo "<mac></mac>" >> $1tmp1.xml
echo "  <config version=\"1\">" >> $1tmp1.xml

# read the content of txt into the tmp file
cat $1$2 >> $1tmp1.xml

# delete the Unicode BOM as the <feff> at the txt, if there is any.
sed 's/^\xEF\xBB\xBF//'  $1tmp1.xml >> $1tmp2.xml

# comment all the line start with # and -, delete all the ^M sigh caused by the txt editor.
sed -e 's/^#\(.*$\)/<!--&-->/' -e 's/^-\(.*$\)/<!--&-->/' -e "s///g" $1tmp2.xml >> $1tmp3.xml

# convert xml skip characters into character entity references, then add <> </> to every configuration line.
sed -e '/^P/s:&:&amp;:g' -e '/^P/s:<:\&lt;:g' -e '/^P/s:>:\&gt;:g' -e '/^P/s:'\'':\&apos;:g' -e '/^P/s:'\"':\&quot;:g' -e '/^P/s: ::g' -e '/^P/s:=: :' -e '/^P/s:\(.*\) \(.*\):<\1>\2</\1>:g' $1tmp3.xml >> $1tmp4.xml

# add the end of XML declaration
echo "  </config>" >> $1tmp4.xml
echo "</gs_provision>" >>$1tmp4.xml

# prepare the CSV file, delete all the blankspace and delete the line with blank MAC value
sed -e 's: ::g' -e '/^,/d' -e '/^$/d' $1$3 > $1tmp5.csv

# read the CSV file and generate all the XML files by the information in the CSV file.

# reetp - Added username
while IFS=, read mac user password authid username; do

# check if the MAC address matches the prefix of GS devices
if [[ $mac == *"000B82"* ]] || [[ $mac == *"000b82"* ]]; then

# check the P value of Sip User ID in the txt file, and change the value in different conditions.

# reetp - Add mods for bluetooth ID and Hostname and Username

    if grep -q "<P35>" $1tmp4.xml ; then
    sed -e "/^<mac>/s:.*:<mac>$mac</mac>:g" -e "/^<P35>/s:.*:<P35>$user</P35>:g" -e "/^<P34>/s:.*:<P34>$password</P34>:g" -e "/^<P36>/s:.*:<P36>$authid</P36>:g" -e "/^<P146>/s:.*:<P146>sip-$user</P146>:g" -e "/^<P3>/s:.*:<P3>$username</P3>:g" -e "/^<P8364>/s:.*:<P8364>gxp2170_$mac-0</P8364>:g" -e "/^<P/s:<P:    <P:" -e "s///g" < $1tmp4.xml > "$1cfg$mac.xml"

    elif grep -q "<P4060>" $1tmp4.xml ; then

    sed -e "/^<mac>/s:.*:<mac>$mac</mac>:g" -e "/^<P4060>/s:.*:<P4060>$user</P4060>:g" -e "/^<P4120>/s:.*:<P4120>$password</P4120>:g" -e "/^<P4090>/s:.*:<P4090>$authid</P4090>:g" -e "/^<P/s:<P:    <P:" -e "s///g" < $1tmp4.xml > "$1cfg$mac.xml"

    elif grep -q "<P3060>" $1tmp4.xml ; then

    sed -e "/^<mac>/s:.*:<mac>$mac</mac>:g" -e "/^<P3060>/s:.*:<P3060>$user</P3060>:g" -e "/^<P3120>/s:.*:<P3120>$password</P3120>:g" -e "/^<P3090>/s:.*:<P3090>$authid</P3090>:g" -e "/^<P/s:<P:    <P:" -e "s///g" < $1tmp4.xml > "$1cfg$mac.xml"

    else
    sed -e "/^<mac>/s:.*:<mac>$mac</mac>:g" -e "/^<P/s:<P:    <P:" -e "s///g" < $1tmp4.xml > "$1cfg$mac.xml"
    fi
else

echo "        Notice: The Mac \"$mac\" is invalid for not starting with \"000B82\", please check the CSV file"

fi
done <$1tmp5.csv

# delete all the tmp files
rm $1tmp1.xml $1tmp2.xml $1tmp3.xml $1tmp4.xml $1tmp5.csv

# end of if-statement
fi

# give a hint where the XML is output
echo "        Thank you for using this program!"
echo "        Your XML files will be generated at: $1"
