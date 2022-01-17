page 14228841 "Work Order ELA"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Work Order Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("PM Work Order No."; "PM Work Order No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Evaluated At Qty."; "Evaluated At Qty.")
                {
                    ApplicationArea = All;
                }
                field("Work Order Date"; "Work Order Date")
                {
                    ApplicationArea = All;
                }
                field("Person Responsible"; "Person Responsible")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("PM Group Code"; "PM Group Code")
                {
                    ApplicationArea = All;
                }
                field(Cycles; Cycles)
                {
                    ApplicationArea = All;
                }
                field("Cycles at Last Work Order"; "Cycles at Last Work Order")
                {
                    ApplicationArea = All;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                }
                field("Contains Critical Control"; "Contains Critical Control")
                {
                    ApplicationArea = All;
                }
                field("PM Scheduling Type"; "PM Scheduling Type")
                {
                    ApplicationArea = All;
                }
                field("Work Order Freq."; "Work Order Freq.")
                {
                    ApplicationArea = All;
                }
                field("Evaluation Qty."; "Evaluation Qty.")
                {
                    ApplicationArea = All;
                }
            }
            part("Lines"; "Work Order Subform ELA")
            {
                SubPageLink = "PM Work Order No." = field("PM Work Order No.");
            }
            group(Scheduling)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Evaluation UOM"; grecWorkCenter."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Schedule at %"; "Schedule at %")
                {
                    ApplicationArea = All;
                }
                field("Maintenance Time"; "Maintenance Time")
                {
                    ApplicationArea = All;
                }
                field("Maintenance UOM"; "Maintenance UOM")
                {
                    ApplicationArea = All;
                }
                field("Evaluation at UOM"; grecWorkCenter."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(FactBoxes)
        {
            part("PM Work Order Factbox"; "PM Work Ord Stat. Factbox ELA")
            {
                ApplicationArea = all;
                SubPageLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM Proc. Version No." = FIELD("PM Proc. Version No."), "PM Procedure Code" = FIELD("PM Procedure Code");
                ShowFilter = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    procedure jfdoSetEditable()
    begin
        CLEAR(grecWorkCenter);
        CLEAR(grecMachineCenter);

        IF Type = Type::"Work Center" THEN
            IF grecWorkCenter.GET("No.") THEN;
        IF Type = Type::"Machine Center" THEN BEGIN
            IF grecMachineCenter.GET("No.") THEN;
            IF grecWorkCenter.GET(grecMachineCenter."Work Center No.") THEN;
        END;
    end;

    var
        //gcduPMVersionMgt: Codeunit "PM Management";
        grecPMWOHeader: Record "Work Order Header";
        grecWorkCenter: Record "Work Center";
        grecMachineCenter: Record "Machine Center";
        JFText0001: TextConst ENU = 'Do you wish to post this PM Work Order?';
}