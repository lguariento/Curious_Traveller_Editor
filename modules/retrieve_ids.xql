xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

for $doc in collection("/db/apps/app-ct/data/documents")
where $doc//tei:title[@ref="bi0022"]
let $id := $doc//tei:TEI/data(@xml:id)
 return
     $id