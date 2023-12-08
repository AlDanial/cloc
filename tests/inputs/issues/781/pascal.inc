(* https://en.wikibooks.org/wiki/Pascal_Programming/Examples *)
{...........................................................................}
Procedure PrinterTest;   { works in the text mode}

  begin
    rejestr.dx:=LPT1;  { Port Number to which the printer is attached ;  0 = LPT1 }
    rejestr.ah:=2;     { Function Number ; printer port status }
    Intr($17,rejestr); {BIOS Interrupt #17 : initializes the indicated printer port and returns its status }
    if rejestr.ah=144  { 10010000B : (bit 7) =1  i (bit 4) =1  }
       then writeLn('Printer on LPT1 is OK')
       else writeLn('Printer on LPT1 is not OK');
       WriteLst(Reset);
  end; { Procedure PrinterTest }
