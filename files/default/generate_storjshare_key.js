#!/usr/bin/env node
var storj = require('storj-lib');
var fs = require('fs');

var key = storj.KeyPair().getPrivateKey();

var key_path = process.env.KEY_PATH;

fs.writeFileSync(key_path, key);

console.log('%s', key);
