#!bin/bash

#History:
#  2017-07-28 jin first release
unzip -fq  -P $FUTU_IM_ZIP_KEY ./id_rsa.zip -d $HOME/.ssh/
echo $FUTU_IM_SING > $HOME/.ssh/known_hosts

ls -a $HOME/.ssh/

zip -r ./futu.zip ./public

scp ./futu.zip root@futu.im:/data/web/futu.im/pub