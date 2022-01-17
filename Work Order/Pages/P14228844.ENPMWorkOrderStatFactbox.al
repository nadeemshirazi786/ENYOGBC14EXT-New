page 14228844 "PM Work Ord Stat. Factbox ELA"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Work Order Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Last Work Order Date"; "Last Work Order Date")
                {
                    ApplicationArea = All;
                }
                field("Qty. Produced"; "Qty. Produced")
                {
                    ApplicationArea = All;
                }
                field("Capacity Qty."; "Capacity Qty.")
                {
                    ApplicationArea = All;
                }
                field("Stop Time"; "Stop Time")
                {
                    ApplicationArea = All;
                }
                group(Calendar)
                {
                    field("Days Between Work Orders"; gdecNoDaysInCycle)
                    {
                        ApplicationArea = All;
                    }
                    field("Days Since Last Work Order"; gdecNoDaysSinceLast)
                    {
                        ApplicationArea = All;
                    }
                }
                group(Cycles)
                {
                    field(Current; Cycles)
                    {
                        ApplicationArea = All;
                    }
                    field("As of Last Work Order"; "Cycles at Last Work Order")
                    {
                        ApplicationArea = All;
                    }
                }
                group(" ")
                {
                    field("Progress to Next Work Order"; gdecPctToNextWorkOrder)
                    {
                        ApplicationArea = All;
                    }
                }
                group(Results)
                {
                    field("Maintenance Cost"; "Maintenance Cost")
                    {
                        ApplicationArea = All;
                    }
                    field("PM WO Failure"; "PM WO Failure")
                    {
                        ApplicationArea = All;
                    }
                    field("Test Complete"; "Test Complete")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        gdecPctToNextWorkOrder := 0;

        IF ("PM Scheduling Type" = "PM Scheduling Type"::Cycles) AND ("Evaluation Qty." <> 0) THEN
            gdecPctToNextWorkOrder := ROUND((Cycles - "Cycles at Last Work Order") / "Evaluation Qty.") * 100;

        IF ("PM Scheduling Type" = "PM Scheduling Type"::Calendar) AND ("Last Work Order Date" <> 0D) THEN BEGIN
            gdecNoDaysSinceLast := WORKDATE - CALCDATE("Work Order Freq.", "Last Work Order Date");
            gdecNoDaysInCycle := CALCDATE("Work Order Freq.", WORKDATE) - WORKDATE;

            IF (gdecNoDaysSinceLast <> 0) AND (gdecNoDaysInCycle <> 0) THEN
                gdecPctToNextWorkOrder := ROUND(gdecNoDaysSinceLast / gdecNoDaysInCycle) * 100;
        END;

        gblnOverPct := gdecPctToNextWorkOrder > 100;
    end;

    var
        gdecPctToNextWorkOrder: Decimal;
        gdecNoDaysSinceLast: Decimal;
        gdecNoDaysInCycle: Decimal;
        gblnOverPct: Boolean;
}