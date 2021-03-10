xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace functx = 'http://www.functx.com';

 let $on-disk := doc("/db/apps/app-ct/data/indices/pedb.xml")

 
 for $name in doc("/db/apps/app-ct/data/indices/pedb.xml")//tei:addName[not(@ref) and (text())]
 return
     update replace $on-disk//$name with  functx:add-attributes($name, xs:QName('ref'), 1)
