'use strict';

const crypto = require('crypto');
const fs = require('fs');

let basePath = process.argv[2];
let rsecret = process.argv[3];
let key = fs.readFileSync('./id_rsa.key' , 'utf-8');

let decipher = crypto.createDecipher('aes-256-cbc',rsecret);
let dec = decipher.update(key,'hex','utf8');
dec += decipher.final('utf8');

fs.writeFileSync(`${basePath}/.ssh/id_rsa` , dec);
