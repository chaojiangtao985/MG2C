(function (global) {
    global.svgToImg = function (svgHtml) {
        this.svgHtml = svgHtml;
    };
    global.svgToImg.prototype = {
        /**
         * svg转图片
         * @description
         * 1.将svg转base64；
         * 2.将base64格式的svg转指定的图片格式并下载
         * @param fileName
         * 图片名称
         * @param imgType
         * 图片类型：jpg/png/bmp
         *
         */
        change: function (fileName, imgType) {
            var This = this;
            //1.给svg标签添加属性：version和xmlns
            [
                ['version', 1.1],
                ['xmlns', "http://www.w3.org/2000/svg"],
            ].forEach(function (item) {
                This.svgHtml.setAttribute(item[0], item[1]);
            });
            // 2.获取到svg标签+标签内的所有元素
            var str = This.svgHtml.parentNode.innerHTML;

            //3.创建img
            var img = document.createElement('img');

            // 4.svg格式的base64图像
            img.setAttribute('src', 'data:image/svg+xml;base64,' + btoa(unescape(encodeURIComponent(str))));
            //base64格式的svg
            //document.getElementById('baseSvg').src='data:image/svg+xml;base64,'+ btoa(unescape(encodeURIComponent(str)));

            // 5.转换成指定图片格式
            img.onload = function () {
                // 1.创建canvas
                var canvas = document.createElement('canvas');
                var context = canvas.getContext("2d");

                canvas.width = img.width;
                canvas.height = img.height;
                // 2.根据base64格式的svg生成canvas
                context.drawImage(img, 0, 0);

                // 3.将canvas转字符串（按指定好的图片格式）
                var canvasData = canvas.toDataURL("image/" + imgType);
                // 4.创建图片元素
                var img2 = document.createElement('img');
                // 5.生成图片
                img2.setAttribute('src', canvasData);

                // 6.下载该图片
                img2.onload = function () {
                    var a = document.createElement("a");
                    // 下载
                    a.download = fileName + "." + imgType;
                    a.href = img2.getAttribute('src');
                    a.click();
                };
            };
        }
    }
}(this));
