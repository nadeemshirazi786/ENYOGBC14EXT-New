page 14229800 "PM Procedure ELA"
{
    PageType = Document;
    SourceTable = "PM Procedure Header ELA";
    ApplicationArea = all;
    UsageCategory = Tasks;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Code; Code)
                {

                    trigger OnAssistEdit()
                    begin
                        IF AssistEdit(xRec) THEN
                            CurrPage.UPDATE;
                    end;
                }
                field(Description; Description)
                {
                }
                field("PM Group Code"; "PM Group Code")
                {
                }
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field(Name; Name)
                {
                }
                field("Serial No."; "Serial No.")
                {
                }
                field(Status; Status)
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Version No."; "Version No.")
                {
                }
                field("Starting Date"; "Starting Date")
                {
                }
                field("Person Responsible"; "Person Responsible")
                {
                }
                field("Contains Critical Control"; "Contains Critical Control")
                {
                }
                field("PM Work Order No. Series"; "PM Work Order No. Series")
                {
                }
            }
            part("PM Procedure Subform"; "PM Proc. Subform ELA")
            {
                SubPageLink = "PM Procedure Code" = FIELD(Code), "Version No." = FIELD("Version No.");
            }
            group(Scheduling)
            {
                Caption = 'Scheduling';
                field("PM Scheduling Type"; "PM Scheduling Type")
                {
                    Editable = "PM Scheduling TypeEditable";
                    trigger OnValidate()
                    begin
                        jfdoSetEditable;
                    end;
                }
                field("Work Order Freq."; "Work Order Freq.")
                {
                    Editable = "Work Order Freq.Editable";
                }
                group(groupName)
                {
                    field("Evaluation Qty."; "Evaluation Qty.")
                    {
                        Editable = "Evaluation Qty.Editable";
                    }
                    field(CapUOM1; grecWorkCenter."Unit of Measure Code")
                    {
                        Caption = 'Evaluation UOM';
                        Editable = false;
                    }
                }
                field("Schedule at %"; "Schedule at %")
                {
                    Editable = "Schedule at %Editable";
                }
                field("Maintenance Time"; "Maintenance Time")
                {
                }
                field(MaintUOM; "Maintenance UOM")
                {
                    Caption = 'Maintenance UOM';
                }
                field("Multiple Calc. Methods"; "Multiple Calc. Methods")
                {

                    trigger OnValidate()
                    begin
                        jfdoSetEditable;
                    end;
                }
            }
        }
        area(FactBoxes)
        {
            part("PM Sched. Statistics FactBox"; "PM Sched. Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = Code = field(Code), "Version No." = field("Version No.");
            }
        }

    }

    actions
    {
        area(Processing)
        {
            group("My Procedure")
            {
                action(Comments)
                {
                    ApplicationArea = All;
                    RunObject = page "PM Proc. Comments";
                    RunPageLink = "PM Procedure Code" = field(Code), "Version No." = field("Version No."), "PM Procedure Line No." = const(0);
                    Image = ListPage;
                }
                action("Open Work Orders")
                {
                    ApplicationArea = All;
                    RunObject = page "PM Work Order List";
                    RunPageLink = "PM Procedure Code" = field(Code);
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = Document;
                }
                action("Finished Work Orders")
                {
                    ApplicationArea = All;
                    RunObject = page "Fin. Work Order List";
                    RunPageLink = "PM Procedure Code" = field(Code);
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = Document;
                }

            }
            group(Functions)
            {
                action("Go to Active Version")
                {
                    ApplicationArea = All;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    begin
                        Rec.GET(Code, gcduPMVersionMgt.GetActiveVersion(Code));
                    end;
                }
                action("Create New Version")
                {
                    ApplicationArea = All;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    begin
                        gcduPMVersionMgt.CreateNewVersion(Rec);
                    end;
                }
                action("Calc. Methods")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = page "PM Calc. Methods";
                    RunPageLink = "PM Procedure Code" = field(Code), "Version No." = field("Version No."), Type = field(Type);

                }
            }
            group(Print)
            {
                action("PM Procedure")
                {
                    ApplicationArea = All;
                    Image = Report;
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        grecPMProcedure.SETRANGE(Code, Code);
                        grecPMProcedure.SETRANGE("Version No.", "Version No.");
                        //REPORT.RUN(REPORT::"PM Procedure", TRUE, FALSE, grecPMProcedure);
                    end;
                }
            }
        }

    }
    var
        gcduPMVersionMgt: Codeunit "PM Management ELA";
        grecPMProcedure: Record "PM Procedure Header ELA";
        grecWorkCenter: Record "Work Center";
        grecMachineCenter: Record "Machine Center";
        grecFixedAsset: Record "Fixed Asset";
        gdecCyclesPct: Decimal;
        "PM Scheduling TypeEditable": Boolean;
        "Schedule at %Editable": Boolean;
        "Evaluation Qty.Editable": Boolean;
        "Work Order Freq.Editable": Boolean;

    trigger OnAfterGetRecord()
    begin
        jfdoSetEditable;
    end;

    trigger OnInit()
    begin
        "Work Order Freq.Editable" := TRUE;
        "Evaluation Qty.Editable" := TRUE;
        "Schedule at %Editable" := TRUE;
        "PM Scheduling TypeEditable" := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        jfdoSetEditable;
    end;


    procedure jfdoSetEditable()
    var
        lblnEvalQtyEdit: Boolean;
        lblnCapUOM1Visible: Boolean;
        lblnCapUOM2Visible: Boolean;
    begin
        "PM Scheduling TypeEditable" := NOT "Multiple Calc. Methods";
        "Work Order Freq.Editable" := NOT "Multiple Calc. Methods";
        "Evaluation Qty.Editable" := NOT "Multiple Calc. Methods";
        "Schedule at %Editable" := NOT "Multiple Calc. Methods";

        "Work Order Freq.Editable" := "PM Scheduling Type" = "PM Scheduling Type"::Calendar;

        lblnEvalQtyEdit :=
          ("PM Scheduling Type" = "PM Scheduling Type"::Cycles) OR
          ("PM Scheduling Type" = "PM Scheduling Type"::"Qty. Produced") OR
          ("PM Scheduling Type" = "PM Scheduling Type"::"Run Time") OR
          ("PM Scheduling Type" = "PM Scheduling Type"::"Stop Time");

        "Evaluation Qty.Editable" := lblnEvalQtyEdit;

        IF Type = Type::"Work Center" THEN
            IF grecWorkCenter.GET("No.") THEN;
        IF Type = Type::"Machine Center" THEN BEGIN
            IF grecMachineCenter.GET("No.") THEN;
            IF grecWorkCenter.GET(grecMachineCenter."Work Center No.") THEN;
        END;
    end;


}

