page 14229840 "PM Sched. Statistics FactBox"
{
    Caption = 'Scheduling Statistics';
    Editable = false;
    PageType = CardPart;
    SourceTable = "PM Procedure Header ELA";

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
                field(Current; Cycles)
                {
                    Caption = 'Current';
                }
                field("Cycles at Last Work Order"; "Cycles at Last Work Order")
                {
                    Caption = 'As of Last Work Order';
                }
            }
            group(groupName)
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

