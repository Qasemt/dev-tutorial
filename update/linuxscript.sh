#/bin/bash


flashpath="$1"


#_______________ Define function _______________
logg()
{
MSG=$1
echo $MSG >> "$BASE_ADD/usb.txt"
}
#---------------------------------------------------
clear_and_GetfolderName()
{
address="$1"
address=${address::-1} #Delete the last character
folder=${address##*/}
folder=${folder/"#"/""}
folder=${folder/"\$"/""}

echo $folder

}
#---------------------------------------------------
remove_temp_folder() {

        logg "Remove all Files"
        cd "${BASE_DIR_PATH}"
        sudo rm -r *
        }
#---------------------------------------------------
check_flags()
{
local  pstring=$1
local   Result=''
if [[ $pstring == *"\$"* ]]
then Result="\$"
elif [[ $pstring == *"#"* ]]
then Result="#"
else Result=""

fi
echo $Result;
}
#---------------------------------------------------
database_process()
{
foler_script="$1"
  res=$(check_flags $foler_script)
	
if [ "$res" == "\$" ]
        then
            return
	fi

path_script_alter="$foler_script/1.altertable.sh"
path_script_bulk_insert="$foler_script/2.bulkinsert.sh"

  if [ -f  $path_script_alter ] ;
        then
	logg "Run Script > Alter Db > $path_script_alter"
	 bash $path_script_alter
	fi

  if [ -f  $path_script_bulk_insert ] ;
        then
        logg "Run Script > bulk insert > $path_script_bulk_insert"	
        bash $path_script_bulk_insert
	fi

}
#---------------------------------------------------
copy_to_dev()
         {
         logg "-------------------<< Cp >>--------------------"
         local a1=$1
         local a2=$2
         # name folder ra fetch mikonad
         folder=$(clear_and_GetfolderName $a2)


	logg ">>>> [$a1] (To) a2 [$a2]"
        return 0 
        if [ -d $a1 ] ;
        then

	res=$(check_flags $a1)

	if [ "$res" == "" ]
        	then
	        logg "full cp >>>>> Remove files >>> $a2"
        	rm -r $a2
	        mkdir -p $a2
	        cp -r $a1/* $a2

			elif [ "$res" == "\$" ]
				then
				logg "no cp "
				elif [ "$res" == "#" ] 
					then
					logg "cp rep"
					mkdir -p $a2
					#a1=${a1/"#"/""}
					cp -r $a1/* $a2
				fi
					else
						logg "Source Not found (a1) [ $a1 ]"
				fi 

} # end copy_to_dev

#_______________ Define Fileds ______________________________________________________


Pack_Name="pack.tar.gz"
MAIN_FOLDER="packupdatecarpc" # folder dakhele pack.zip 

##
## Working directory of the Script
##
#BASE_ADD="/home/qasem"
BASE_ADD="/root"
BASE_DIR="workingtemp" # folder name tmp roy board
BASE_DIR_PATH="$BASE_ADD/$BASE_DIR" # path folder temp roye board 

#Des_PATH="$BASE_ADD/$BASE_DIR/FORTEST" # masire forlder base roy board 
Des_PATH="/usr/local/softwares" # masire forlder base roy board 

DIR_DATA="data"
DIR_VTL="vtl"
DIR_VOICE="voices"
DIR_GISDATA="gisdata"
DIR_SCRIPT="script"
#________________ MAin Block ____________________
logg " >>>> INIT Script <<<<"

mkdir -p $BASE_DIR_PATH

logg "> Path Flash  $flashpath"


logg "Find pack ...."
pathpack="$flashpath/$MAIN_FOLDER/$Pack_Name" 
if [ -f $pathpack ];
then 
logg "File $pathpack exists"
else
logg "file $pathpack does not exists"
exit
fi

remove_temp_folder

logg "copy to Device ...."

cp $pathpack $BASE_DIR_PATH

#__________________ extract unit __________________________

logg "Extract File $Pack_Name"
d_Path_Pack_zip="$BASE_DIR_PATH/$Pack_Name"

if [ -f $d_Path_Pack_zip ];
then 
logg "Do Extract file $d_Path_Pack_zip"

extrpath="$BASE_DIR_PATH/"
#echo $extrpath

sudo tar -xvzf $d_Path_Pack_zip -C $extrpath
sudo chmod -R 777 .

else
logg "extractunit :file $d_Path_Pack_zip does not exists"
exit
fi

#__________________ Ready For Copy _________________________


for i in $(find $BASE_ADD/$BASE_DIR/$MAIN_FOLDER/ -type d -maxdepth 1)
do
#continue
result=${i##*/} 
#echo "$result"
tmpfoldername=${result/"#"/""}
tmpfoldername=${tmpfoldername/"\$"/""}

if [[ ("$tmpfoldername" == "${DIR_DATA}")  ]] 
then
copy_to_dev  "${BASE_DIR_PATH}/${MAIN_FOLDER}/$result/"  "$Des_PATH/${DIR_DATA}/"
elif [[ ("$tmpfoldername" == "${DIR_VTL}")  ]]
then
copy_to_dev  "${BASE_DIR_PATH}/${MAIN_FOLDER}/$result/"  "$Des_PATH/${DIR_VTL}/"
elif [[ ("$tmpfoldername" == "${DIR_VTL}")  ]]
then
copy_to_dev  "${BASE_DIR_PATH}/${MAIN_FOLDER}/$result/"  "$Des_PATH/${DIR_VTL}/"
elif [[ ("$tmpfoldername" == "${DIR_VOICE}")  ]]
then 
copy_to_dev  "${BASE_DIR_PATH}/${MAIN_FOLDER}/$result/"  "$Des_PATH/${DIR_VOICE}/"
elif [[ ("$tmpfoldername" == "${DIR_GISDATA}")  ]]
then 
copy_to_dev  "${BASE_DIR_PATH}/${MAIN_FOLDER}/$result/"  "$Des_PATH/${DIR_GISDATA}/"
elif [[ ("$tmpfoldername" == "${DIR_SCRIPT}")  ]]
then 
database_process  "${BASE_DIR_PATH}/${MAIN_FOLDER}/$result" 
fi

done






logg "_________________ Finished __________________________"


exit



