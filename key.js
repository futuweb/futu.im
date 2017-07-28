'use strict';

const crypto = require('crypto');
const fs = require('fs');
const exec = require('child_process').exec;

let basePath = process.argv[2];
let rsecret = process.argv[3];
let pubkey = process.argv[4];

let key = fs.readFileSync('./id_rsa.key' , 'utf-8');
let pub = fs.readFileSync('./id_rsa_pub.pub' , 'utf-8');

console.log('get key and pub. basePath:' , basePath);

let decipher = crypto.createDecipher('aes-256-cbc',rsecret);
let dec = decipher.update(key,'hex','utf8');
dec += decipher.final('utf8');
fs.writeFileSync(`${basePath}/.ssh/id_rsa` , dec);

decipher = crypto.createDecipher('aes-256-cbc',pubkey);
dec = decipher.update(pub,'hex','utf8');
dec += decipher.final('utf8');
fs.writeFileSync(`${basePath}/.ssh/id_rsa.pub` , dec);

console.log('**********done************');

exec('bash ./scp.sh' , function(err, stdout, stderr) {
  console.log(err);
  console.log(stdout);
  console.log(stderr);
});