(function($) {
    /* Smooth scrolling for anchors */
    $(document).on('click','a.smooth', function(e){
        e.preventDefault();
        var $link = $(this);
        var anchor = $link.attr('href');
        $('html, body').stop().animate({
            scrollTop: $(anchor).offset().top
        }, 1000);
    });

    $(document).ready(function() {
        $.slidebars();

        var setTooltip = function(type, elem){
            if($(elem).hasClass( "tt-inline" )){
                $(elem).tooltip({
                    placement: type,
                    template: '<div class="tooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner tooltip-inline"></div></div>'
                });
            }else{
                $(elem).tooltip({placement: type});
            }
        };

        // tooltips
        $('.tt').attr('data-toggle','tooltip').each(function(i,e){setTooltip('top', e)});
        $('.tl').attr('data-toggle','tooltip').each(function(i,e){setTooltip('left', e)});
        $('.tr').attr('data-toggle','tooltip').each(function(i,e){setTooltip('right', e)});
        $('.tb').attr('data-toggle','tooltip').each(function(i,e){setTooltip('bottom', e)});


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
}) (jQuery);
