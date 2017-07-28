#!bin/bash

#History:
#  2017-07-28 jin first release

echo $FUTU_IM_KEY > $HOME/.ssh/id_rsa
echo $FUTU_IM_PUB > $HOME/.ssh/id_rsa.pub

zip -r ./futu.zip ./public

scp ./futu.zip root@futu.im:/data/web/futu.im/pub