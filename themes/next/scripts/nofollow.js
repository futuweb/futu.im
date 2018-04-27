hexo.extend.filter.register('after_render:html', (source) => {
    // console.log('after_render');
    return source.replace(/rel="noopener"/g, function(str){
        // console.log('replace rel nofollow');
        return 'rel="noopener external nofollow"';
    });
});
