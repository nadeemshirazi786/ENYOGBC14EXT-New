pageextension 14229611 "EN Pstd Purch. Rcpt. Subform" extends "Posted Purchase Rcpt. Subform"
{
    procedure _ShowExtraCharges()
    begin
        Rec.ShowExtraChargesELA; //ENEC1.00
    end;
}