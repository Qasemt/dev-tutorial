
gisdatafolder=gisdata
voicesfolder=voices
vtlfolder=vtl
datafolder=data
pack_folder=pack.tar.gz
main_folder=packupdatecarpc
src_vtl_from_Device=root@192.168.1.56:/usr/local/softwares
src_from_host=/usr/local/softwares
dest=/home/qasem/workingtemp

#--------------Define func---------------
	logg()
	{
		msg=$1
		echo "$msg"
	}

	copy_folder()
	{
		s=$1
		d=$2
		logg ">>>> Copy $s to $d"
		rsync -av $s $d

	}
	copy_folder_from_device()
	{
		s=$1
		d=$2
		logg ">>>> Copy $s to $d"
		rsync -rpz -l $s $d

	}

	create_pack()
	{
        
         tar -cvzf "$pack_folder"  $"$main_folder/"
	}
#---------------end -------------------------
rm -r $dest

mkdir -p $dest

copy_folder "$src_from_host/$gisdatafolder" "$dest/$main_folder"
copy_folder "$src_from_host/$datafolder" "$dest/$main_folder"
copy_folder "$src_from_host/$voicesfolder" "$dest/$main_folder"
copy_folder  "$src_vtl_from_Device/$vtlfolder" "$dest/$main_folder"


cd $dest
create_pack 

