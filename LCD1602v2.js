function LCD1602v2() {
    var i2c = require('i2c');
    var Jdate = require('jdate');
    var address = 0x27;


// commands
    LCD_CLEARDISPLAY = 0x01;
    LCD_RETURNHOME = 0x02;
    LCD_ENTRYMODESET = 0x04;
    LCD_DISPLAYCONTROL = 0x08;
    LCD_CURSORSHIFT = 0x10;
    LCD_FUNCTIONSET = 0x20;
    LCD_SETCGRAMADDR = 0x40;
    LCD_SETDDRAMADDR = 0x80;

//flags for display entry mode
    LCD_ENTRYRIGHT = 0x00;
    LCD_ENTRYLEFT = 0x02;
    LCD_ENTRYSHIFTINCREMENT = 0x01;
    LCD_ENTRYSHIFTDECREMENT = 0x00;

//flags for display on/off control
    LCD_DISPLAYON = 0x04;
    LCD_DISPLAYOFF = 0x00;
    LCD_CURSORON = 0x02;
    LCD_CURSOROFF = 0x00;
    LCD_BLINKON = 0x01;
    LCD_BLINKOFF = 0x00;

// flags for display/cursor shift
    LCD_DISPLAYMOVE = 0x08;
    LCD_CURSORMOVE = 0x00;
    LCD_MOVERIGHT = 0x04;
    LCD_MOVELEFT = 0x00;

//flags for function set
    LCD_8BITMODE = 0x10;
    LCD_4BITMODE = 0x00;
    LCD_2LINE = 0x08;
    LCD_1LINE = 0x00;
    LCD_5x10DOTS = 0x04;
    LCD_5x8DOTS = 0x00;

// flags for backlight control
    LCD_BACKLIGHT = 0x08;
    LCD_NOBACKLIGHT = 0x00;

    En = 0x4;//0b00000100 // Enable bit
    Rw = 0x2;//0b00000010 // Read/Write bit
    Rs = 0x1;//0b00000001 // Register select bit
    var self = this;
    this.lcd_device = undefined;
//----------- Constractor------------
    self.lcd_device = new i2c(address, {device: '/dev/i2c-1'});

    var WritRaw = function (RawData) {
        self.lcd_device.write(RawData, function (err) {
        });
    };
 //clocks EN to latch command
    function lcdStrobe(data) {
        WritRaw([(data | En | LCD_BACKLIGHT)]);
        // sleep(.0005)
        WritRaw(((data & ~En) | LCD_BACKLIGHT))
        // sleep(.0001)
    };

    var ClearLine = function (line) {

        var str = "";
        for (ii = 1; ii <= 16; ii++) {
            str += " ";
        }
        self.lineOut(str, line);
    };
    function lcdWrite4(data) {

        WritRaw(Buffer([(data | LCD_BACKLIGHT)]));
        WritRaw(Buffer([(data | LCD_DISPLAYON | LCD_BACKLIGHT)]));
        WritRaw(Buffer([((data & ~LCD_DISPLAYON) | LCD_BACKLIGHT)]));
      //  lcdStrobe(data);

    }

    function lcdWrite(data, mode) {
        lcdWrite4(mode | (data & 0xF0));
        lcdWrite4(mode | ((data << 4) & 0xF0));
    }
      function LCDINIT() {
        if (is_rpi_available) {
            lcdWrite(0x03, 0);
            lcdWrite(0x03, 0);
            lcdWrite(0x03, 0);
            lcdWrite(0x02, 0);

            lcdWrite(LCD_FUNCTIONSET | LCD_2LINE | LCD_5x8DOTS | LCD_4BITMODE, 0);
            lcdWrite(LCD_DISPLAYCONTROL | LCD_DISPLAYON, 0);
            lcdWrite(LCD_CLEARDISPLAY, 0);
            lcdWrite(LCD_ENTRYMODESET | LCD_ENTRYLEFT, 0);
        }
    }
    this.ShowTime = function () {

      //  var now = new Date();
        //  if (_LastMinuteValue != now.getMinutes()) {
        var j = Jdate.JDate();
        var persianDateStr = j.toString('yy/MM/ddHH:mm:ss');

        self.lineOut(persianDateStr, 2);
        j = null;

       // _LastMinuteValue = now.getMinutes();
        //   }

    };

    /*
     * Write a string to the specified LCD line.
     */
    this.lineOut = function (str, addr) {
        if (addr == 1)
            lcdWrite(0x80, 0);
        if (addr == 2)
            lcdWrite(0xC0, 0);
        if (addr == 3)
            lcdWrite(0x94, 0);
        if (addr == 4)
            lcdWrite(0xD4, 0);


        str.split('').forEach(function (c) {
            lcdWrite(c.charCodeAt(0), 1);
        });
    };
 LCDINIT();
    lcdWrite(LCD_CLEARDISPLAY,0);
}
module.exports.LCD1602v2 = new LCD1602v2();

var _lcdMan = require("./jfLCD").LCD1602v2;

var ic = 0;
setInterval(function () {

    _lcdMan.lineOut("salam " + ic, 1);
    _lcdMan.ShowTime();
    console.log("hi");
    ic++;
}, 1000);
