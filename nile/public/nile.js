$(document).ready(function() {

    $.template("zone-list",
	       "<li class=\"zone-link\"rel=\"/zones/${id}\">${fqdn}</li>");

    var zoneUnpacker = function(data) {
	$("#update-zone").html($("#zone-input-tmpl").tmpl({
	    fqdn: data["fqdn"],
	    host1: data["hosts"][0],
	    host2: data["hosts"][1],
	    ns: data["ns"]
	}))
    };

    var loadZones = function() {
	$.ajax({
	    url: "/zones",
	    dataType: "json",
	    type: "GET",
	    success: function(data) {
		$("#zone-list").html("");
		$.each(data, function(i, d) {
		    $.tmpl("zone-list", d).appendTo("#zone-list")
		});
	    }
	});
    };

    var loadZone = function(url) {
	$.ajax({
	    url: url,
	    dataType: "json",
	    type: "GET",
	    success: function(data) {zoneUnpacker(data)}
	});
    };

    $(".zone-link").live("click", function() {
	$(".selected").removeClass("selected");
	$(this).addClass("selected")
	loadZone($(this).attr('rel'));
    });

    $("#update-zone").live("submit", function() {
	$.ajax({
	    url: "/zones/" + $(this).find("#fqdn").val(),
	    type: "PUT",
	    data: {
		host1: $(this).find("#host1").val(),
		host2: $(this).find("#host2").val()
	    },
	    success: function(data) {zoneUnpacker(data);loadZones}
	});
	return false;
    });

    $("#new-zone").live("click", function() {
	zoneUnpacker({fqdn: "",hosts: []})
    });

    loadZones();
});
