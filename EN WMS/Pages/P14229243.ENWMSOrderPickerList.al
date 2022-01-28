page 14229243 "WMS Order Picker List ELA"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WMS Order Picker ELA";
    SourceTableTemporary = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Picker Code"; "Picker Code")
                {
                    ApplicationArea = All;
                }
                field("Order No."; "Order No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        IF "Order No." <> xRec."Order No." THEN
                            RemovePicker;
                        AssignPicker;
                        CheckPicks;
                    end;
                }
                field("Pick Created"; "Pick Created")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Shipment No."; "Shipment No.")
                {
                    ApplicationArea = All;
                }
                field("Trip ID"; "Trip ID")
                {
                    ApplicationArea = All;
                }
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
    trigger OnOpenPage()
    var
        OrderPicker: Record "WMS Order Picker ELA" temporary;
    begin

        ShptDash.RESET;
        ShptDash.SETFILTER(Level, '=%1', 1);
        ShptDash.SETFILTER(ShptDash."Assigned App. User", '<>%1', '');
        IF ShptDash.FINDSET THEN
            REPEAT
                IF NOT Rec.GET(ShptDash."Assigned App. User", ShptDash."Source No.", ShptDash.Location) THEN BEGIN
                    Rec.INIT;
                    Rec."Picker Code" := ShptDash."Assigned App. User";
                    Rec."Order No." := ShptDash."Source No.";
                    Rec."Location Code" := ShptDash.Location;        //EN1.01
                    Rec."Shipment No." := ShptDash."Shipment No.";    //EN1.03
                                                                      //TR Rec."Trip ID" := ShptDash."Trip ID";               //EN1.03
                                                                      //<<EN1.02
                    WhseActivityLine.RESET;
                    WhseActivityLine.SETFILTER(WhseActivityLine."Source No.", ShptDash."Source No.");
                    WhseActivityLine.SETFILTER(WhseActivityLine."Assigned App. User ELA", ShptDash."Assigned App. User");
                    WhseActivityLine.SETFILTER(WhseActivityLine."Location Code", ShptDash.Location);
                    IF WhseActivityLine.FINDFIRST THEN
                        Rec."Pick Created" := TRUE;
                    //>>EN1.02
                    INSERT;
                END;
            UNTIL ShptDash.NEXT = 0;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

        AssignPicker;
        CheckPicks;
    end;

    trigger OnModifyRecord(): Boolean
    begin

        IF "Order No." <> xRec."Order No." THEN
            RemovePicker;
        AssignPicker;
        CheckPicks;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        RemovePicker();
    end;


    local procedure AssignPicker()
    begin
        ShptDash.RESET;
        ShptDash.SETFILTER(ShptDash."Source No.", "Order No.");
        ShptDash.SETFILTER(Level, '=%1', 1);               //EN1.02
        ShptDash.SETFILTER("Assigned App. User", '');           //EN1.02
                                                                //<<EN1.02
        IF ShptDash.FINDSET THEN
            REPEAT
                ShptDash.VALIDATE(ShptDash."Assigned App. User", "Picker Code");
                ShptDash.MODIFY;
            UNTIL ShptDash.NEXT = 0;
        //>>EN1.02
    end;


    local procedure RemovePicker()
    begin
        ShptDash.RESET;
        ShptDash.SETFILTER(ShptDash."Source No.", xRec."Order No.");
        ShptDash.SETFILTER(Level, '=%1', 1);                      //EN1.02
        ShptDash.SETFILTER("Assigned App. User", xRec."Picker Code");  //EN1.02
                                                                       //<<En1.02
        IF ShptDash.FINDSET THEN
            REPEAT
                ShptDash.VALIDATE(ShptDash."Assigned App. User", '');
                ShptDash.MODIFY;
            UNTIL ShptDash.NEXT = 0;
        //>>EN1.02
    end;


    local procedure CheckPicks()
    begin
        WhseActivityLine.RESET;
        WhseActivityLine.SETFILTER(WhseActivityLine."Source No.", "Order No.");
        WhseActivityLine.SETFILTER(WhseActivityLine."Assigned App. User ELA", "Picker Code");   //EN1.02
        IF WhseActivityLine.FINDFIRST THEN
            Rec."Pick Created" := TRUE;
    end;


    var
        ShptDash: Record "Shipment Dashboard ELA";
        WhseActivityLine: Record "Warehouse Activity Line";
        WMSLoginMgt: Codeunit "App. Login Mgmt. ELA";
}