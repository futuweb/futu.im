#!bin/bash

#History:
#  2017-07-28 jin first release

unzip -uoq -P $FUTU_IM_ZIP_KEY ./id_rsa.zip -d $HOME/.ssh/

chmod 600 $HOME/.ssh/id_rsa

cd ./public
zip -r ../futu.zip .
cd ..

scp -o "StrictHostKeyChecking no" ./futu.zip futu@futu.im:/data/web/futu.im/pub

ssh -o "StrictHostKeyChecking no" futu@futu.im "cd /data/web/futu.im/pub && sh pub.sh"