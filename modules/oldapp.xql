xquery version "3.1";

module namespace app = "http://edition.curioustravellers.ac.uk/templates";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "http://edition.curioustravellers.ac.uk/config" at "config.xqm";
import module namespace tei2 = "http://exist-db.org/xquery/app/tei2html" at "tei2html.xql";
import module namespace functx = 'http://www.functx.com';
import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html media-type=text/html";

declare function app:checkPresence($node as node(), $model as map(*), $searchkey as xs:string?)

{
    
    let $message :=
    for $hit in collection(concat($config:app-root, '/data/documents/'))//tei:TEI[.//tei:bibl[@ref = $searchkey]]
    return
        if ($hit = "") then
            ("No docs linked")
        else
            ()
    return
        $message

};

declare function local:get-id($xml-id as xs:string) as xs:integer {
    xs:integer(replace($xml-id, '[^0-9]+', ''))
};

declare function app:countLetters($node as node(), $model as map(*)) {
    
    let $count_letters := count(collection(concat($config:app-root, "/data/documents"))/tei:TEI[@xml:id > "ct0100"])
    return
        $count_letters

};

declare function app:countTours($node as node(), $model as map(*)) {
    
    let $count_tours := count(collection(concat($config:app-root, "/data/documents"))/tei:TEI[@xml:id < "ct0100"])
    return
        $count_tours

};

declare function app:getDocName($node as node()) {
    let $name := functx:substring-after-last(document-uri(root($node)), '/')
    return
        $name
};

declare function app:hrefToDoc($node as node()) {
    let $href := concat('show.html', '?document=', app:getDocName($node))
    return
        $href
};

(: The transform (in the http://exist-db.org/xquery/transform function namespace) module 
provides functions for directly applying an XSL stylesheet 
to an XML fragment within an XQuery script.:)

declare function app:XMLtoHTML($node as node(), $model as map(*)) {
    let $ref := xs:string(request:get-parameter("document", ""))
    let $xmlPath := concat(xs:string(request:get-parameter("directory", "documents")), '/')
    let $xml := doc(replace(concat($config:app-root, "/data/", $xmlPath, $ref), '/exist', '/db/'))
    let $xslPath := concat(xs:string(request:get-parameter("stylesheet", "xmlToHtml")), '.xsl')
    let $xsl := doc(replace(concat($config:app-root, "/resources/xslt/", $xslPath), '/exist', '/db/'))
    
    (: get a list of all the URL parameters that are not either xml= or xslt= :)
    let $params :=
    <parameters>
        {
            for $p in request:get-parameter-names()
            let $val := request:get-parameter($p, ())
                where not($p = ("document", "directory", "stylesheet"))
            return
                <param
                    name="{$p}"
                    value="{$val}"/>
        }
    </parameters>
    
    return
        transform:transform($xml, $xsl, $params),
    
    (: navigation within the Pennant-Bull corpus :)
    
    let $thisid := "ct" || substring-before(request:get-parameter("document", ''), '.xml')
    
    let $nextdoc :=
    (for $doc in collection(concat($config:app-root, "/data/documents"))//tei:TEI[@xml:id > $thisid]
    let $sent := $doc//tei:correspAction[@type = "sent"]/tei:persName
    let $received1 := $doc//tei:correspAction[@type = "received"]/tei:persName[1]
    let $received2 := $doc//tei:correspAction[@type = "received"]/tei:persName[2]
        
        where
        $sent/@ref = "pe0313" or $sent/@ref = "pe0232" and ($received1/@ref = "pe0313" or $received1/@ref = "pe0232")
        order by $doc/@xml:id
    return
        concat(substring(string($doc//@xml:id), 3), '.xml'))[1]
    
    let $prevdoc :=
    (for $doc in collection(concat($config:app-root, "/data/documents"))//tei:TEI[@xml:id < $thisid]
    let $sent := $doc//tei:correspAction[@type = "sent"]/tei:persName
    let $received1 := $doc//tei:correspAction[@type = "received"]/tei:persName[1]
    let $received2 := $doc//tei:correspAction[@type = "received"]/tei:persName[2]
        
        where
        ($sent/@ref = "pe0313" or $sent/@ref = "pe0232") and ($received1/@ref = "pe0313" or $received1/@ref = "pe0232")
        order by $doc/@xml:id descending
    return
        concat(substring(string($doc//@xml:id), 3), '.xml'))[1]
    
    return
        if ($thisid > "ct0999" and $thisid < "ct1270") then
            (
            if ($nextdoc) then
                <a
                    type="button"
                    class="btn btn-default pull-right"
                    href="https://edition.curioustravellers.ac.uk/pages/show.html?document={$nextdoc}">Next letter in the Pennant-Bull correspondence</a>
            else
                (<button
                    class="btn btn-default pull-right disabled">This is the last letter</button>),
            if ($prevdoc) then
                <a
                    type="button"
                    class="btn btn-default pull-left"
                    href="https://edition.curioustravellers.ac.uk/pages/show.html?document={$prevdoc}">Previous letter in the Pennant-Bull correspondence</a>
            else
                (<button
                    type="button"
                    class="btn btn-default pull-left disabled">This is the first letter</button>),
            <br/>,
            <br/>)
        else
            ()
};

(:~ : creates a basic table of content derived from the documents stored in '/data/documents' :)

declare function app:tocLetters($node as node(), $model as map(*)) {
    for $doc in collection(concat($config:app-root, "/data/documents"))/tei:TEI[@xml:id > "ct0100"]
    let $id := substring-before(app:getDocName($doc), '.xml')
    let $from := string($doc//tei:correspAction[@type = "sent"]/tei:persName)
    let $to := $doc//tei:correspAction[@type = "received"]/tei:persName
    let $day := functx:substring-after-last(string(data($doc//tei:correspAction[@type = "sent"]/tei:date/@when)), '-')
    let $month := functx:month-name-en(xs:date(data($doc//tei:correspAction[@type = "sent"]/tei:date/@when)))
    let $year := substring-before(data($doc//tei:correspAction[@type = "sent"]/tei:date/@when), '-')
    let $date := $year || ' ' || $month || ' ' || $day
    return
        
        <tr>
            
            <th
                scope="row"><a
                    href="{app:hrefToDoc($doc)}">{$id}</a></th>
            <td>{$from}</td>
            <td>{$to}</td>
            <td>{$date}</td>
        </tr>


};

declare function app:tocTours($node as node(), $model as map(*)) {
    
    for $doc in collection(concat($config:app-root, "/data/documents"))/tei:TEI[@xml:id < "ct0100"]
    let $id := substring-before(app:getDocName($doc), '.xml')
    let $title := string($doc//tei:titleStmt/tei:title)
    
    return
        <tr>
            
            <th
                scope="row"><a
                    href="{app:hrefToDoc($doc)}">{$id}</a></th>
            <td>{$title}</td>
        
        </tr>

};


declare function app:number($node as node(), $model as map(*)) {
    
    let $par := fn:current-dateTime()
    
    return
        
        $par

};

declare function app:listPers($node as node(), $model as map(*)) {
    
    let $hitHtml := "hits.html?searchkey="
    for $person in doc(concat($config:app-root, '/data/indices/pedb.xml'))//tei:listPerson/tei:person
    let $forename := $person/tei:persName/tei:forename
    let $surname := $person/tei:persName/tei:surname
    let $aka := $person/tei:persName/tei:addName
        order by $surname
    return
        
        <tr>
            
            <td><a
                    href="{concat($hitHtml, data($person/@xml:id))}">{
                        if ($surname = "") then
                            "[Unknown]"
                        else
                            $surname
                    }</a></td>
            <td><a
                    href="{concat($hitHtml, data($person/@xml:id))}">{
                        if ($forename = "") then
                            "[Unknown]"
                        else
                            $forename
                    }</a></td>
            <td>{$person/tei:persName/tei:addName}</td>
        
        </tr>


};

declare function app:listArtworks($node as node(), $model as map(*)) {
    
    let $hitHtml := "hitsartworks.html?searchkey="
    for $artwork in doc(concat($config:app-root, '/data/indices/ardb.xml'))//tei:rs
    return
        
        <tr>
            <td><a
                    href="{concat($hitHtml, data($artwork/@xml:id))}">{string($artwork/tei:title)}</a></td>
            <td><a
                    href="{concat($hitHtml, data($artwork/@xml:id))}">{string($artwork/tei:forename)}</a></td>
            <td><a
                    href="{concat($hitHtml, data($artwork/@xml:id))}">{string($artwork/tei:surname)}</a></td>
        </tr>


};

declare function app:listBooks($node as node(), $model as map(*)) {
    
    let $hitHtml := "hitsbooks.html?searchkey="
    for $book in doc(concat($config:app-root, '/data/indices/bidb.xml'))//tei:bibl
    
    return
        
        <tr>
            
            <td><a
                    href="{concat($hitHtml, data($book/@xml:id))}">{string($book/tei:title)}
                    </a>
            </td>
        
        </tr>


};

declare function app:listPers_hits($node as node(), $model as map(*), $searchkey as xs:string?)

{
    
    for $hit in collection(concat($config:app-root, '/data/documents/'))//tei:TEI[.//tei:persName[@ref = $searchkey]]
    let $document := substring-before(app:getDocName($hit), '.xml')
    let $title := $hit//tei:titleStmt/tei:title
    
    return
        
        <tr>
            <td><a
                    href="{app:hrefToDoc($hit)}">{$document}</a> ({string($title)})
            </td>
        </tr>
};

declare function app:listArtworks_hits($node as node(), $model as map(*), $searchkey as xs:string?)

{
    
    for $hit in collection(concat($config:app-root, '/data/documents/'))//tei:TEI[.//tei:rs[@ref = $searchkey]]
    let $document := substring-before(app:getDocName($hit), '.xml')
    let $title := $hit//tei:titleStmt/tei:title
    return
        
        <tr>
            <td><a
                    href="{app:hrefToDoc($hit)}">{$document}</a> ({string($title)})
            </td>
        </tr>
};

declare function app:listBooks_hits($node as node(), $model as map(*), $searchkey as xs:string?)

{
    
    for $hit in collection(concat($config:app-root, '/data/documents/'))//tei:TEI[.//tei:bibl/tei:title[@ref = $searchkey]]
    let $document := substring-before(app:getDocName($hit), '.xml')
    let $title := $hit//tei:titleStmt/tei:title
    return
        
        <tr>
            <td><a
                    href="{app:hrefToDoc($hit)}">{$document}</a> ({string($title)})
            </td>
        </tr>
};

declare function app:persDetails($node as node(), $model as map(*), $searchkey as xs:string?)

{
    
    let $note := doc(concat($config:app-root, '/data/indices/pedb.xml'))//tei:listPerson/tei:person[@xml:id = $searchkey]/tei:persName/tei:note
    let $forename := doc(concat($config:app-root, '/data/indices/pedb.xml'))//tei:listPerson/tei:person[@xml:id = $searchkey]/tei:persName/tei:forename
    let $surname := doc(concat($config:app-root, '/data/indices/pedb.xml'))//tei:listPerson/tei:person[@xml:id = $searchkey]/tei:persName/tei:surname
    let $rolename := doc(concat($config:app-root, '/data/indices/pedb.xml'))//tei:listPerson/tei:person[@xml:id = $searchkey]/tei:persName/tei:roleName
    let $addname := doc(concat($config:app-root, '/data/indices/pedb.xml'))//tei:listPerson/tei:person[@xml:id = $searchkey]/tei:persName/tei:addName
    
    return
        <div>
            <h2>Person details</h2>
            <br/>
            {
                if ($forename ne "") then
                    (<h4>{string($surname)}, {string($forename)}</h4>)
                else
                    (<h4>No name provided</h4>)
            }
            {
                if ($addname ne "") then
                    (<p>AKA: {string($addname)}</p>)
                else
                    (<p>No AKA provided</p>)
            }
            {
                if ($rolename ne "") then
                    (<p>Title: {string($rolename)}</p>)
                else
                    (<p>No title provided</p>)
            }
            {
                if ($note ne "") then
                    (<p>Notes: {string($note)}</p>)
                else
                    (<p>No notes provided</p>)
            }
            <div
                style="width: 20%;"
                class="alert alert-info"
                role="alert">
                <span
                    class="glyphicon glyphicon-pencil"
                    aria-hidden="true"></span>
                <a
                    class="alert-link"
                    target="_blank"
                    href="https://editor.curioustravellers.ac.uk/pages/persedit.html?searchkey={$searchkey}"> Edit in the Curious Editor</a>
            </div>
        </div>
};

declare function app:artworkDetails($node as node(), $model as map(*), $searchkey as xs:string?)

{
    
    let $title := doc(concat($config:app-root, '/data/indices/ardb.xml'))//tei:rs[@xml:id = $searchkey]/tei:title
    let $geognameHist := doc(concat($config:app-root, '/data/indices/ardb.xml'))//tei:rs[@xml:id = $searchkey]/tei:geogName[@type = "historic"]
    let $geognameCurr := doc(concat($config:app-root, '/data/indices/ardb.xml'))//tei:rs[@xml:id = $searchkey]/tei:geogName[@type = "current"]
    let $note := doc(concat($config:app-root, '/data/indices/ardb.xml'))//tei:rs[@xml:id = $searchkey]/tei:note
    let $forename := doc(concat($config:app-root, '/data/indices/ardb.xml'))//tei:rs[@xml:id = $searchkey]/tei:forename
    let $surname := doc(concat($config:app-root, '/data/indices/ardb.xml'))//tei:rs[@xml:id = $searchkey]/tei:surname
    let $date := doc(concat($config:app-root, '/data/indices/ardb.xml'))//tei:rs[@xml:id = $searchkey]/tei:date
    let $addname := doc(concat($config:app-root, '/data/indices/ardb.xml'))//tei:rs[@xml:id = $searchkey]/tei:addname
    
    return
        <div>
            <h2>Artwork details</h2>
            <br/>
            <h4><i>{string($title)}</i></h4>
            {
                if ($forename ne "" and $surname ne "") then
                    (<p>By {string($surname)}, {string($forename)}</p>)
                else
                    if ($surname ne "") then
                        (<p>By {string($surname)}
                        </p>)
                    else
                        (<p>No name provided</p>)
            }
            {
                if ($geognameHist ne "") then
                    (<p>Geogname (historic): {$geognameHist}</p>)
                else
                    (<p>No geogname (historic) provided</p>)
            }
            {
                if ($geognameCurr ne "") then
                    (<p>Geogname (current): {$geognameCurr}</p>)
                else
                    (<p>No geogname (current) provided</p>)
            }
            {
                if ($date ne "") then
                    (<p>Date: {$date}</p>)
                else
                    (<p>No date provided</p>)
            }
            {
                if ($addname ne "") then
                    (<p>Addname: {$addname}</p>)
                else
                    (<p>No addname provided</p>)
            }
            {
                if ($note ne "") then
                    (<p>Note: {$note}</p>)
                else
                    (<p>No note provided</p>)
            }
            <div
                style="width: 20%;"
                class="alert alert-info"
                role="alert">
                <span
                    class="glyphicon glyphicon-pencil"
                    aria-hidden="true"></span>
                <a
                    class="alert-link"
                    target="_blank"
                    href="https://editor.curioustravellers.ac.uk/pages/bookedit.html?searchkey={$searchkey}"> Edit in the Curious Editor</a>
            </div>
        
        </div>
};

declare function app:bookDetails($node as node(), $model as map(*), $searchkey as xs:string?)

{
    
    let $title := doc(concat($config:app-root, '/data/indices/bidb.xml'))//tei:bibl[@xml:id = $searchkey]/tei:title
    let $pubPlace := doc(concat($config:app-root, '/data/indices/bidb.xml'))//tei:bibl[@xml:id = $searchkey]/tei:pubPlace
    let $publisher := doc(concat($config:app-root, '/data/indices/bidb.xml'))//tei:bibl[@xml:id = $searchkey]/tei:publisher
    let $note := doc(concat($config:app-root, '/data/indices/bidb.xml'))//tei:bibl[@xml:id = $searchkey]/tei:note
    let $date := doc(concat($config:app-root, '/data/indices/bidb.xml'))//tei:bibl[@xml:id = $searchkey]/tei:date
    let $forename := doc(concat($config:app-root, '/data/indices/bidb.xml'))//tei:bibl[@xml:id = $searchkey]/tei:author/tei:forename
    let $surname := doc(concat($config:app-root, '/data/indices/bidb.xml'))//tei:bibl[@xml:id = $searchkey]/tei:author/tei:surname
    let $addname := doc(concat($config:app-root, '/data/indices/bidb.xml'))//tei:bibl[@xml:id = $searchkey]/tei:addname
    
    return
        <div>
            <h2>Book details</h2>
            <br/>
            <h4><i>{string($title)}</i></h4>
            {
                if ($addname ne "") then
                    (<p>AKA: {string($addname)}</p>)
                else
                    (<p>No AKA provided</p>)
            }
            {
                if ($surname ne "" and $forename ne "") then
                    (<p>By {string($surname)}, {string($forename)}</p>)
                else
                    if ($surname ne "") then
                        (<p>By {$surname}</p>)
                    else
                        (<p>No author provided</p>)
            }
            {
                if ($publisher ne "") then
                    (<p>Publisher: {string($publisher)}</p>)
                else
                    (<p>No publisher provided</p>)
            }
            {
                if ($pubPlace ne "") then
                    (<p>Publication place: {string($pubPlace)}</p>)
                else
                    (<p>No publication place provided</p>)
            }
            {
                if ($date ne "") then
                    (<p>Publication date: {string($date)}</p>)
                else
                    (<p>No publication date provided</p>)
            }
            {
                if ($note ne "") then
                    (<p>Note: {string($note)}</p>)
                else
                    (<p>No notes provided</p>)
            }
            
            <div
                style="width: 20%;"
                class="alert alert-info"
                role="alert">
                <span
                    class="glyphicon glyphicon-pencil"
                    aria-hidden="true"></span>
                <a
                    class="alert-link"
                    target="_blank"
                    href="https://editor.curioustravellers.ac.uk/pages/bookedit.html?searchkey={$searchkey}"> Edit in the Curious Editor</a>
            </div>
        </div>
};

declare function app:ft_search($node as node(), $model as map(*)) {
    if (request:get-parameter("searchexpr", "") != "") then
        let $searchterm as xs:string := request:get-parameter("searchexpr", "")
        for $hit in collection(concat($config:app-root, '/data/documents'))//tei:p[ft:query(., $searchterm)]
        (: passes the search term to the show.html so that we can highlight the search terms :)
        let $href := concat(app:hrefToDoc($hit), "&amp;searchexpr=", $searchterm)
        let $score as xs:float := ft:score($hit)
            order by $score descending
        return
            <tr>
                <td
                    class="KWIC">{
                        kwic:summarize($hit, <config
                            width="40"
                            link="{$href}"/>)
                    }</td>
                <td>{app:getDocName($hit)}</td>
            </tr>
    else
        <div>Nothing to search for</div>
};
