var kkeys = [], konami = "38,38,40,40,37,39,37,39,66,65";
$(document).keydown(function(e) {
    kkeys.push( e.keyCode );
    if ( kkeys.toString().indexOf( konami ) >= 0 ) {
    $(document).unbind('keydown',arguments.callee);
    // Pause Reveal.js so it stops stealing keyboard input
    if (typeof Reveal !== 'undefined') {
      Reveal.configure({keyboard: false});
      Reveal.slide(0); // go back to first slide
    }
    $('body').append(`
    <div id="legend-backdrop" style="position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.85);z-index:99999;" onclick="closeLegend()"></div>
    <div id="legend" style="position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);z-index:100000;background:#000;padding:10px;border-radius:8px;box-shadow:0 0 40px rgba(244,104,0,0.5);">
      <div style="text-align:right;margin-bottom:4px;"><span onclick="closeLegend()" style="color:#aaa;cursor:pointer;font-size:24px;padding:4px 8px;">&times;</span></div>
      <iframe src="https://www.retrogames.cc/embed/22709-legend-of-zelda-the-a-link-to-the-past-usa.html" width="600" height="450" frameborder="no" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" scrolling="no">
      </iframe>
    </div>
    `)
    }
});
function closeLegend() {
    $('#legend, #legend-backdrop').remove();
    if (typeof Reveal !== 'undefined') {
      Reveal.configure({keyboard: true});
    }
}
