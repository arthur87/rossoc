# rossoc

rossoc is an experimental project to generate code from sql.  
Convert sql to mruby and mruby/c with Common I/O API.

# Guide

For example, SQL like `SELECT din11 FROM board WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9)` is converted to source code like this:

```ruby
# SELECT `din11` FROM `board` WHERE ((`din1` = 0 AND `din2` <= 1) OR `din3` <> 9)

GPIO.setmode(11, GPIO::IN)
GPIO.setmode(1, GPIO::IN)
GPIO.setmode(2, GPIO::IN)
GPIO.setmode(3, GPIO::IN)

uart1 = UART.new(1)

while 1 do
  din11 = GPIO.read(11)
  din1 = GPIO.read(1)
  din2 = GPIO.read(2)
  din3 = GPIO.read(3)

  if ((din1 == 0 && din2 <= 1) || din3 != 9)
    uart1.puts("din11=#{din11}")
  end

end
```

This mruby code can be output with the following command.

```bash
rossoc query -i 'SELECT din11 FROM board WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9)' -o test.rb
```

You can also use the sleep function.  
`RSLEEP` is the original keyword of rossoc.

```bash
rossoc query -i 'SELECT din11 FROM board WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9) RSLEEP 100' -o test.rb
```

The code will look like this.

```ruby
# SELECT `din11` FROM `board` WHERE ((`din1` = 0 AND `din2` <= 1) OR `din3` <> 9) RSLEEP 100

GPIO.setmode(11, GPIO::IN)
GPIO.setmode(1, GPIO::IN)
GPIO.setmode(2, GPIO::IN)
GPIO.setmode(3, GPIO::IN)

uart1 = UART.new(1)

while 1 do
  din11 = GPIO.read(11)
  din1 = GPIO.read(1)
  din2 = GPIO.read(2)
  din3 = GPIO.read(3)

  if ((din1 == 0 && din2 <= 1) || din3 != 9)
    uart1.puts("din11=#{din11}")
  end

  sleep(100)

end
```

# Reference

The following code is included to extend sql: https://github.com/cryodex/sql-parser
