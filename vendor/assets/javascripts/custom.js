(function($){
"use strict";
    /*---Tab Js --*/
    $("#simple-design-tab a").on('click', function(e){
            e.preventDefault();
            $(this).tab('show');
    });
})(jQuery);
