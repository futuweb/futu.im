'use strict';

const path = require('path');

module.exports = {
  bolgName:'富途Web开发团队',
  root: path.resolve(process.cwd() , 'source/_posts'), //bolg markdown file path
  url: 'https://futu.im/statistics/static',
  viewPath: path.resolve(process.cwd() , 'public/statistics'), //html path you want
  staticPath: path.resolve(process.cwd() , 'public/statistics/static') // js,css path you want
};