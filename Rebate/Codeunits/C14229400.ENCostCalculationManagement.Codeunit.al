codeunit 14229400 "Cst Calculation Management ELA"
{
    trigger OnRun()
    begin

    end;

    procedure SetExcludeItemCharges(pblnExcludeItemCharges: Boolean)
    begin
        //<ENRE1.00>
        gblnExcludeItemCharges := pblnExcludeItemCharges;
        //</ENRE1.00>
    end;

    var
        UOMMgt: Codeunit "Unit of Measure Management";
        ExpOvhdCost: Decimal;
        gblnExcludeItemCharges: Boolean;
}