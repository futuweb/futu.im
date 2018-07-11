


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
.homepageWrap .aboutWeb{
	width:900px;
	margin:0 auto;
}
.homepageWrap .aboutWeb h1{
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
.homepageWrap .aboutWeb h3{
	font-size:22px;
}
</style>
<div class="homepageWrap">
	<div class="banner">

	</div>
	<div class="aboutWeb">
		<h1>关于富途WEB团队</h1>
		<ul>
			<li>
				<h3>Who we are？</h3>
				<p>富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala.</p>
			</li>
			<li>
				<h3>What we do？</h3>
				<p>富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala.</p>
			</li>
			<li>
				<h3>Where is our future？</h3>
				<p>富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala.</p>
			</li>
		</ul>
	</div>
	<div class="aboutWeb">
		<h1>大家眼中的我们</h1>
		<ul>
			<li>
				<h3>Who we are？</h3>
				<p>富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala.</p>
			</li>
			<li>
				<h3>What we do？</h3>
				<p>富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala.</p>
			</li>
			<li>
				<h3>Where is our future？</h3>
				<p>富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala，整点字占位富途WEB研发团队是balabala.</p>
			</li>
		</ul>
	</div>
</div>

{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
