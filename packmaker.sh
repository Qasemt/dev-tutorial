
folder='vtl'
src=root@192.168.1.56:/usr/local/softwares/$folder
dest=/home/qasem/workingtemp
rsync -rpz -l $src $dest/

echo "$folder - $dest/$folder/"
cd $dest

tar -cvzf "$folder.tar.gz" "./$folder"

mkdir -p $"$dest/tt/"
tar -xvzf "$folder.tar.gz" -C $"$dest/tt/"
