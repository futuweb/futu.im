#!bin/bash

#History:
#  2017-07-28 jin first release
#  
unzip -q -P $FUTU_IM_ZIP_KEY ./id_rsa.zip -d $HOME/.ssh/

chmod 600 $HOME/.ssh/id_rsa

cd ./public
zip -r ../futu.zip .
cd ..

scp ./futu.zip root@futu.im:/data/web/futu.im/pub