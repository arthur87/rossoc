
# rossoc
rossoc はSQLからコードを生成する実験的なプロジェクトです。  
SQLを mruby, mruby/c, と Arduino に変換します。 

# ガイド
例えば、`SELECT din11 FROM mruby WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9)` のようなSQLは以下のようなコードに変換されます。  

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

この mruby コードは次のコマンドで出力できます。  

```bash
rossoc query -i 'SELECT din11 FROM mruby WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9)' -o test.rb
```

sleep 関数を使用できます。`RSLEEP` は rossoc の独自キーワードです。

```bash
rossoc query -i 'SELECT din11 FROM mruby WHERE ((din1 = 0 AND din2 <= 1) OR din3 <> 9) RSLEEP 100' -o test.rb
```

`RSLEEP` を使用したコードは以下のようになります。

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

rossoc は `SELECT` ステートメントのみサポートしています。  
カラムには `din1` から `din20` と `ain1` から `ain20` を指定できます。dinはデジタルピン、ainはアナログピンです。  
テーブル名には `mruby`, `arduino` と `dev` が指定できます。
もし `dev` を指定したときシンプルなrubyコードを出力します。 このコードは物理的なボードを必要としません。

# 参考

このプロジェクトでは以下の文献、コード等を参考にしています。  

The following code is included to extend sql: https://github.com/cryodex/sql-parser  
mruby, mruby/c Common I/O API Guidelines and Community-developed Libraries: https://github.com/mruby/microcontroller-peripheral-interface-guide

# アーキテクチャ
rossoc はフロントエンドとバックエンドから構成されています。
独自のIR(中間表現)を介してフロントエンドとバックエンドを接続しています。  
フロントエンドは、字句、構文、意味解析を実行します。
バックエンドは、ターゲットのコードを生成します。

```mermaid
flowchart TB
    input --> FrontEnd
    subgraph FrontEnd
    parser --> columns --> tables --> condition --> rsleep
    end
    FrontEnd --> IR --> BackEnd
    subgraph BackEnd
    execute
    end
    execute --> output
```