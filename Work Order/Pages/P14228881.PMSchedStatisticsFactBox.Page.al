page 23019293 "PM Sched. Statistics FactBox"
{
    // Copyright Axentia Solutions Corp.  1999-2014.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF43787SHR 20141030 - Changed calc of gdecNoDaysSinceLast
    // JF43788SHR 20141030 - clear variables
    // JF43819SHR 20141106 - add stop time

    Caption = 'Scheduling Statistics';
    Editable = false;
    PageType = CardPart;
    SourceTable = Table23019250;

    layout
    {
        area(content)
        {
            field("Last Work Order Date"; "Last Work Order Date")
            {
            }
            field("Qty. Produced"; "Qty. Produced")
            {
            }
            field("Capacity Qty."; "Capacity Qty.")
            {
            }
            field("Stop Time"; "Stop Time")
            {
            }
            group(Calendar)
            {
                Caption = 'Calendar';
                field(gdecNoDaysInCycle; gdecNoDaysInCycle)
                {
                    Caption = 'Days Between Work Orders';
                }
                field(gdecNoDaysSinceLast; gdecNoDaysSinceLast)
                {
                    Caption = 'Days Since Last Work Order';
                }
            }
            group(Cycles)
            {
                Caption = 'Cycles';
                field(Cycles; Cycles)
                {
                    Caption = 'Current';
                }
                field("Cycles at Last Work Order"; "Cycles at Last Work Order")
                {
                    Caption = 'As of Last Work Order';
                }
            }
            group()
            {
                field(gdecPctToNextWorkOrder; gdecPctToNextWorkOrder)
                {
                    Caption = 'Progress to Next Work Order';
                    ExtendedDatatype = Ratio;
                    MaxValue = 100;
                    MinValue = 0;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        gdecPctToNextWorkOrder := 0;

        IF ("PM Scheduling Type" = "PM Scheduling Type"::Cycles) AND ("Evaluation Qty." <> 0) THEN
            gdecPctToNextWorkOrder := ROUND((Cycles - "Cycles at Last Work Order") / "Evaluation Qty.") * 100;

        IF ("PM Scheduling Type" = "PM Scheduling Type"::Calendar) AND ("Last Work Order Date" <> 0D) THEN BEGIN
            //<JF43787SHR>
            gdecNoDaysSinceLast := WORKDATE - ("Last Work Order Date");
            //</JF43787SHR>
            gdecNoDaysInCycle := CALCDATE("Work Order Freq.", WORKDATE) - WORKDATE;

            IF (gdecNoDaysSinceLast <> 0) AND (gdecNoDaysInCycle <> 0) THEN
                gdecPctToNextWorkOrder := ROUND(gdecNoDaysSinceLast / gdecNoDaysInCycle) * 100;

            //<JF43788SHR>
        END ELSE BEGIN
            gdecNoDaysSinceLast := 0;
            gdecNoDaysInCycle := 0;
            //</JF43788SHR>
        END;
    end;

    var
        gdecPctToNextWorkOrder: Decimal;
        gdecNoDaysSinceLast: Decimal;
        gdecNoDaysInCycle: Decimal;
}

