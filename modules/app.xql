xquery version "3.1";

module namespace app="http://editor.curioustravellers.ac.uk/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://editor.curioustravellers.ac.uk/config" at "config.xqm";
import module namespace functx="http://www.functx.com";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html comedia-type=text/html";

declare variable $app:persons := doc('/db/apps/app-ct/data/pedb.xml');

declare function app:get-id($n as node()) as xs:integer {
   format-number(xs:integer(substring(data($n/@xml:id), 3)), "0000")
};

declare function app:pad-id($xml-id as xs:numeric, $db as xs:string) as xs:string {
    
    $db || format-number($xml-id, "0000")
};

declare function app:countBooks($node as node(), $model as map(*)) {

    let $count_books := count(doc('/db/apps/app-ct/data/indices/bidb.xml')//listBibl/bibl)
    return $count_books
};

declare function app:countPersons($node as node(), $model as map(*)) {
    let $count_persons := count(doc('/db/apps/app-ct/data/indices/pedb.xml')//listPerson/person)
    return $count_persons
};

declare function app:countPlaces($node as node(), $model as map(*)) {
    let $count_places := count(doc('/db/apps/app-ct/data/indices/pldb.xml')//listPlace/place)
    return $count_places  
};

declare function app:countArtworks($node as node(), $model as map(*)) {
    let $count_artworks := count(doc('/db/apps/app-ct/data/indices/ardb.xml')//item/rs)
    return $count_artworks
};


(: Books :)

declare function app:listbookEdit($node as node(), $model as map(*)) {

    let $hitHtml := "bookedit.html?searchkey="

    for $book in doc('/db/apps/app-ct/data/indices/bidb.xml')//listBibl/bibl
(:    order by $book/title:)

    return
    <tr>
    
        <td><div style="white-space:nowrap;"><a href="{concat($hitHtml,data($book/@xml:id))}">{substring(data($book/@xml:id), 3)}</a>
        <button style="display:contents;"class="js-copy btn btn-default" data-clipboard-text="{data($book/@xml:id)}">
        <img class="clippy" src="https://clipboardjs.com/assets/images/clippy.svg" width="13"/></button></div>
        <div class="copied" id="alert_{data($book/@xml:id)}"/></td>
        <td>{$book//title/text()}</td>
        <td>{$book//author/forename}</td>
        <td>{$book//author/surname}</td>
        <td>{$book//date}</td>
    
    </tr>
    
};

declare function app:bookEdit($node as node(), $model as map(*), $searchkey as xs:string?)

{

(:    let $newsearchkey := functx:substring-before-last($searchkey, '?'):)

    let $on-disk := doc('/db/apps/app-ct/data/indices/bidb.xml')
    let $biid := doc('/db/apps/app-ct/data/indices/bidb.xml')//bibl[@xml:id=$searchkey]/@xml:id

    let $title := doc('/db/apps/app-ct/data/indices/bidb.xml')//bibl[@xml:id=$searchkey]/title
    let $oldtitle := $on-disk//listBibl/bibl[@xml:id=$searchkey]/title
    
    let $addname := doc('/db/apps/app-ct/data/indices/bidb.xml')//bibl[@xml:id=$searchkey]/addName
    let $oldaddname := $on-disk//listBibl/bibl[@xml:id=$searchkey]/addName
    
    
    let $author_forename := doc('/db/apps/app-ct/data/indices/bidb.xml')//listBibl/bibl[@xml:id=$searchkey]/author/forename
    let $oldauthor_forename := $on-disk//listBibl/bibl[@xml:id=$searchkey]/author/forename

    let $author_surname := doc('/db/apps/app-ct/data/indices/bidb.xml')//listBibl/bibl[@xml:id=$searchkey]/author/surname
    let $oldauthor_surname := $on-disk//listBibl/bibl[@xml:id=$searchkey]/author/surname
    
    let $pubplace := doc('/db/apps/app-ct/data/indices/bidb.xml')//listBibl/bibl[@xml:id=$searchkey]/pubPlace
    let $oldpubplace := $on-disk//listBibl/bibl[@xml:id=$searchkey]/pubPlace
    
    let $year := doc('/db/apps/app-ct/data/indices/bidb.xml')//listBibl/bibl[@xml:id=$searchkey]/date
    let $oldyear := $on-disk//listBibl/bibl[@xml:id=$searchkey]/date
    
    let $publisher := doc('/db/apps/app-ct/data/indices/bidb.xml')//listBibl/bibl[@xml:id=$searchkey]/publisher
    let $oldpublisher := $on-disk//listBibl/bibl[@xml:id=$searchkey]/publisher
    
    let $note := doc('/db/apps/app-ct/data/indices/bidb.xml')//listBibl/bibl[@xml:id=$searchkey]/note/node()
    let $oldnote := $on-disk//listBibl/book[@xml:id=$searchkey]/note

    return
    
<div class="container">

<form action="bookupdated.html" target="bookupdated" method="POST">  
<h1 style="text-align:center;">Edit this curious book</h1>
<div class="form-group col-md-3">
<label for="biid">ID:</label>
<input readonly="readonly" class="form-control" type="text" name="biid" value="{$biid}"/>
<br/>
<label for="title">Title:</label>
<textarea type="text" class="form-control" style="white-space: normal; height: 100px; width: 100%;" name="title">{fn:normalize-space($title)}</textarea>
<input type="hidden" name="oldtitle" value="{$oldtitle}"/>
<br/>
<input type="hidden" name="count" value="1" />
<label for="bookddname">Variants:</label>
{ for $variant at $pos in $addname return
        <div class="input-append">
            <input class="form-control" id="field{$pos}" name="addname" value="{$variant}" ref="{$pos}" type="text"/>
            <input type="hidden" id="field{$pos}" name="oldaddname" value="{$oldaddname}"/>
        </div>
        }
        <button type="button" class="btn btn-default add-more">Add
        <span class="glyphicon glyphicon-plus" aria-hidden="true"></span></button>
        <button type="button" class="btn btn-default remove">Remove
        <span class="glyphicon glyphicon-minus" aria-hidden="true"></span></button>
        <br/>
        <br/>
<label for="author_forename">Author's forename:</label>
<input type="text" class="form-control" name="author_forename" value="{$author_forename}"/>
<input type="hidden" name="oldauthor_forename" value="{$oldauthor_forename}"/>
<br/>
<label for="author_surname">Author's surname:</label>
<input type="text" class="form-control" name="author_surname" value="{fn:normalize-space($author_surname)}"/>
<input type="hidden" name="oldauthor_surname" value="{$oldauthor_surname}"/>
<br/>
<label for="pubplace">Place of publication:</label>
<input type="text" class="form-control" name="pubplace" value="{fn:normalize-space($pubplace)}"/>
<input type="hidden" name="oldpubplace" value="{$oldpubplace}"/>
<br/>
<label for="year">Year of publication:</label>
<input type="text" class="form-control" name="year" value="{$year}"/>
<input type="hidden" name="oldyear" value="{$oldyear}"/>
<br/>

<label for="publisher">Publisher:</label>
<input type="text" class="form-control" name="publisher" value="{fn:normalize-space($publisher)}"/>

<input type="hidden" name="oldpublisher" value="{$oldpublisher}"/>

<br/>
</div>
<div class="col-md-9">
<br/>
<iframe scrolling="no" style="border: none; width:100%; height: 350px;" name="bookupdated"></iframe>
</div>
<div class="form-group col-md-12">
<label for="note">Note:</label><br/>
<textarea type="text" class="form-control" name="booknote" style="white-space: normal; height: 100px; width: 100%;">{$note}</textarea>
<input type="hidden" name="oldbooknote" value="{$oldnote}"/>
<br/>

<input class="btn btn-primary btn-lg" type="submit" value="Submit"/>
<a class="btn btn-danger pull-right" onclick="return confirm('Are you sure you want to delete this record?');" href="bookdeleted.html?biid={$biid}" style="margin-left: 18px;">*Delete record*</a>
<button class="btn btn-danger pull-right" type="reset" value="Reset">Reset</button>

<a href="books.html" class="btn btn-success pull-right" style="margin-right: 20px;">Back to list</a>
</div>
</form>
</div>

};

declare function app:bookDeleted ($node as node(), $model as map(*)) {

let $biid := request:get-parameter('biid', '')
let $on-disk := doc('/db/apps/app-ct/data/indices/bidb.xml')

let $delete := update delete $on-disk//bibl[@xml:id eq $biid]

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Deleted</title>
        
    </head>
    <body>

         <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <h3>You have deleted book no. {$biid}</h3>

        </div>
        
    </body>
    
</html>

};

declare function app:bookupdated($node as node(), $model as map(*)) {

let $biid := request:get-parameter('biid', '')

let $title := request:get-parameter('title', '')
let $oldtitle := request:get-parameter('oldtitle', '')

let $addname := request:get-parameter('addname', '')
let $oldaddname := request:get-parameter('oldaddname', '')

let $author_forename := request:get-parameter('author_forename', '')
let $oldauthor_forename := request:get-parameter('oldauthor_forename', '')

let $author_surname := request:get-parameter('author_surname', '')
let $oldauthor_surname := request:get-parameter('oldauthor_surname', '')

let $pubplace := request:get-parameter('pubplace', '')
let $oldpubplace := request:get-parameter('oldpubplace', '')

let $year := request:get-parameter('year', '')
let $oldyear := request:get-parameter('oldyear', '')

let $publisher := request:get-parameter('publisher', '')
let $oldpublisher := request:get-parameter('oldpublisher', '')

let $note_raw := request:get-parameter('booknote', '')
let $note := fn:parse-xml(concat('<note xmlns="http://www.tei-c.org/ns/1.0">', $note_raw, '</note>'))

let $oldnote := request:get-parameter('oldbooknote', '')

let $on-disk := doc('/db/apps/app-ct/data/indices/bidb.xml')

(:let $update := update value $on-disk//bibl[@xml:id eq $biid]/title with $title
let $update := update value $on-disk//bibl[@xml:id eq $biid]/author/surname with $author_surname
let $update := update value $on-disk//bibl[@xml:id eq $biid]/author/forename with $author_forename
let $update := update value $on-disk//bibl[@xml:id eq $biid]/pubPlace with $pubplace
let $update := update value $on-disk//bibl[@xml:id eq $biid]/year with $year
let $update := update value $on-disk//bibl[@xml:id eq $biid]/publisher with $publisher
let $update := update value $on-disk//bibl[@xml:id eq $biid]/note with $booknote:)

let $updatedrecord :=

<bibl xmlns="http://www.tei-c.org/ns/1.0" xml:id="{xs:ID($biid)}" >

<title>{$title}</title>
{for $variant at $pos in $addname return 
<addName ref="{$pos}">{$variant}</addName>}
<author>
<forename>{$author_forename}</forename>
<surname>{$author_surname}</surname>
</author>
<pubPlace>{$pubplace}</pubPlace>
<date>{$year}</date>
<publisher>{$publisher}</publisher>
{$note}

</bibl> 

let $insert := update replace $on-disk//bibl[@xml:id eq $biid] with $updatedrecord

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Book updated</title>
        
    </head>
    <body>
    
    <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <h3>You have changed:</h3><h3>
            
            {if ($oldtitle != $title) then (<br>- title (the old one was: {$oldtitle})</br>) else ()}
            {if ($oldauthor_forename != $author_forename) then (<br>- forename (the old one was: {$oldauthor_forename})</br>) else ()}
            {if ($oldaddname != $addname) then (<br>- variant</br>) else ()}
            {if ($oldauthor_surname != $author_surname) then (<br>- surname (the old one was: {$oldauthor_surname})</br>) else ()}
            {if ($oldpubplace != $pubplace) then (<br>- place of publication (the old one was: {$oldpubplace})</br>) else ()}
            {if ($oldyear != $year) then (<br>- year (the old one was: {$oldyear})</br>) else ()}
            {if ($oldpublisher != $publisher) then (<br>- publisher (the old one was: {$oldpublisher})</br>) else ()}
            {if ($oldnote != $note) then (<br>- note (the old one was: {$oldnote})</br>) else ()}
            
            
            </h3>
            <p>If you made a mistake and want to revert back to the previous value <br /> copy the old value above and paste it back to the form. 
            <br />'Reset' (followed by 'Submit') will revert all the fields as they were when you first opened this page.<br /> It's your last chance!</p>
            <p>If you want to add or edit something else on this record<br />just do so and submit the form again</p>

        <br />
        <br />

        </div>
        
    </body>
    
</html>

};

declare function app:addBook($node as node(), $model as map(*)) {

     let $id_gap :=
        
        (for $book in doc('/db/apps/app-ct/data/indices/bidb.xml')//bibl[position() ne last()]
        where local:get-id($book/@xml:id) ne (local:get-id($book/following-sibling::bibl[1]/@xml:id) - 1)
        return (local:get-id($book/@xml:id) + 1))[1]
        
(:        (for $key in (1 to 9999)!format-number(., '0000')
        let $bid := concat('bi', $key)
        where empty(doc('/db/apps/app-ct/data/indices/bidb.xml')//bibl[@xml:id=$bid])
        return $key)[1]:)
        
        let $idnext :=
        if (empty($id_gap)) then 
        (local:get-id(doc('/db/apps/app-ct/data/indices/bidb.xml')//bibl[last()]/@xml:id) + 1)
        else ($id_gap)
        
        let $newbiid := 
         if (fn:string-length($idnext) = 1) then
            concat('bi000', $idnext) else if 
            (fn:string-length($idnext) = 2) then 
            concat('bi00', $idnext) else if 
            (fn:string-length($idnext) = 3) then 
            concat('bi0', $idnext) else 
            concat('bi', $idnext)
    
    return
    
<div class="container">

<form action="bookadded.html" target="bookadded" method="POST">  
<h1 style="text-align:center;">Add a curious book</h1>
<div class="form-group col-md-3">

<label for="newbiid">ID:</label>
<input readonly="readonly" class="form-control" type="text" name="newbiid" value="{$newbiid}"/>
<br/>
<label for="title">Title:</label>
<input type="text" class="form-control" name="title" placeholter="title"/>
<br/>
		<input type="hidden" name="count" value="1" />

            <label for="bookaddname">Variants:</label>

                <div class="input-append">
                    <input class="form-control" id="field1" ref="1" name="bookaddname" type="text" placeholder="variant"  />
                </div>
                        <button type="button" class="btn btn-default add-more">Add
        <span class="glyphicon glyphicon-plus" aria-hidden="true"></span></button>
        <button type="button" class="btn btn-default remove">Remove
        <span class="glyphicon glyphicon-minus" aria-hidden="true"></span></button>
        <br />
        <br/>
<label for="author_forename">Author's forename:</label>
<input type="text" class="form-control" name="author_forename" placeholder="forename"/>
<br/>
<label for="author_surname">Author's surname:</label>
<input type="text" class="form-control" name="author_surname" placeholder="surname"/>
<br/>
<label for="pubplace">Place of publication:</label>
<input type="text" class="form-control" name="pubplace" placeholder="place of publication"/>
<br/>
<label for="year">Year of publication:</label>
<input type="text" class="form-control" name="year" placeholder="year"/>
<br/>
<label for="publisher">Publisher:</label>
<input type="text" class="form-control" name="publisher" placeholder="publisher"/>
<br/>    
</div>
<div class="col-md-9">
<br/>
<iframe scrolling="no" style="border: none; width:100%; height: 350px;" name="bookadded"></iframe>
</div>
<div class="form-group col-md-12">
<label for="note">Note:</label><br/>
<textarea type="text" class="form-control" placeholder="note" name="booknote" style="height: 100px; width: 100l%;"></textarea>
<br/>
<br/>
<input class="btn btn-primary btn-lg" type="submit" onclick="disable()" value="Submit"/>
<button class="btn btn-danger pull-right" type="reset" value="Reset">Reset</button>

<a href="books.html" class="btn btn-success pull-right" style="margin-right: 20px;">Back to list</a>
</div>

</form>

</div>

};

declare function app:bookadded($node as node(), $model as map(*)) {

let $newbiid := request:get-parameter('newbiid', '')
let $title := request:get-parameter('title', '')
let $bookaddname := request:get-parameter('bookaddname', '')
let $author_surname := request:get-parameter('author_surname', '')
let $author_forename := request:get-parameter('author_forename', '')
let $pubplace := request:get-parameter('pubplace', '')
let $year := request:get-parameter('year', '')
let $publisher := request:get-parameter('publisher', '')
let $note_raw := request:get-parameter('note', '')
let $note := fn:parse-xml(concat('<note xmlns="http://www.tei-c.org/ns/1.0">', $note_raw, '</note>'))


let $on-disk := doc('/db/apps/app-ct/data/indices/bidb.xml')

let $newrecord :=

<bibl xmlns="http://www.tei-c.org/ns/1.0" xml:id="{xs:ID($newbiid)}" >

<title>{$title}</title>
{for $variant at $pos in $bookaddname return 
<addName ref="{$pos}">{$variant}</addName>}
<author>
<forename>{$author_forename}</forename>
<surname>{$author_surname}</surname>
</author>
<pubPlace>{$pubplace}</pubPlace>
<date>{$year}</date>
<publisher>{$publisher}</publisher>
{$note}

</bibl> 

let $previous := local:get-id($newbiid) - 1
let $previd := 
if (fn:string-length($previous) = 1) then
   concat('bi000', $previous) else if 
   (fn:string-length($previous) = 2) then 
   concat('bi00', $previous) else if 
   (fn:string-length($previous) = 3) then 
   concat('bi0', $previous) else 
   concat('bi', $previous)

let $insert := update insert $newrecord following $on-disk//bibl[@xml:id eq $previd]

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Added {$newbiid}</title>
    </head>
    <body>
    
         <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <br />
            <h3>You have just added {($title)} to the database</h3>

            <p><a href="bookedit.html?searchkey={$newbiid}?p={$newbiid}" target="_parent"><b>Revise the details</b></a></p>
            <!-- appending a parameter for cache busting (newpeid should always be different each time) so that it forces the browser to load the page in no-cache mode  !-->
            <p><a href="addnewbook.html?p={$newbiid}" target="_parent"><b>Add another one</b></a></p>
            <br />

        </div>
        
    </body>
    
</html>

};

(: Places :)


declare function app:listplaceEdit($node as node(), $model as map(*)) {

    let $hitHtml := "placeedit.html?searchkey="

    for $place in doc('/db/apps/app-ct/data/indices/pldb.xml')//listPlace/place

    return
    <tr>
        <td class="col-md-1"><div style="white-space:nowrap;"><a href="{concat($hitHtml,data($place/@xml:id))}">{substring(data($place/@xml:id), 3)}</a>
        <button style="display: contents;" class="js-copy btn btn-default" data-clipboard-text="{data($place/@xml:id)}">
        <img class="clippy" src="https://clipboardjs.com/assets/images/clippy.svg" width="15"/></button></div>
        <div class="copied" id="alert_{data($place/@xml:id)}"/></td>   
        <td class="col-md-3" id="name">{$place/placeName/geogName}</td>
        <!-- <td><a href="{concat($hitHtml,data($place/@xml:id))}">{for $variant at $pos in $place/placeName/addName return ($variant[@ref = $pos])}</a></td> !-->
        <td class="col-md-2" id="variant">{$place/placeName/addName}</td>
        <td class="col-md-6" id="note" style="word-break: break-all;">{$place/placeName/note}</td>
    </tr>
    
};

declare function app:placeEdit($node as node(), $model as map(*), $searchkey as xs:string?)

{
    
(:    let $newsearchkey := functx:substring-before-last($searchkey, '?'):)

    let $on-disk := doc('/db/apps/app-ct/data/indices/pldb.xml')
    let $plid := doc('/db/apps/app-ct/data/indices/pldb.xml')//listPlace/place[@xml:id=$searchkey]/@xml:id

    let $placename := doc('/db/apps/app-ct/data/indices/pldb.xml')//listPlace/place[@xml:id=$searchkey]/placeName/geogName
    let $oldplacename := $on-disk//listPlace/place[@xml:id=$searchkey]/placeName/geogName
    let $addname := doc('/db/apps/app-ct/data/indices/pldb.xml')//listPlace/place[@xml:id=$searchkey]/placeName/addName
    let $oldaddname := $on-disk//listPlace/place[@xml:id=$searchkey]/placeName/addName
    let $geo := doc('/db/apps/app-ct/data/indices/pldb.xml')//listPlace/place[@xml:id=$searchkey]/placeName/geo
    let $oldgeo := $on-disk//listPlace/place[@xml:id=$searchkey]/placeName/geo
    let $placenote := doc('/db/apps/app-ct/data/indices/pldb.xml')//listPlace/place[@xml:id=$searchkey]/placeName/note/node()
    let $oldplacenote := $on-disk//listPlace/place[@xml:id=$searchkey]/placeName/note
    let $xsl := doc("/db/apps/app-ct/resources/xslt/xmlToHtml.xsl")
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
    
<div class="container">
<h1 style="text-align:center;">Edit this curious place</h1>
<form action="placeupdated.html" target="placeupdated" method="POST">  

<div class="form-group col-md-3">
<label for="plid">ID</label>
<input readonly="readonly" class="form-control" type="text" name="plid" value="{$plid}"/>
<br/>
<label for="placename">Place name:</label>
<input type="text" class="form-control" name="placename" value="{$placename}"/>
<input type="hidden" name="oldplacename" value="{$oldplacename}"/>
<br/>
<!-- <input type="text" class="form-control" name="pladdname" value="{$pladdname}"/>
<input type="hidden" name="oldpladdname" value="{$oldpladdname}"/> !-->
<input type="hidden" name="count" value="1" />
<label for="pladdname">Variants:</label>
{ for $variant at $pos in $addname return
        <div class="input-append">
            <input class="form-control" id="field{$pos}" name="addname" value="{$variant}" ref="{$pos}" type="text"/>
        </div>
        }
        <button type="button" class="btn btn-default add-more">Add
        <span class="glyphicon glyphicon-plus" aria-hidden="true"></span></button>
        <button type="button" class="btn btn-default remove">Remove
        <span class="glyphicon glyphicon-minus" aria-hidden="true"></span></button>
        <br />
       
<br/>
<label for="geo">Coordinates</label>
<input type="text" style="white-space:pre-line;" class="form-control" name="geo" value="{fn:normalize-space($geo)}"/>
<input type="hidden" name="oldgeo" value="{$oldgeo}"/>
</div>
<div class="col-md-9">
<br />
<iframe scrolling="no" style="border: none; width:100%; height: 350px;" name="placeupdated"></iframe>
</div>
<div class="form-group col-md-12">
<label for="placenote">Notes:</label>
<textarea type="text" class="form-control" name="placenote" style="white-space: normal; height: 100px; width: 100%;">{$placenote}</textarea>
<input type="hidden" name="oldplacenote" value="{$oldplacenote}"/>
<br/>
<h5>Note output:</h5>
<p>{transform:transform($placenote, $xsl, $params)}</p>
<br/>
<input class="btn btn-primary btn-lg" type="submit" value="Submit"/>
<a onclick="return confirm('Are you sure you want to delete this record?');" class="btn btn-danger pull-right" href="placedeleted.html?plid={$plid}" style="margin-left: 18px;">*Delete record*</a>
<button class="btn btn-danger pull-right" type="reset" value="Reset">Reset</button>

<a href="places.html" class="btn btn-success pull-right" style="margin-right: 20px;">Back to list</a>

</div>

</form>

</div>

};

declare function app:placeDeleted ($node as node(), $model as map(*)) {

let $plid := request:get-parameter('plid', '')
(:let $plid := functx:substring-before-last($id, '?'):)
let $on-disk := doc('/db/apps/app-ct/data/indices/pldb.xml')

let $delete := update delete $on-disk//place[@xml:id eq $plid]

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Deleted</title>
        
    </head>
    <body>

         <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <h3>You have deleted place no. {$plid}</h3>

        </div>
        
    </body>
    
</html>

};

declare function app:placeupdated($node as node(), $model as map(*)) {

let $plid := request:get-parameter('plid', '')

let $placename := request:get-parameter('placename', '')
let $oldplacename := request:get-parameter('oldplacename', '')

let $addname := request:get-parameter('addname', '')
let $oldaddname := request:get-parameter('oldaddname', '')

let $geo := request:get-parameter('geo', '')
let $oldgeo := request:get-parameter('oldgeo', '')

let $note_raw := request:get-parameter('placenote', '')

let $oldplacenote := request:get-parameter('oldplacenote', '')

let $on-disk := doc('/db/apps/app-ct/data/indices/pldb.xml')

let $placenote :=
fn:parse-xml(concat('<note xmlns="http://www.tei-c.org/ns/1.0">', string($note_raw), '</note>'))



let $updatedrecord :=

<place xmlns="http://www.tei-c.org/ns/1.0" xml:id="{xs:ID($plid)}" >

<placeName>
<geogName>{$placename}</geogName>
{for $variant at $pos in $addname return 
<addName ref="{$pos}">{$variant}</addName>}
<geo>{$geo}</geo>
{$placenote}
</placeName>
</place> 

let $insert := update replace $on-disk//place[@xml:id eq $plid] with $updatedrecord 


(:let $update := update value $on-disk//place[@xml:id eq $plid]/placeName/geogName with $placename
let $update := 
(\:for $variant at $pos in $pladdname return (update replace $on-disk//place[@xml:id eq $plid]/placeName/addName[@ref eq xs:string($pos)] with <addName xmlns="http://www.tei-c.org/ns/1.0" ref="{$pos}">{$variant}</addName>):\)

for $variant at $pos in $pladdname return (update value $on-disk//place[@xml:id eq $plid]/placeName/addName[@ref eq $pos] with $variant)
let $update := update value $on-disk//place[@xml:id eq $plid]/placeName/geo with $geo
let $update := update value $on-disk//place[@xml:id eq $plid]/placeName/note with $placenote:)

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Place updated</title>
        
    </head>
    <body>
    
            <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <h3>You have changed:</h3><h3>
            
            {if ($oldplacename != $placename) then (<br>- placename (the old one was: {$oldplacename})</br>) else ()}
            <!-- {if ($oldpladdname != $pladdname) then (<li>variant</li>) else ()} !-->
            {if ($oldgeo != $geo) then (<br>- coordinates (the old one was: {$oldgeo})</br>) else ()}
            <!-- {if ($oldplacenote != $placenote) then (<br>- note (the old one was: {data($oldplacenote)}))</br>) else ()} !-->
            
            </h3>
            <p>If you made a mistake and want to revert back to the previous value <br /> copy the old value above and paste it back to the form. 
            <br />'Reset' (followed by 'Submit') will revert all the fields as they were when you first opened this page.<br /> It's your last chance!</p>
            <p>If you want to add or edit something else on this record<br />just do so and submit the form again</p>

        <br />
        <br />
        
        </div>
        
    </body>
    
</html>

};

declare function app:addPlace($node as node(), $model as map(*)) {

      let $on-disk := doc('/db/apps/app-ct/data/indices/pldb.xml')
      let $plid := app:get-id($on-disk//listPlace/place[position() eq last()]) + 1   
 
          let $id_gap := 
          (for $place in ($on-disk//listPlace/place[position() ne last()])
              let $id := data($place/@xml:id)
              return if (app:get-id($place) + 1 ne (app:get-id($place/following-sibling::place[1])))
                      then app:get-id($place) + 1
                      else ())[1]
          
          let $idnext :=
          if (empty($id_gap)) then 
          app:pad-id($plid, "pl") else 
          app:pad-id($id_gap, "pl")

let $placename := request:get-parameter('placename', '')
let $pladdname := request:get-parameter('pladdname', '')
let $geo := request:get-parameter('geo', '')
let $placenote := request:get-parameter('placenote', '')
      
let $newrecord :=

<place xmlns="http://www.tei-c.org/ns/1.0" xml:id="{xs:ID($idnext)}" >

<placeName>
<geogName>{$placename}</geogName>
{for $variant at $pos in $pladdname return 
<addName ref="{$pos}">{$variant}</addName>}
<geo>{$geo}</geo>
<note>{$placenote}</note>
</placeName>
</place> 
        
        
let $previous := format-number(xs:integer(substring($idnext, 3)) -1, "0000")
let $previd := xs:ID("pl" || $previous)

(:let $login := xmldb:login('/db/apps/app-ct/data', 'admin', 'a8^CXi7JlFtFB'):)
let $insert := update insert $newrecord following $on-disk//place[@xml:id eq $previd]

       return
       
       <div>{$placename}, with ID {$idnext}</div>

};

declare function app:placeadded($node as node(), $model as map(*)) {

let $newplid := request:get-parameter('newplid', '')
let $id_gap := request:get-parameter('id_gap', '')
let $placename := request:get-parameter('placename', '')
let $pladdname := request:get-parameter('pladdname', '')
let $geo := request:get-parameter('geo', '')
let $note_raw := request:get-parameter('note', '')
let $note := fn:parse-xml(concat('<note xmlns="http://www.tei-c.org/ns/1.0">', $note_raw, '</note>'))


let $on-disk := doc('/db/apps/app-ct/data/indices/pldb.xml')

let $newrecord :=

<place xmlns="http://www.tei-c.org/ns/1.0" xml:id="{xs:ID($newplid)}" >

<placeName>
<geogName>{$placename}</geogName>
{for $variant at $pos in $pladdname return 
<addName ref="{$pos}">{$variant}</addName>}
<geo>{$geo}</geo>
{$note}
</placeName>
</place> 

let $previous := local:get-id($newplid) - 1
let $previd := 
if (fn:string-length($previous) = 1) then
   concat('pl000', $previous) else if 
   (fn:string-length($previous) = 2) then 
   concat('pl00', $previous) else if 
   (fn:string-length($previous) = 3) then 
   concat('pl0', $previous) else 
   concat('pl', $previous)
(:let $insert := update insert $newrecord following $on-disk//place[@xml:id eq $previd]:)
let $insert := update insert $newrecord following $on-disk//place[last()]

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Added {$newplid}</title>
        <script type="text/javascript" src="$app-root/resources/js/refresh.js"/>
    </head>
    <body>
    
         <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <br />
            <h3>You have just added "{$placename}" to the database.</h3>

            <p><a href="placeedit.html?searchkey={$newplid}?p={$newplid}" target="_parent"><b>Revise the details</b></a></p>
            <!-- appending a parameter for cache busting (newpeid should always be different each time) so that it forces the browser to load the page in no-cache mode  !-->
            <p><a href="addnewplace.html?p={$newplid}" target="_parent"><b>Add another one</b></a></p>
            <br />
            
        </div>
        
    </body>
    
</html>

};

(: persons :)

declare function app:listpersEdit($node as node(), $model as map(*)) {

    let $hitHtml := "persedit.html?searchkey="

    for $person in doc('/db/apps/app-ct/data/indices/pedb.xml')//listPerson/person
        
(:    order by $person//surname :)

    return
    
    <tr>

        <td>
        <div style="white-space:nowrap;"><a value="{data($person/@xml:id)}" href="{concat($hitHtml,data($person/@xml:id))}">{substring(data($person/@xml:id), 3)}</a>
        <button style="display:contents;"class="js-copy btn btn-default" data-clipboard-text="{data($person/@xml:id)}">
        <img class="clippy" src="https://clipboardjs.com/assets/images/clippy.svg" width="13"/></button></div>
        <div class="copied" id="alert_{data($person/@xml:id)}"/>
        <td>{$person/persName/surname}</td>
        <td>{$person/persName/forename}</td>
        <td>{$person/persName/note}</td>
        </td>
    
    </tr>
    
};

(: Checks :)

declare function app:placesCheck($node as node(), $model as map(*)) {

    let $hitHtml := "placeedit.html?searchkey="

    for $place in doc('/db/apps/app-ct/data/indices/pldb.xml')//listPlace/place
     let $check :=
         
         for $hit in collection(concat("/db/apps/app-ct", '/data/documents/'))//TEI[.//placeName[@ref = data($place/@xml:id)]]
         let $document := $hit
         return
             "ok"

    return
    if (empty($check)) then
    <tr>
        <td><div style="white-space:nowrap;"><a href="{concat($hitHtml,data($place/@xml:id))}">{substring(data($place/@xml:id), 3)}</a>
        <button style="display: contents;" class="js-copy btn btn-default" data-clipboard-text="{data($place/@xml:id)}">
        <img class="clippy" src="https://clipboardjs.com/assets/images/clippy.svg" width="15"/></button></div>
        <div class="copied" id="alert_{data($place/@xml:id)}"/></td>   
        <td class="col-md-4" id="name">{$place/placeName/geogName}</td>
        <!-- <td><a href="{concat($hitHtml,data($place/@xml:id))}">{for $variant at $pos in $place/placeName/addName return ($variant[@ref = $pos])}</a></td> !-->
        <td class="col-md-3" id="variant">{$place/placeName/addName}</td>
        <td class="col-md-4" id="note">{$place/placeName/note}</td>
    </tr>
    
    else ()
    
};


declare function app:persCheck($node as node(), $model as map(*)) {

    let $hitHtml := "persedit.html?searchkey="

    for $person in doc('/db/apps/app-ct/data/indices/pedb.xml')//listPerson/person
        let $check :=
        
        for $hit in collection(concat("/db/apps/app-ct", '/data/documents/'))//TEI[.//persName[@ref = data($person/@xml:id)]]
        return
            "ok"
        
(:    order by $person//surname :)

    return
    if (empty($check)) then(
    <tr>

        <td>
        <div style="white-space:nowrap;"><a value="{data($person/@xml:id)}" href="{concat($hitHtml,data($person/@xml:id))}">{substring(data($person/@xml:id), 3)}</a>
        <button style="display:contents;"class="js-copy btn btn-default" data-clipboard-text="{data($person/@xml:id)}">
        <img class="clippy" src="https://clipboardjs.com/assets/images/clippy.svg" width="13"/></button></div>
        <div class="copied" id="alert_{data($person/@xml:id)}"/>
        </td>
        <td>{$person/persName/surname}</td>
        <td>{$person/persName/forename}</td>
        <td>{$person/persName/note}</td>
    
    </tr>)
    
    else ()
    
};

declare function app:artworksCheck($node as node(), $model as map(*)) {

    let $hitHtml := "artworkedit.html?searchkey="

    for $artwork in doc('/db/apps/app-ct/data/indices/ardb.xml')//item/rs
    let $check :=
        
        for $hit in collection(concat("/db/apps/app-ct", '/data/documents/'))//TEI[.//rs[@ref = data($artwork/@xml:id)]]
        let $document := $hit
        return
            "ok"

    return
    if (empty($check)) then(
    <tr>
        <td><div style="white-space:nowrap;"><a href="{concat($hitHtml,data($artwork/@xml:id))}">{substring(data($artwork/@xml:id), 3)}</a>
        <button style="display: contents;" class="js-copy btn btn-default" data-clipboard-text="{data($artwork/@xml:id)}">
        <img class="clippy" src="https://clipboardjs.com/assets/images/clippy.svg" width="13"/></button></div>
        <div class="copied"  id="alert_{data($artwork/@xml:id)}"/></td>
        <td>{$artwork/title/text()}</td>
        <td>{$artwork/forename}</td>
        <td>{$artwork/surname}</td>
        <td>{$artwork/date}</td>
    </tr>)
    
    else ()
    
};

declare function app:booksCheck($node as node(), $model as map(*)) {

    let $hitHtml := "bookedit.html?searchkey="

    for $book in doc('/db/apps/app-ct/data/indices/bidb.xml')//listBibl/bibl
        let $check :=
        
        for $hit in collection(concat("/db/apps/app-ct", '/data/documents/'))//TEI[.//bibl/title[@ref = data($book/@xml:id)]]
        let $document := $hit
        return
            "ok"
(:    order by $book/title:)

    return
    if (empty($check)) then(
    <tr>
    
        <td><div style="white-space:nowrap;"><a href="{concat($hitHtml,data($book/@xml:id))}">{substring(data($book/@xml:id), 3)}</a>
        <button style="display:contents;"class="js-copy btn btn-default" data-clipboard-text="{data($book/@xml:id)}">
        <img class="clippy" src="https://clipboardjs.com/assets/images/clippy.svg" width="13"/></button></div>
        <div class="copied" id="alert_{data($book/@xml:id)}"/></td>
        <td>{$book//title/text()}</td>
        <td>{$book//author/surname}</td>
        <td>{$book//author/forename}</td>
        <td>{$book//date}</td>
    
    </tr>)
    
    else ()
    
};


declare function local:get-id($xml-id as xs:string) as xs:integer {
(:xs:integer(replace($xml-id, '[^0-9]+', '')):)
xs:integer(substring($xml-id, 3))
(:xs:integer(substring-after($xml-id, 'pe')):)
};

declare function app:next-id($pid as xs:string) as xs:string {
(:let $id := for $person in $on-disk//listPerson/person
         return
             data($person/@xml:id)
  
return:)

        if ((app:get-id($pid)) + 1 eq app:get-id(doc('/db/apps/app-ct/data/indices/pedb.xml')//following-sibling::person[1]))
        then app:get-id($pid) +2
        else app:get-id($pid) +1
};

declare

 %templates:wrap
 
function app:addPers($node as node(), $model as map(*)) {

      let $on-disk := doc('/db/apps/app-ct/data/indices/pedb.xml')
      let $peid := app:get-id($on-disk//listPerson/person[position() eq last()]) + 1
 
          let $id_gap := 
          (for $person in ($on-disk//listPerson/person[position() ne last()])
              let $id := data($person/@xml:id)
              return if (app:get-id($person) + 1 ne (app:get-id($person/following-sibling::person[1])))
                      then app:get-id($person) + 1
                      else ())[1]
          
          let $idnext :=
          if (empty($id_gap)) then 
          app:pad-id($peid, "pe") else 
          app:pad-id($id_gap, "pe")

let $surname := request:get-parameter('surname', '')
let $forename := request:get-parameter('forename', '')
let $rolename := request:get-parameter('rolename', '')
let $addname := request:get-parameter('addname', '')
let $note_raw := request:get-parameter('note', '')
let $note := fn:parse-xml(concat('<note xmlns="http://www.tei-c.org/ns/1.0">', $note_raw, '</note>'))

let $newrecord :=

<person xmlns="http://www.tei-c.org/ns/1.0" xml:id="{xs:ID($idnext)}" >

<persName>
<surname>{$surname}</surname>
<forename>{$forename}</forename>
<roleName>{$rolename}</roleName>
{for $variant at $pos in $addname return 
<addName ref="{$pos}">{$variant}</addName>}
{$note}
</persName>
</person>

let $previous := format-number(xs:integer(substring($idnext, 3)) -1, "0000")
let $previd := xs:ID("pe" || $previous)

(:let $login := xmldb:login('/db/apps/app-ct/data', 'admin', 'a8^CXi7JlFtFB'):)
let $insert := update insert $newrecord following $on-disk//person[@xml:id eq $previd]

       return
       
       <div>{$surname}, with ID {$idnext}</div>

    
};

declare function app:persEdit($node as node(), $model as map(*), $searchkey as xs:string?)

{

(:    let $newsearchkey := functx:substring-before-last($searchkey, '?'):)
        
    let $on-disk := doc('/db/apps/app-ct/data/indices/pedb.xml')
    let $peid := doc('/db/apps/app-ct/data/indices/pedb.xml')//listPerson/person[@xml:id=$searchkey]/@xml:id

    let $surname := doc('/db/apps/app-ct/data/indices/pedb.xml')//listPerson/person[@xml:id=$searchkey]/persName/surname
    let $oldsurname := $on-disk//listPerson/person[@xml:id=$searchkey]/persName/surname
    let $forename := doc('/db/apps/app-ct/data/indices/pedb.xml')//listPerson/person[@xml:id=$searchkey]/persName/forename
    let $oldforename := $on-disk//listPerson/person[@xml:id=$searchkey]/persName/forename
    let $rolename := doc('/db/apps/app-ct/data/indices/pedb.xml')//listPerson/person[@xml:id=$searchkey]/persName/roleName
    let $oldrolename := $on-disk//listPerson/person[@xml:id=$searchkey]/persName/roleName
    let $addname := doc('/db/apps/app-ct/data/indices/pedb.xml')//listPerson/person[@xml:id=$searchkey]/persName/addName
    let $oldaddname := $on-disk//listPerson/person[@xml:id=$searchkey]/persName/addName
    let $note := doc('/db/apps/app-ct/data/indices/pedb.xml')//listPerson/person[@xml:id=$searchkey]/persName/note/node()
    let $oldnote := $on-disk//listPerson/person[@xml:id=$searchkey]/persName/note

    return

<div class="container">
<h1 style="text-align:center;">Edit this curious person</h1>

<form action="persupdated.html" target="persedit" method="POST">  

<div style="white-space:nowrap;" class="col-md-3">

<div class="form-group">
<label for="peid">ID:</label>
<input readonly="readonly" class="form-control" type="text" name="peid" value="{$peid}"/>
<br/>
<label for="surname">Surname:</label>
<input class="form-control" type="text" name="surname" value="{$surname}"/>
<input type="hidden" name="oldsurname" value="{$oldsurname}"/>
<br/>
<label for="forename">Forename:</label>
<input class="form-control" type="text" name="forename" value="{$forename}"/>
<input type="hidden" name="oldforename" value="{$oldforename}"/>
<br/>
<label for="rolename">Role name: {$rolename}</label>
<!-- <input class="form-control" type="text" pattern="^[a-zA-Z]+$" name="rolename" value="{$rolename}"/> !-->
<input type="hidden" name="oldrolename" value="{$oldrolename}"/>
    
    { if (functx:contains-word('Admiral Archbishop Baron Bishop Captain Colonel Count Countess Dr Duchess Duke Earl Emperor Esquire King Lady Lieutenant Lord Miss MP Mr Mrs Prince Professor Provost Queen Reverend Sir Squire', $rolename))
    then (<p><b>The role name is in standardised form</b>.<br/> If you want to change it, select an option below, otherwise don't touch anything here.</p>) else (if ($rolename = "") then (<p><b>The role name is not set</b></p>) else (<p style="background: red;"><b>The role name is not in standard form</b></p>), <p>Select which one applies:</p>),
    <select type="text" class="form-control" id="rolename" name="rolename">,
    <option></option>,
    <option>Admiral</option>,
    <option>Archbishop</option>,
    <option>Baron</option>,
    <option>Bishop</option>,
    <option>Captain</option>,
    <option>Colonel</option>,
    <option>Count</option>,
    <option>Countess</option>,
    <option>Dr</option>,
    <option>Duchess</option>,
    <option>Duke</option>,
    <option>Earl</option>,
    <option>Emperor</option>,
    <option>Esquire</option>,
    <option>King</option>,
    <option>Lady</option>,
    <option>Lieutenant</option>,
    <option>Lord</option>,
    <option>Miss</option>,
    <option>MP</option>,
    <option>Mr</option>,
    <option>Mrs</option>,
    <option>Prince</option>,
    <option>Princess</option>,
    <option>Professor</option>,
    <option>Provost</option>,
    <option>Queen</option>,
    <option>Reverend</option>,
    <option>Sir</option>,
    <option>Squire</option>
  </select>
  }
  
  
<br/>

<!-- <label for="addname">Additional name:</label>
<input class="form-control" type="text" pattern="^[a-zA-Z ]+$" name="addname" value="{$addname}"/>
<input type="hidden" name="oldaddname" value="{$oldaddname}"/> !-->

<input type="hidden" name="count" value="1" />
<label for="pladdname">Variants:</label>
{ for $variant at $pos in $addname return
        <div class="input-append">
            <input class="form-control" id="field{$pos}" name="addname" value="{fn:normalize-space($variant)}" ref="{$pos}" type="text"/>
        </div>
        }
        <button type="button" class="btn btn-default add-more">Add
        <span class="glyphicon glyphicon-plus" aria-hidden="true"></span></button>
        <button type="button" class="btn btn-default remove">Remove
        <span class="glyphicon glyphicon-minus" aria-hidden="true"></span></button>
        <br />

</div> <!-- form-group !-->
</div> <!-- col-md-3 !-->


<div class="col-md-9">
<br/>
<iframe scrolling="no" style="border: none; width:100%; height: 350px;" name="persedit"></iframe>
</div>
<div class="form-group col-md-12">
<label for="note">Note:</label>
<textarea class="form-control" type="text" name="note" style="white-space: normal; height: 200px; width: 100%;">{$note}</textarea>
<input type="hidden" name="oldnote" value="{$oldnote}"/>
<br/>
<input class="btn btn-primary btn-lg" type="submit" value="Submit"/>
<a class="btn btn-danger pull-right" onclick="return confirm('Are you sure you want to delete this record?');" href="persdeleted.html?peid={$peid}" style="margin-left: 18px;">*Delete record*</a>
<button class="btn btn-warning pull-right" type="reset" value="Reset">Reset</button>

<a href="persons.html" class="btn btn-success pull-right" style="margin-right: 20px;">Back to list</a>

</div> <!-- form-group !-->
</form>
</div>

};

declare function app:persDeleted ($node as node(), $model as map(*)) {

let $peid := request:get-parameter('peid', '')
let $on-disk := doc('/db/apps/app-ct/data/indices/pedb.xml')

let $delete := update delete $on-disk//person[@xml:id eq $peid]

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Deleted</title>
        
    </head>
    <body>

         <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <h3>You have deleted person no. {$peid}</h3>

        </div>
        
    </body>
    
</html>

};

declare function app:persupdated($node as node(), $model as map(*)) {

let $peid := request:get-parameter('peid', '')

let $surname := request:get-parameter('surname', '')
let $oldsurname := request:get-parameter('oldsurname', '')

let $forename := request:get-parameter('forename', '')
let $oldforename := request:get-parameter('oldforename', '')

let $oldrolename := request:get-parameter('oldrolename', '')
let $rolename_q := request:get-parameter('rolename', '')

let $rolename := if ($rolename_q = '') then $oldrolename else $rolename_q

let $addname := request:get-parameter('addname', '')
let $oldaddname := request:get-parameter('oldaddname', '')

let $note_raw := request:get-parameter('note', '')
let $oldnote := request:get-parameter('oldnote', '')

let $on-disk := doc('/db/apps/app-ct/data/indices/pedb.xml')

let $persnote :=
fn:parse-xml(concat('<note xmlns="http://www.tei-c.org/ns/1.0">', string($note_raw), '</note>'))

(:let $update := update value $on-disk//person[@xml:id eq $peid]/persName/surname with $surname
let $update := update value $on-disk//person[@xml:id eq $peid]/persName/forename with $forename
let $update := update value $on-disk//person[@xml:id eq $peid]/persName/roleName with $rolename
let $update := update value $on-disk//person[@xml:id eq $peid]/persName/addName with $addname
let $update := update value $on-disk//person[@xml:id eq $peid]/persName/note with $note:)

let $updatedrecord :=

<person xml:id="{xs:ID($peid)}" >

<persName>
<surname>{$surname}</surname>
<forename>{$forename}</forename>
<roleName>{$rolename}</roleName>
{for $variant at $pos in $addname return 
<addName ref="{$pos}">{$variant}</addName>}
<note>{$persnote}</note>
</persName>
</person> 

let $insert := update replace $on-disk//person[@xml:id eq $peid] with $updatedrecord

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Updated</title>
        
    </head>
    <body>

         <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <h3>You have changed:</h3><h3>

            
            {if ($oldsurname != $surname) then (<br>- surname (the old one was: {$oldsurname})</br>) else ()}
            {if ($oldforename != $forename) then (<br>- forename (the old one was: {$oldforename})</br>) else ()}
            {if ($oldrolename != $rolename) then (<br>- role name (the old one was: {$oldrolename})</br>) else ()}
            {if ($oldnote != $note_raw) then (<br>- note (the old one was: {$oldnote})</br>) else ()}
            </h3>
            <p>If you made a mistake and want to revert back to the previous value <br /> copy the old value above and paste it back to the form. 
            <br />'Reset' (followed by 'Submit') will revert all the fields as they were when you first opened this page.<br /> It's your last chance!</p>
            <p>If you want to add or edit something else on this record<br />just do so and submit the form again</p>

        <br />
        <br />
        </div>
        
    </body>
    
</html>

};

(: Artworks :)

declare function app:listartworksEdit($node as node(), $model as map(*)) {

    let $hitHtml := "artworkedit.html?searchkey="

    for $artwork in doc('/db/apps/app-ct/data/indices/ardb.xml')//item/rs

    return
    <tr>
        <td><div style="white-space:nowrap;"><a href="{concat($hitHtml,data($artwork/@xml:id))}">{substring(data($artwork/@xml:id), 3)}</a>
        <button style="display: contents;" class="js-copy btn btn-default" data-clipboard-text="{data($artwork/@xml:id)}">
        <img class="clippy" src="https://clipboardjs.com/assets/images/clippy.svg" width="13"/></button></div>
        <div class="copied"  id="alert_{data($artwork/@xml:id)}"/></td>
        <td>{$artwork/title/text()}</td>
        <td>{$artwork/forename}</td>
        <td>{$artwork/surname}</td>
        <td>{$artwork/date}</td>
    </tr>
    
};

declare function app:artworkEdit($node as node(), $model as map(*), $searchkey as xs:string?)

{

(:    let $newsearchkey := functx:substring-before-last($searchkey, '?'):)

    let $on-disk := doc('/db/apps/app-ct/data/indices/ardb.xml')
    let $arid := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[@xml:id=$searchkey]/@xml:id

    let $arttitle := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[@xml:id=$arid]/title
    let $oldarttitle := $on-disk//rs[@xml:id=$searchkey]/title
    let $artforename := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[@xml:id=$arid]/forename
    let $oldartforename := $on-disk//rs[@xml:id=$searchkey]/forename
    let $artsurname := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[@xml:id=$searchkey]/surname
    let $oldartsurname := $on-disk//rs[@xml:id=$searchkey]/surname    
    let $histplace := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[@xml:id=$searchkey]/geogName[@type="historic"]
    let $oldhistplace := $on-disk//rs[@xml:id=$searchkey]/geogName[@type="historic"]
    let $currplace := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[@xml:id=$searchkey]/geogName[@type="current"]
    let $oldcurrplace := $on-disk//rs[@xml:id=$searchkey]/geogName[@type="current"]
    let $ardate := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[@xml:id=$searchkey]/date
    let $oldardate := $on-disk//rs[@xml:id=$searchkey]/date
    let $araddname := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[@xml:id=$searchkey]/addName
    let $oldaraddname := $on-disk//rs[@xml:id=$searchkey]/addName
    let $artnote := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[@xml:id=$searchkey]/note/node()
    let $oldartnote := $on-disk//rs[@xml:id=$searchkey]/note

    return
    
<div class="container">
<h1 style="text-align:center;">Edit this curious artwork</h1>
<form action="artworkupdated.html" target="artworkupdated" method="POST">  

<div class="form-group col-md-6">
<label for="arid">ID</label>
<input readonly="readonly" class="form-control" type="text" name="arid" value="{$arid}"/>
<br/>
<label for="arttitle">Artwork title:</label>
<input type="text" class="form-control" name="arttitle" value="{fn:normalize-space($arttitle)}"/>
<input type="hidden" name="oldarttitle" value="{fn:normalize-space($oldarttitle)}"/>
<br/>
<label for="artforename">Forename:</label>
<input type="text" class="form-control" name="artforename" value="{fn:normalize-space($artforename)}"/>
<input type="hidden" name="oldartforename" value="{fn:normalize-space($oldartforename)}"/>
<br/>
<label for="artsurname">Surname:</label>
<input type="text" class="form-control" name="artsurname" value="{fn:normalize-space($artsurname)}"/>
<input type="hidden" name="oldartsurname" value="{fn:normalize-space($oldartsurname)}"/>
<br/>
<label for="histplace">Historic place:</label>
<input type="text" class="form-control" name="histplace" value="{fn:normalize-space($histplace)}"/>
<input type="hidden" name="oldhistplace" value="{fn:normalize-space($oldhistplace)}"/>
<br/>
<label for="currplace">Current place:</label>
<input type="text" class="form-control" name="currplace" value="{fn:normalize-space($currplace)}"/>
<input type="hidden" name="oldcurrplace" value="{fn:normalize-space($oldcurrplace)}"/>
<br/>
<label for="ardate">Date:</label>
<input type="text" class="form-control" name="ardate" value="{$ardate}"/>
<input type="hidden" name="oldardate" value="{$oldardate}"/>
<br/>
<label for="araddname">Variants:</label>
<input type="text" class="form-control" name="araddname" value="{$araddname}"/>
<input type="hidden" name="oldaraddname" value="{$oldaraddname}"/>
<br/>

</div>
<div class="col-md-6">
<br />
<iframe scrolling="no" style="border: none; width:100%; height: 350px;" name="artworkupdated"></iframe>
</div>

<div class="form-group col-md-12">
<label for="artnote">Notes:</label>
<textarea type="text" class="form-control" name="artnote" style="white-space: normal; height: 100px; width: 100%;">{$artnote}</textarea>
<input type="hidden" name="oldartnote" value="{$oldartnote}"/>
<br/>
<input class="btn btn-primary btn-lg" type="submit" value="Submit"/>
<button class="btn btn-danger pull-right" type="reset" value="Reset">Reset</button>

<a href="artworks.html" class="btn btn-success pull-right" style="margin-right: 20px;">Back to list</a>
</div>
</form>
</div>

};

declare function app:artworkupdated($node as node(), $model as map(*)) {

let $arid := request:get-parameter('arid', '')

let $arttitle := request:get-parameter('arttitle', '')
let $oldarttitle := request:get-parameter('oldarttitle', '')

let $artforename := request:get-parameter('artforename', '')
let $oldartforename := request:get-parameter('oldartforename', '')

let $artsurname := request:get-parameter('artsurname', '')
let $oldartsurname := request:get-parameter('oldartsurname', '')

let $histplace := request:get-parameter('histplace', '')
let $oldhistplace := request:get-parameter('oldhistplace', '')

let $currplace := request:get-parameter('currplace', '')
let $oldcurrplace := request:get-parameter('oldcurrplace', '')

let $ardate := request:get-parameter('ardate', '')
let $oldardate := request:get-parameter('oldardate', '')

let $araddname := request:get-parameter('araddname', '')
let $oldaraddname := request:get-parameter('oldaraddname', '')

let $artnote_raw := request:get-parameter('artnote', '')
let $artnote := fn:parse-xml(concat('<note xmlns="http://www.tei-c.org/ns/1.0">', $artnote_raw, '</note>'))


let $oldartnote := request:get-parameter('oldartnote', '')



let $on-disk := doc('/db/apps/app-ct/data/indices/ardb.xml')

let $updatedrecord :=

<rs xmlns="http://www.tei-c.org/ns/1.0" xml:id="{xs:ID($arid)}" >

<title>{$arttitle}</title>
<forename>{$artforename}</forename>
<surname>{$artsurname}</surname>
<geogName type="historic">{$histplace}</geogName>
<geogName type="current">{$currplace}</geogName>
<date>{$ardate}</date>
<addName>{$araddname}</addName>
<note>{$artnote}</note>

</rs> 

let $insert := update replace $on-disk//rs[@xml:id eq $arid] with $updatedrecord 

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Artwork updated</title>
        
    </head>
    <body>
    
            <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <h3>You have changed:</h3><h3>
            
            {if ($oldarttitle != $arttitle) then (<br>- title (the old one was: {$oldarttitle})</br>) else ()}
            {if ($oldartforename != $artforename) then (<br>- forename (the old one was: {$oldartforename})</br>) else ()}
            {if ($oldartsurname != $artsurname) then (<br>- surname (the old one was: {$oldartsurname})</br>) else ()}
            {if ($oldhistplace != $histplace) then (<br>- historic location (the old one was: {$oldhistplace})</br>) else ()}
            {if ($oldcurrplace != $currplace) then (<br>- current location (the old one was: {$oldcurrplace})</br>) else ()}
            {if ($oldardate != $ardate) then (<br>- date (the old one was: {$oldardate})</br>) else ()}
            {if ($oldaraddname != $araddname) then (<br>- variants (the old one was: {$oldaraddname})</br>) else ()}
            {if ($oldartnote != $artnote) then (<br>- note (the old one was: {$oldartnote}))</br>) else ()}
            
            </h3>
            <p>If you made a mistake and want to revert back to the previous value <br /> copy the old value above and paste it back to the form. 
            <br />'Reset' (followed by 'Submit') will revert all the fields as they were when you first opened this page.<br /> It's your last chance!</p>
            <p>If you want to add or edit something else on this record<br />just do so and submit the form again</p>

        <br />
        <br />
        
        </div>
        
    </body>
    
</html>

};

declare function app:addArtwork($node as node(), $model as map(*)) {

    let $arid := doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[last()]/@xml:id    
    let $newarid := xs:ID("ar" || format-number(xs:integer(substring($arid, 3)) + 1, "0000"))
    
    let $id_gap :=
        
        (for $artwork in doc('/db/apps/app-ct/data/indices/ardb.xml')//rs[position() ne last()]
        where format-number(local:get-id($artwork/@xml:id), "0000") ne format-number((local:get-id($artwork/following-sibling::rs[1]/@xml:id) - 1), "0000")
        return format-number((local:get-id($artwork/@xml:id) + 1), "0000"))[1]
        
        let $idnext :=
        if (empty($id_gap)) then
        $newarid
        else "ar" || $id_gap
        
       return
    
<div class="container">

<form action="artworkadded.html" target="artworkadded" method="POST">  

<h1 style="text-align:center;">Add a curious artwork</h1>
<div class="form-group col-md-3">

<label for="idnext">ID</label>
<input readonly="readonly" class="form-control" type="text" name="idnext" value="{$idnext}"/>
<br/>
<label for="arttitle">Artwork title:</label>
<input type="text" class="form-control" name="arttitle"/>
<br/>
<label for="artforename">Forename:</label>
<input type="text" class="form-control" name="artforename"/>
<br/>
<label for="artsurname">Surname:</label>
<input type="text" class="form-control" name="artsurname"/>
<br/>
<label for="histplace">Historic place:</label>
<input type="text" class="form-control" name="histplace"/>
<br/>
<label for="currplace">Current place:</label>
<input type="text" class="form-control" name="currplace"/>
<br/>
<label for="ardate">Date:</label>
<input type="text" class="form-control" name="ardate"/>
<br/>
<label for="araddname">Variants:</label>
<input type="text" class="form-control" name="araddname"/>
<br/>

</div>
<div class="col-md-9">
<br />
<iframe scrolling="no" style="border: none; width:100%; height: 350px;" name="artworkadded"></iframe>
</div>

<div class="form-group col-md-12">
<label for="artnote">Notes:</label>
<textarea type="text" class="form-control" name="artnote" style="white-space: normal; height: 100px; width: 100%;"></textarea>
<br/>
<input class="btn btn-primary btn-lg" type="submit" onclick="disable()" value="Submit"/>
<button class="btn btn-danger pull-right" type="reset" disabled="disabled" value="Reset">Reset</button>

<a href="artworks.html" class="btn btn-success pull-right" style="margin-right: 20px;">Back to list</a>
</div>
</form>

</div>

};

declare function app:artworkadded($node as node(), $model as map(*)) {

let $idnext := request:get-parameter('idnext', '')
let $arttitle := request:get-parameter('arttitle', '')
let $artforename := request:get-parameter('artforename', '')
let $artsurname := request:get-parameter('artsurname', '')
let $histplace := request:get-parameter('histplace', '')
let $currplace := request:get-parameter('currplace', '')
let $ardate := request:get-parameter('ardate', '')
let $araddname := request:get-parameter('araddname', '')
let $artnote := request:get-parameter('artnote', '')

let $on-disk := doc('/db/apps/app-ct/data/indices/ardb.xml')

let $newrecord :=

<rs xmlns="http://www.tei-c.org/ns/1.0" xml:id="{xs:ID($idnext)}" >

<title>{$arttitle}</title>
<forename>{$artforename}</forename>
<surname>{$artsurname}</surname>
<geogName type="historic">{$histplace}</geogName>
<geogName type="current">{$currplace}</geogName>
<date>{$ardate}</date>
<addName>{$araddname}</addName>
<note>{$artnote}</note>

</rs> 

let $previous := local:get-id($idnext) - 1
let $previd := "ar" || format-number($previous, "0000")
let $insert := update insert $newrecord following $on-disk//rs[@xml:id eq $previd]

return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Added {$idnext}</title>
    </head>
    <body>
    
         <div style="background:floralwhite; text-align:center; border-radius: 80px; overflow: hidden;">
            <br />
            <h3>You have just added {$arttitle} to the database</h3>

            <p><a href="artworkedit.html?searchkey={$idnext}" target="_parent"><b>Revise the details</b></a></p>
            <!-- appending a parameter for cache busting (newpeid should always be different each time) so that it forces the browser to load the page in no-cache mode !-->
            <p><a href="addnewartwork.html?p={$idnext}" target="_parent"><b>Add another one</b></a></p>
            <br />
            
        </div>
        
    </body>
    
</html>

};