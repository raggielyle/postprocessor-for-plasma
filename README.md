# postprocessor-for-plasma
For use with dfx2gcode
This is a bash script. Windows users will need to enable bash.

Explanation
This script edits files created with dfx2gcode to make them "plasma friendly". 
Sometimes after shapes have been cut they can cause disruption to the movement of the gantry. Therefore, you can set the length of time for pauses both before and after cuts.

Instructions
1. Create your dxf file
2. Create your ngc file with dfx2gcode
3. Copy the file  named 4cncplasma1.2B.sh to the folder where your ngc file is
4. Change the permissions of the file 4cncplasma1.2B.sh to executable
5. type the command ./4cncplasma1.2B.sh and press enter
7. Follow the prompts to select the file, set cut height, pierce height, pierce delay, safe height for rapids, z axis offset after probe, feed rate, and pauses both before and after each cut.
8. Your original ngc file will remain intact and the processed file will contain the word "plasma" at the end

Note - the script provides default values for the above. You can edit the script to suit your requirements.

