require('coffee-script/register');
var AuthenticateTask = require('./src/authenticate-task');
module.exports = new AuthenticateTask().run;
