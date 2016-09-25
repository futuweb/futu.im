(function(){
	if(location.hostname === 'www.futu.im' || location.hostname === 'futu.im'){
		if(location.protocol === 'http:'){
			location.replace(location.href.replace(/^http:/,'https:'));
		}
	}
})();
