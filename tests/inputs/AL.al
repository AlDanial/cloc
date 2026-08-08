namespace MyCompany.Sales;

using Microsoft.Foundation;

table 50100 "My Table"
{
    // A field list.
    fields
    {
        field(1; Name; Text[50])
        {
            Caption = 'Name';
        }
    }

    /* A block comment
       spanning two lines. */
    procedure Compute(Value: Decimal): Decimal
    var
        Total: Decimal;
        Note: Text;
    begin
        Total := Value * 2;  // double it
        Note := 'It''s at https://example.com';
        Note := 'not /* a comment */ either';
        exit(Total);
    end;
}
