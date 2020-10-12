$(document).ready(function() {
  $(".select2").select2();

    var IS_IPAD = navigator.userAgent.match(/iPad/i) !== null;
    var IS_IPHONE = (navigator.userAgent.match(/iPhone/i) !== null) || (navigator.userAgent.match(/iPod/i) !== null);

    if (IS_IPAD || IS_IPHONE) {

        $('a').on('click touchend', function() {
            var link = $(this).attr('href');
            window.open(link,'_self'); // opens in new window as requested

            return false; // prevent anchor click
        });
    }
});

