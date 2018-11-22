/**
* categories menu
*/
hexo.extend.helper.register('cate_menu', function(cate){
    var menu = this.site.categories;
    var result = '<a href="/" class="'+ (cate === 'all' ? 'active' : '') +'">全部文章</a>';
    var self = this;

    menu.forEach(function(obj) {
        result += '<a href="' + self.url_for(obj.path) + '" class="'+ (cate === obj.name ? 'active' : '') +'">' + obj.name + '</a>';
    });

    return result;
});

/**
* categories menu
*/
hexo.extend.helper.register('show_cate', function(){
    var menu = this.page.categories;
    var result = '';
    var self = this;

    menu.forEach(function(obj) {
        result += '<a href="' + self.url_for(obj.path) + '">' + obj.name + '</a>';
    });

    return result;
});