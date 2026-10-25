// Tạm tính tiền ngay trên trang đặt sân (tiền chính thức do server tính khi lưu).
(function () {
    var form = document.getElementById('bookingForm');
    if (!form) {
        return;
    }
    var pricePerHour = parseFloat(form.getAttribute('data-price'));
    var startSel = document.getElementById('start');
    var endSel = document.getElementById('end');
    var box = document.getElementById('total');

    function toMin(v) {
        if (!v) {
            return null;
        }
        var p = v.split(':');
        return parseInt(p[0], 10) * 60 + parseInt(p[1], 10);
    }

    function update() {
        var s = toMin(startSel.value), e = toMin(endSel.value);
        if (s === null || e === null) {
            box.textContent = '';
            return;
        }
        if (e - s < 30) {
            box.textContent = 'Giờ kết thúc phải sau giờ bắt đầu ít nhất 30 phút.';
            return;
        }
        var total = Math.round(pricePerHour * (e - s) / 60);
        box.textContent = 'Tạm tính: ' + total.toLocaleString('vi-VN') + ' đ (' + ((e - s) / 60) + ' giờ)';
    }

    startSel.addEventListener('change', update);
    endSel.addEventListener('change', update);
    update();
})();
