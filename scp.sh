#!bin/bash

#History:
#  2017-07-28 jin first release

echo $FUTU_IM_SING > $HOME/.ssh/known_hosts

zip -r ./futu.zip ./public

scp ./futu.zip root@futu.im:/data/web/futu.im/pub