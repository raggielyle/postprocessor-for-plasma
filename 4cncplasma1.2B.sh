#!/bin/bash
# SECTION 1 - GET VARIABLES 
#set defailt values
dcutheight="2.5" #cut height
dpierceheight="3" #pierce height
dpiercedelay="0.5" #pierce delay
dextension=".ngc" #file extension to ngc
dsafeheight="15" #3 safe height for rapid movements
dzset="-3.5"
dfeedrate="1350" #feed rate
dpac="10" #pause after cut
dpbc="2" #pause before cut
newfile="plasma"
# get name of file to be processed
echo Please enter the name of the ngc 'file' to be processed - dont include 'file' extension
read filename
oldfile=$filename
filename=$filename$dextension
# Check if string is empty    
if [[ -z "$filename" ]]; then
   printf '%s\n' "No file name entered"
   exit 1
fi
echo
#if there is a valid file then first make a backup and then show defaults
if [[ -f $filename ]];then 
    cp $filename backup.ngc   
    echo "$filename exists. Please proceed to enter details for:"
    echo
    echo 1. cutting height              - default is $dcutheight
    echo 2. pierce height               - default is $dpierceheight
    echo 3. pierce delay                - default is $dpiercedelay
    echo 4. feed rate                   - default is $dfeedrate
    echo 4. rapid movement safe height  - default is $dsafeheight
    echo 5. z axis offset after probe   - default is $dzset
    echo 6. pause BEFORE cutting        - default is $dpbc  seconds
    echo 7. pause AFTER cutting         - default is $dpac seconds
    
    echo
# exit program if wrong or no file esists
else
echo Wrong or 'file' name or 'file' does not exist -- exiting 
exit 1
fi
# establish if defaults are to be applied
read -p "Accept defaults (y/n) " RESP
if [ "$RESP" = "y" ]; then
echo you have accepted defaults
cutheight=$dcutheight
pierceheight=$dpierceheight
piercedelay=$dpiercedelay
feedrate=$dfeedrate
safeheight=$dsafeheight
zset=$dzset
pac=$dpac
pbc=$dpbc


#exit 1
else
        echo
#cutting height
        echo What is the cutting height? - default is $dcutheight mm
        read cutheight
        if [[ -z "$cutheight" ]];then
        cutheight=$dcutheight
        fi
        echo Ok cut height is $cutheight mm
echo
#pierce heightif [[ -z "$cutheight" ]]
        echo What is the pierce height? - default is $dpierceheight mm
        read pierceheight
        if [[ -z "$pierceheight" ]];then
        pierceheight=$dpierceheight
        fi
        echo Ok pierce height is $pierceheight mm
echo
#pierce delay
        echo What is the pierce delay? - default is $dpiercedelay seconds
        read piercedelay
        if [[ -z "$piercedelay" ]];then
        piercedelay=$dpiercedelay
        fi
        echo Ok the pierce delay is $piercedelay seconds
echo
#feed rate
       echo What is the feed 'rate'? - default is $dfeedrate mm/min
       read feedrate
       if [[ -z "$feedrate" ]];then
       feedrate=$dfeedrate
       fi
       echo Ok feed rate is $feedrate mm/min
# echo
#safe height for rapid movements
        echo What is the rapid movement safe height? - default is $dsafeheight mm
        read safeheight
        if [[ -z "$safeheight" ]];then
        safeheight=$dsafeheight
        fi
        echo Ok safe height is $safeheight mm
        echo
# offset for z axis after probe
        echo What is the offset 'for' z axis after probe? - default is $dzset mm
        read zset
        if [[ -z "$zset" ]];then
        zset=$dzset
        fi
        echo Ok z offsetis $zset mm
        echo
# pause before cutting
        echo What is the pause BEFORE cutting commences? - default is $dpbc seconds
        read pbc
        if [[ -z "$pbc" ]];then
        pbc=$dpbc
        fi
        echo Ok pause before cutting is $pbc seconds
        echo
# pause after cutting
        echo What is the pause AFTER cutting commences? - default is $dpac seconds
        read pac
        if [[ -z "$pac" ]];then
        pac=$dpac
        fi
        echo Ok pause after cutting is $pac seconds
        echo
fi
# SECTION 2 EFFECT CHANGES TO THE SELECTED NGC FILE

# put credits in for me!! and go to z 25
sed -i "8i(This file modified by 4cncplasma - By Bruce Lyle)\n\n\ \nG0Z25" $filename


#change the feed rate
sed  -i "s/^F.*/F$feedrate/g" $filename

# remove all lines containing the strings "G0 Z" and "G1 Z"
sed  -i '/G0 Z\|G1 Z/d' $filename

# remove all lines containing feed rates "F*"
# stet - this removes feed rates as per dfx2gcode so removed.
#sed  -i '/F/d' $filename  

# replace all lines containing "M9 M5" with "M9 M5 and \nG0 $safeheight\nG4 P$pac"
sed  -i "s/M9 M5/M9 M5 (torch off)\nG0 Z $safeheight (go to safe height)\nG4 P $pac (pause after cutting)/g" $filename

# replace all lines containing "M3 M8" with delay before cut and probing cycle
sed  -i "s/M3 M8/G40 (compensation off)\nG4 P $pbc (delay before cuting commences)\nG38.2 Z-100 F$feedrate (probe for surface)\nG92 Z $zset (set Z offset)\nG0 Z $pierceheight (go to pierce height) \nM3 S1 (torch on) \nG4 P $piercedelay (pierce delay) \nG0 Z $cutheight (go to cut height)/g" $filename

# put in safe heifght to go to X0 Y0
#step 1 remove last 2 lines
head -n -2 $filename > tmp.txt && mv tmp.txt $filename
#step 2 add last 3 lines
#sed -i '$i G0 Z 25\nG0 X  0 Y 0\nM2 (Program end)' $filename
echo "G0 Z 25 ( go to return height)" >> $filename
cat $filename
echo "G0 X 0 Y 0 (go back home)" >> $filename
cat $filename
echo "M2 (Program End)" >> $filename
cat $filename

#lastly rename the file to indicate that it's a plasma cutting file and restore the origninal file
mv $filename "$oldfile$newfile.ngc"
mv backup.ngc "$oldfile.ngc"

# Message to indicate process completed
echo Finished 
echo New 'file' -  "$oldfile$newfile$dextension" - created
echo - "$oldfile.ngc" - remains unchanged









