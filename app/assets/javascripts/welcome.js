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
      		$.get('/quick_search/welcome', {'q': q}, function(data) {
				$("#results").html(data);
			});
    	}, 500);
	});
	
	$(".welcomeSuggestionTerm").on("click", function(e) {
		var term = $(this).data('term');
		if(term) {
			$('#welcomeSearch').val(term).click();
			
		}
	});
	
	$.get('/quick_search/welcome', {'q': '*'}, function(data) {
		$("#results").html(data);
	});
});