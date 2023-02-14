
window.addEventListener('resize',on_resize,false);

function on_resize(){
    glcanvas.width = window.innerWidth;
    glcanvas.height =window.innerHeight;
}

on_resize();