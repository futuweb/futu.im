#!bin/bash

#History:
#  2017-07-28 jin first release
unzip -q -P $FUTU_IM_ZIP_KEY ./id_rsa.zip -d $HOME/.ssh/
echo $FUTU_IM_SING > $HOME/.ssh/known_hosts

chmod 600 $HOME/.ssh/id_rsa

zip -r ./futu.zip ./public

scp ./futu.zip root@futu.im:/data/web/futu.im/pub