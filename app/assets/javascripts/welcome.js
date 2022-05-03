jQuery(document).ready(function() {
	var timer;
	$("#results").html('');
	
	$(".welcomeSearchClear").on('click', function(e) {
		$('#welcomeSearch').val('');
		$(".welcomeSearchClear").hide();
	});
	
	$("#welcomeSearchForm").on("submit", function(e) {
		e.preventDefault();
		return false;
	});
	
	$("#welcomeSearch").on("keyup change click", function(e) {
		$('.welcomeSuggestions').show(250);
		
		var q = $('#welcomeSearch').val();
		if(!q.trim().length) { 
			$(".welcomeSearchClear").hide();
			return; 
		}
		$(".welcomeSearchClear").show();
		
		clearTimeout(timer);
    	timer = setTimeout(function () {
      		$.get('/welcome/search', {'q': q}, function(data) {
				$("#results").html(data);
				$("#refineContainer").load("/welcome/refinepanel");
			});
    	}, 500);
    	e.preventDefault();
	});
	
	$(".welcomeSuggestionTerm").on("click", function(e) {
		var term = $(this).data('term');
		if(term) {
			$('#welcomeSearch').val(term).click();
			
		}
	});
	
	$.get('/welcome/search', {'q': '*'}, function(data) {
		$("#results").html(data);
	});
});

function getDateExprFromFilterUI(prefix, f, i) {
    if (!f) { f = 'date_last_updated'; }
    if (!i) { i = 'updated_at'; }
    var mode = jQuery("#" + prefix + "_" + f + "_mode").val();  
    var date_expr = null;

    if (mode == 'between') {
        var min = jQuery("#" + prefix + "_" + f + "_min").val(); 
        var max = jQuery("#" + prefix + "_" + f + "_max").val(); 
        if (min && max) {
            date_expr = i + ":[" + min + " TO " + max + "]";
        }
    } else {
        var date = jQuery("#" + prefix + "_" + f + "_date").val(); 
        if (date) {
            if (mode == 'in') {
                date_expr = i + ":[" + date + " TO " + date + "]";
            } else if(mode == 'before') {
                date_expr = i + ":[1900-01-01 TO " + date + "]";
            } else if(mode == 'after') {
                date_expr = i + ":[" + date + " TO 2100-01-01]";
            }
        }
    }
    return date_expr;
}

function updateDateFilterUI(prefix, f) {
    if (!f) { f = 'date_last_updated'; }
    var mode = jQuery("#" + prefix + "_" + f + "_mode").val();  
            
    if (mode == 'between') {
        jQuery("#" + prefix + "_" + f + "_range, #" + prefix + "_" + f + "_min, #" + prefix + "_" + f + "_max").show().attr('disabled', false);
        jQuery("#" + prefix + "_" + f + "_date").hide().attr('disabled', true);
    } else {
        jQuery("#" + prefix + "_" + f + "_range, #" + prefix + "_" + f + "_min, #" + prefix + "_" + f + "_max").hide().attr('disabled', true);
        jQuery("#" + prefix + "_" + f + "_date").show().attr('disabled', false);
    }
}