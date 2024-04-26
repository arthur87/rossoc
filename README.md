# rossoc

Convert sql to mruby mruby/c Common I/O API

# Guide

For example, SQL like `SELECT din11 FROM board WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9)` is converted to source code like this:

```ruby
# SELECT `din11` FROM `board` WHERE ((`din1` = 0 AND `din2` <= 1) OR `din3` <> 9)

GPIO.setmode(1, GPIO::IN) 
GPIO.setmode(2, GPIO::IN) 
GPIO.setmode(3, GPIO::IN) 
GPIO.setmode(11, GPIO::IN) 

uart1 = UART.new(1)

while 1 do

  din1 = GPIO.read(1) 
  din2 = GPIO.read(2) 
  din3 = GPIO.read(3) 
  din11 = GPIO.read(11) 

  if ((din1 == 0 && din2 <= 1) || din3 != 9)
    uart1.write("#{din11}\r\n") 
  end
end
```