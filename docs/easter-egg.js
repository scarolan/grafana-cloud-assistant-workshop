var kkeys = [], konami = "38,38,40,40,37,39,37,39,66,65";
$(document).keydown(function(e) {
    kkeys.push( e.keyCode );
    if ( kkeys.toString().indexOf( konami ) >= 0 ) {
    $(document).unbind('keydown',arguments.callee);
    $('body').append(`
    <div id="legend" style="position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);z-index:9999;background:#000;padding:10px;border-radius:8px;box-shadow:0 0 40px rgba(244,104,0,0.5);">
      <div style="text-align:right;margin-bottom:4px;"><span onclick="document.getElementById('legend').remove()" style="color:#aaa;cursor:pointer;font-size:20px;">&times;</span></div>
      <iframe src="https://www.retrogames.cc/embed/22709-legend-of-zelda-the-a-link-to-the-past-usa.html" width="600" height="450" frameborder="no" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" scrolling="no">
      </iframe>
    </div>
    `)
    }
});
