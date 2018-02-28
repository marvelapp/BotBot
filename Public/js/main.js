$(document).ready(function(){

    $('.commands-menu li').click(function(){
      var tab_id = $(this).attr('data-tab');

      $('.commands-menu li').removeClass('active');
      $('.screenshot div').hide();

      $(this).addClass('active');
      $("#screenshot-"+tab_id).show();
    })

});
