xquery version "3.1";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/apps/app-ct-ed/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$exist:path}pages/index.html"/>
    </dispatch>
    
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
            <set-header name="Cache-Control" value="no-cache"/>
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="yes"/>
        </forward>
    </dispatch>

(: Resource paths starting with $app-root are loaded from the application's root collection :)
else if (contains($exist:path,"app-root")) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{$exist:controller}/{substring-after($exist:path, '$app-root/')}">
        <set-header name='Cache-Control' value="yes"/>
    </forward>
</dispatch>

else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
