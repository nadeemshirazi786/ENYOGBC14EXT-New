page 14229827 "PM Calc. Methods"
{
    DelayedInsert = true;
    PageType = List;
    SourceTable = "PM Calc. Methods ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("PM Scheduling Type"; "PM Scheduling Type")
                {

                    trigger OnValidate()
                    begin
                        PMSchedulingTypeOnAfterValidat;
                    end;
                }
                field("Work Order Freq."; "Work Order Freq.")
                {
                    Editable = "Work Order Freq.Editable";
                }
                field("Last Work Order Date"; "Last Work Order Date")
                {
                }
                field("Evaluation Qty."; "Evaluation Qty.")
                {
                    Editable = "Evaluation Qty.Editable";
                }
                field("Schedule at %"; "Schedule at %")
                {
                }
                field("Qty. Produced"; "Qty. Produced")
                {
                }
                field("Capacity Qty."; "Capacity Qty.")
                {
                }
                field(Cycles; Cycles)
                {
                }
                field("Cycles at Last Work Order"; "Cycles at Last Work Order")
                {
                }
                field(gdecCyclesPct; gdecCyclesPct)
                {
                    Caption = 'Percent of Calc. Method';
                    ExtendedDatatype = Ratio;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        jfdoCalcQuantities;
        OnAfterGetCurrRecord;
    end;

    trigger OnInit()
    begin
        "Work Order Freq.Editable" := TRUE;
        "Evaluation Qty.Editable" := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        gdecCyclesPct := 0;
        OnAfterGetCurrRecord;
    end;

    var
        gdecCyclesPct: Decimal;
        [InDataSet]
        "Evaluation Qty.Editable": Boolean;
        [InDataSet]
        "Work Order Freq.Editable": Boolean;

    [Scope('Internal')]
    procedure jfdoSetEditable()
    var
        lblnEvalQtyEdit: Boolean;
    begin
        "Work Order Freq.Editable" := "PM Scheduling Type" = "PM Scheduling Type"::Calendar;

        lblnEvalQtyEdit :=
          ("PM Scheduling Type" = "PM Scheduling Type"::Cycles) OR
          ("PM Scheduling Type" = "PM Scheduling Type"::"Qty. Produced") OR
          ("PM Scheduling Type" = "PM Scheduling Type"::"Run Time") OR
          ("PM Scheduling Type" = "PM Scheduling Type"::"Stop Time");
        "Evaluation Qty.Editable" := lblnEvalQtyEdit;
    end;

    [Scope('Internal')]
    procedure jfdoCalcQuantities()
    var
        ldecNoDaysSinceLast: Decimal;
        ldecNoDaysInCycle: Decimal;
    begin
        SETRANGE("Date Filter", "Last Work Order Date", WORKDATE);
        CALCFIELDS("Qty. Produced", "Capacity Qty.");

        gdecCyclesPct := 0;
        IF ("PM Scheduling Type" = "PM Scheduling Type"::Cycles) AND ("Evaluation Qty." <> 0) THEN
            gdecCyclesPct := 10000 * (Cycles - "Cycles at Last Work Order") / "Evaluation Qty.";

        CALCFIELDS("Last Work Order Date");
        IF ("PM Scheduling Type" = "PM Scheduling Type"::Calendar) AND ("Last Work Order Date" <> 0D) THEN BEGIN
            ldecNoDaysSinceLast := WORKDATE - "Last Work Order Date";
            ldecNoDaysInCycle := CALCDATE("Work Order Freq.", WORKDATE) - WORKDATE;
            IF ldecNoDaysInCycle <> 0 THEN
                gdecCyclesPct := ldecNoDaysSinceLast / ldecNoDaysInCycle * 10000;
        END;
    end;

    local procedure PMSchedulingTypeOnAfterValidat()
    begin
        jfdoSetEditable;
    end;

    local procedure OnAfterGetCurrRecord()
    begin
        xRec := Rec;
        jfdoSetEditable;
    end;
}

