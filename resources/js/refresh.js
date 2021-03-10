/*window.addEventListener('load', function (e) {
    window.applicationCache.addEventListener('updateready', function (e) {
        window.location.reload(true);
        }, false);
    console.log("loaded");
}, false);*/

$(window).on('load', function() {

$("a").attr("href", function(i, href) {
  return href + "?rand=" + Math.random();
});
})

$("iframe").on('load', function() {

$("a").attr("href", function(i, href) {
  return href + "?rand=" + Math.random();
});
})