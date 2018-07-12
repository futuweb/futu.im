


{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template %}

{% block title %}
  {% set page_title_suffix = ' | ' + config.title %}

  {% if page.type === "categories" %}
    {{ __('title.category') + page_title_suffix }}
  {% elif page.type === "tags" %}
    {{ __('title.tag') + page_title_suffix }}
  {% else %}
    {{ page.title + page_title_suffix }}
  {% endif %}
{% endblock %}

{% block content %}
<style>
@media (min-width: 1600px){
	.container .main-inner {
		width: 100%;
	}
}
body,html{
	background:#f4f3de
}
.main-inner {
    margin-top: 0px;
}
.homepageWrap{
  	width:100%;
  	min-height:1000px;
	font-size:18px;
}
.homepageWrap .banner{
	background-image:url(https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg);
	background-repeat: no-repeat;
    background-position: center;
    background-size: cover;
	width:100%;
	min-height:500px;
}
.homepageWrap .aboutWeb,
.homepageWrap .otherComment,
.homepageWrap .environment,
.homepageWrap .joinUs,
.homepageWrap .friendLink
{
	width:900px;
	margin:0 auto;
}
.homepageWrap .aboutWeb h1,
.homepageWrap .otherComment h1,
.homepageWrap .environment h1,
.homepageWrap .joinUs h1
{
	font-size:24px;
	padding: 50px 0 30px;
    border-bottom: 2px solid #ccc;
    width: 300px;
    margin: 0 auto 50px;
    text-align: center;
}
.homepageWrap .aboutWeb li{
	margin-bottom:50px;
}
.homepageWrap .aboutWeb h3,
.homepageWrap .friendLink h3{
	font-size:22px;
}

.homepageWrap .otherComment .flexBox,
.homepageWrap .environment .envPic{
	display:flex;
}
.homepageWrap .environment .envPic{
	display:flex;
	margin-bottom:0;
	margin-top:0;
}
.homepageWrap .otherComment .flexBox li{
	background:#f2b59b;
	height:100%;
	margin:10px;
	padding:15px;
}
.homepageWrap .joinUs .joinbox li{
	text-align:center;
	line-height:40px;
	width:100%;
	background:#f3e59a;
	padding:15px;
}
.homepageWrap .friendLink
{
	margin-top:50px;
	margin-bottom:20px;
}
.homepageWrap .friendLink ul{
	padding:20px 0;
}
.homepageWrap .friendLink h1{
	margin-left:40px;
	height:50px;
	width:110px;
	border-bottom: 2px solid #008972;
}
.homepageWrap .friendLink li{
	display:flex;
	color:#0092c7;
}
.homepageWrap .friendLink li a{
	margin-right:55px;
	border-bottom:none;
	padding-left:40px;
}
.homepageWrap .friendLink li a:hover{
	color:#008972;
}
</style>
<div class="homepageWrap">
	<div class="banner">

	</div>
	<div class="aboutWeb">
		<h1>关于富途WEB团队</h1>
		<ul>
			<li>
				<h3>✨Who we are？</h3>
				<p>富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala.</p>
			</li>
			<li>
				<h3>✨What we do？</h3>
				<p>富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala.</p>
			</li>
			<li>
				<h3>✨Where is our future？</h3>
				<p>富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala.</p>
			</li>
		</ul>
	</div>
	<div class="otherComment">
		<h1>大家眼中的我们</h1>
		<ul class="flexBox">
			<li>
				某产品经理说：<br/>
				富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala
			</li>
			<li>某产品经理说：<br/>
				富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabal</li>
			
		</ul>
		<ul class="flexBox">
			<li>
			某产品经理说：<br/>
				富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabal</li>
			<li>某产品经理说：<br/>
				富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala</li>
			<li>某产品经理说：<br/>
				富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala</li>
		</ul>
		<ul class="flexBox">
			<li>
			某产品经理说：<br/>
				富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabal</li>
			<li>某产品经理说：<br/>
				富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala</li>
		</ul>
	</div>
	<div class="environment">
		<h1>我们的工作环境</h1>
		<ul class="envPic">
			<li>
				<img src="https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg"/>
			</li>
		</ul>
		<ul class="envPic">
			<li>
				<img src="https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg"/>
			</li>
			<li>
				<img src="https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg"/>
			</li>
			<li>
				<img src="https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg"/>
			</li>
		</ul>
		<ul class="envPic">
			<li>
				<img src="https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg"/>
			</li>
			<li>
				<img src="https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg"/>
			</li>
		</ul>
		
	</div>
	<div class="environment">
		<h1>认识不一样的我们</h1>
		<ul class="envPic">
			<li>
				<img src="https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg"/>
			</li>
		</ul>
		<ul class="envPic">
			<li>
				<img src="https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg"/>
			</li>
			<li>
				<img src="https://pubimg.futunn.com/20171100006970e32da0ea05c.jpg"/>
			</li>
		</ul>
		
	</div>
	<div class="joinUs">
		<h1>加入我们</h1>
		<ul class="joinbox">
			<li>
				茫茫人海，我在等你~<br/>
				在这里，找到不一样的自己，<br/>
				在这里，实现你的技术大咖梦想，<br/>
				在这里，发现自己的不一样，<br/>
				在这里，我，在等你~<br/>
				欢迎加入我们  招聘链接XXX<br/>
				发送简历到：diandian@futunn.com
			</li>
		</ul>
	</div>
	<div class="friendLink">
		<h1>友情链接</h1>
		<ul>
			<li>
				<a href="javascripyt:;">我是链接</a>
				<a href="javascripyt:;">我是链接</a>
				<a href="javascripyt:;">我是链接</a>
				<a href="javascripyt:;">我是链接</a>
				<a href="javascripyt:;">我是链接</a>
			</li>
		</ul>
	</div>
</div>


{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
