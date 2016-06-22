#!/usr/bin/env node
var storj = require('storj');
var fs = require('fs');
var key = storj.KeyPair().getPrivateKey();
var password = process.env.PASSWORD;
var encryptedKey = storj.utils.simpleEncrypt(password, key);

fs.writeFileSync('/opt/storj/.storjshare/id_ecdsa', encryptedKey);
