create temporary table first_test_pageviews
select 
website_pageviews.website_session_id,
Min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
inner join website_sessions
on website_sessions.website_session_id=website_pageviews.website_session_id
and website_sessions.created_at<'2012-07-28'
and website_pageviews.website_pageview_id>23504
and utm_source='gsearch'
and utm_campaign='nonbrand'
group by 1;

 create temporary table nonbrand_test_sessions_w_landing_page
select
first_test_pageviews.website_session_id,
website_pageviews.pageview_url as landing_page
from first_test_pageviews
left join website_pageviews
on website_pageviews.website_pageview_id=first_test_pageviews.min_pageview_id
where website_pageviews.pageview_url in('/home','/lander-1');
create temporary table nonbrand_test_bounced_sessions
select
nonbrand_test_sessions_w_landing_page.website_session_id,
nonbrand_test_sessions_w_landing_page.landing_page,
Count(distinct website_pageviews.website_pageview_id) as count_of_pages_viewed
from nonbrand_test_sessions_w_landing_page
left join website_pageviews
on website_pageviews.website_session_id=nonbrand_test_sessions_w_landing_page.website_session_id
group by 1,2
having count_of_pages_viewed=1;

select 
nonbrand_test_sessions_w_landing_page.landing_page,
Count( distinct nonbrand_test_sessions_w_landing_page.website_session_id) as total_sessions,
Count( distinct nonbrand_test_bounced_sessions.website_session_id) as bounced_sessions,
Count( distinct nonbrand_test_bounced_sessions.website_session_id)/Count( distinct nonbrand_test_sessions_w_landing_page.website_session_id) as bounce_rate
from nonbrand_test_sessions_w_landing_page
left join nonbrand_test_bounced_sessions
on nonbrand_test_sessions_w_landing_page.website_session_id=nonbrand_test_bounced_sessions.website_session_id 
group by 1
