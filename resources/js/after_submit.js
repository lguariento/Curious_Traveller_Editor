function disable() {
    $("input").attr("readonly", true);
    $("select").attr("readonly", true);
    $("option").attr("readonly", true);
    $("textarea").attr("readonly", true);
    $("input").addClass("disabled");
    return true;
}