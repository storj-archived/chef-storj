#!/usr/bin/env node
var storj = require('storj-lib');
var fs = require('fs');

var migration_key_path = process.env.MIGRATION_KEY_PATH;
var key_path = process.env.KEY_PATH;
var password = process.env.PASSWORD;

var privkey_encrypted = fs.readFileSync(migration_key_path).toString();
var privkey = null;

try {
  privkey = storj.utils.simpleDecrypt(password, privkey_encrypted)
} catch (err) {
  process.exit(1);
}

fs.writeFileSync(key_path, privkey);
