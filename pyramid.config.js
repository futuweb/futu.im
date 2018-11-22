'use strict';

const path = require('path');

module.exports = {
  blogName:'FutuWeb',
  root: path.resolve(process.cwd() , 'source/_posts'), //bolg markdown file path
  url: 'https://futu.im/statistics/static',
  viewPath: path.resolve(process.cwd() , 'public/statistics'), //html path you want
  staticPath: path.resolve(process.cwd() , 'public/statistics/static') // js,css path you want
};