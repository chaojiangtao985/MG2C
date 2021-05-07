 var svgToImg;
  window.onload = function () {
    // 获取到svg标签
    var svg = document.querySelector('svg');
    // 实例化对象
    svgToImg = new svgToImg(svg);
  }

  // 下载
  function change() {
    // svg转图片
    console.log(11);
    svgToImg.change('Marydon', 'jpg');
  }
  
  function svg2jpg() {
    // svg转图片
    console.log(11);
    svgToImg.change('Marydon', 'jpg');
  }
  function svg2png() {
    // svg转图片
    console.log(11);
    svgToImg.change('Marydon', 'png');
  }
  function svg2tiff() {
    // svg转图片
    console.log(11);
    svgToImg.change('Marydon', 'tiff');
  }
