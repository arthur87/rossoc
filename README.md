

# rossoc
rossoc is an experimental project to generate code from sql.  
Converts sql to mruby, mruby/c, or Arduino source code.

# Guide
For example, SQL like `SELECT din11 FROM mruby WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9)` is converted to source code like this:

```ruby
# SELECT `din11` FROM `mruby` WHERE ((`din1` = 0 AND `din2` <= 1) OR `din3` <> 9)

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
rossoc query -i 'SELECT din11 FROM mruby WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9)' -o test.rb
```

`RSLEEP` is the original keyword of rossoc. 
RSLEEP is measured in seconds, and processing will be suspended for the specified number of seconds.

```bash
rossoc query -i 'SELECT din11 FROM mruby WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9) RSLEEP 100' -o test.rb
```

The code will look like this.

```ruby
# SELECT `din11` FROM `mruby` WHERE ((`din1` = 0 AND `din2` <= 1) OR `din3` <> 9) RSLEEP 100

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

```c
// SELECT `din11` FROM `arduino` WHERE ((`din1` = 0 AND `din2` <= 1) OR `din3` <> 9) RSLEEP 100

void setup() {
  Serial.begin(9600);
  
  pinMode(11, INPUT);
  pinMode(1, INPUT);
  pinMode(2, INPUT);
  pinMode(3, INPUT);
}

void loop() {
  
  int din11 = digitalRead(11);
  int din1 = digitalRead(1);
  int din2 = digitalRead(2);
  int din3 = digitalRead(3);


  if((din1 == 0 && din2 <= 1) || din3 != 9) {

    Serial.print("din11=");
    Serial.println(din11);

  }

  
  delay(100000);
  
}
```

rossoc is only `SELECT` statements are supported.  
The values ​​that can be specified for the column name are `din1` to `din20` and `ain1` to `ain20`. din corresponds to digital pin, and ain corresponds to analog pin.  
Possible values ​​for table name are `mruby`, `arduino` and `dev`.  
If you specify `dev`, simple ruby ​​code will be output and you can run it immediately without a board.

# Reference

The following code is included to extend sql: https://github.com/cryodex/sql-parser  
mruby, mruby/c Common I/O API Guidelines and Community-developed Libraries: https://github.com/mruby/microcontroller-peripheral-interface-guide

# Architecture
rossoc is composed of a front-end and a back-end.  
An original IR(Intermediate Representation) is used to connect the front-end and the back-end.  
The front-end performs lexical, syntactic and semantic analysis.  
The back-end generates code for the target.

```mermaid
flowchart TB
    input --> FrontEnd
    subgraph FrontEnd
    parser --> columns --> tables --> condition --> rsleep
    end
    FrontEnd --> IR --> BackEnd
    subgraph BackEnd
    generate
    write
    end
    write --> output
```