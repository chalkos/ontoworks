// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//
//= require turbolinks
//
//= require jquery
//= require jquery_ujs
//
//= require syntax-highlighter-rails/shCore
//= require syntax-highlighter-rails/shBrushXml
//
// APP
//= require queries
//
// OTHERS
//= require bootstrap
//= require buttons
//= require circles.min
//= require lightbox.min
//= require slidebars
//= require wow.min
//= require ie/html5shiv.min
//= require ie/respond.min

/* Smooth scrolling for anchors */
$(document).on('click','a.smooth', function(e){
    e.preventDefault();
    var $link = $(this);
    var anchor = $link.attr('href');
    $('html, body').stop().animate({
        scrollTop: $(anchor).offset().top
    }, 1000);
});

(function($) {
    $(document).ready(function() {
      $.slidebars();
    });
}) (jQuery);

// Syntax Enable
SyntaxHighlighter.all();

jQuery(document).ready(function () {
    // initialize all tooltips
    $(function () {
        $('[data-toggle="tooltip"]').tooltip()
    })

    $('.nav').on('click mousedown mouseup touchstart touchmove', 'a.has_children', function () {
        if ( $(this).next('ul').hasClass('open_t') && !$(this).parents('ul').hasClass('open_t')) {
            $('.open_t').removeClass('open_t');
            return false;
        }
        $('.open_t').not($(this).parents('ul')).removeClass('open_t');
        $(this).next('ul').addClass('open_t');
        return false;
    });
    $(document).on('click', ':not(.has_children, .has_children *)', function() {
        if( $('.open_t').length > 0 ) {
            $('.open_t').removeClass('open_t');
            $('.open_t').parent().removeClass('open');
            return false;
        }
    });

    // hide #back-top first
    $("#back-top").hide();

    // fade in #back-top
    $(function () {
        $(window).scroll(function () {
            if ($(this).scrollTop() > 100) {
                $('#back-top').fadeIn();
            } else {
                $('#back-top').fadeOut();
            }
        });

        // scroll body to 0px on click
        $('#back-top a').click(function () {
            $('body,html').animate({
                scrollTop: 0
            }, 500);
            return false;
        });
    });

});

// WOW Activate
new WOW().init();
