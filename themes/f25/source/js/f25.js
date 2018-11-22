/**
 * [删除ClassName]
 * @param {*} element 
 * @param {*} className 
 */
function removeClassName(element , className){
    if ( !hasClassName(element , className) ){
        return element;
    }
    element.className = ' ' + element.className.trim() + ' ';
    element.className =  element.className.replace(' ' + className + ' ' , ' ').trim();
    return element;
}
/**
 * [添加className]
 * @param {*} element 
 * @param {*} className 
 */
function addClassName(element , className){
    if ( hasClassName(element , className) ){
        return element;
    }
    element.className = element.className.trim() + ' ' + className.trim();
    return element;
}

/**
 * [判断是否包含对应的className]
 * @param {*} element 
 * @param {*} className 
 */
function hasClassName(element , className){
    if ( (' ' + element.className.trim() + ' ').indexOf(' ' + className.trim() + ' ') >= 0 ){
        return true;
    }
    return false;
}



var closeClassName = 'btn-close';
var showClassName = 'show';
var headerMenu = document.querySelector('#J_header_menu');
var headerMenulist = document.querySelector('#J_header_menu_list');

if ( headerMenu && headerMenulist ){
    //h5菜单栏展示
    headerMenu.addEventListener('click' , (event)=>{
        event.preventDefault();
        event.stopPropagation();

        if ( hasClassName(headerMenu , closeClassName) ){
            removeClassName(headerMenulist , showClassName);
            removeClassName(headerMenu , closeClassName);
        }else{
            addClassName(headerMenulist , showClassName);
            addClassName(headerMenu , closeClassName);
        }
    });
}