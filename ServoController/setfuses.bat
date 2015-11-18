REM - SETS FUSES FOR EXTERNAL crystal < 8mhz NO internal clock div/8

avrdude -p atmega168 -P COM1 -c ponyser -U lfuse:w:0xf7:m -U hfuse:w:0xdf:m -U efuse:w:0xf9:m







