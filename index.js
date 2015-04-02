// require coffee if possible; js otherwise
try {
  require('coffee-script/register');  
  AsyncPool = require('./src/async-pool');
}
catch (e) {
  if(e.message.indexOf("Cannot find module") != -1 
      && (e.message.indexOf('./src/index') != -1 
        || e.message.indexOf('coffee-script/register') != -1))
    AsyncPool = require('./lib/async-pool');
  else
    throw e;
}
module.exports = AsyncPool;