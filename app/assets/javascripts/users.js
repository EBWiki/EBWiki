document.addEventListener("DOMContentLoaded", function(){
  const button = document.getElementById('edit-button');
	var display = button.dataset.display;
	if (display === 'false'){
		button.style.display = 'block';
	}
});