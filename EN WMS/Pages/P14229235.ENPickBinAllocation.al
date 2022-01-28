//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page Picking Bin Allocation (ID 14229235).
/// </summary>
page 14229235 "Picking Bin Allocation ELA"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Warehouse Activity Line";
    SourceTableTemporary = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Released To Pick"; "Released To Pick ELA")
                {
                    Caption = 'Select';

                    trigger OnValidate()
                    begin
                        if "Released To Pick ELA" then
                            DoSingleOrderSelection(true)
                        else
                            DoSingleOrderSelection(false);
                    end;
                }
                field("No."; "No.")
                {
                }
                field("Line No."; "Line No.")
                {
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    Caption = 'Order No.';
                }
                field("Location Code"; "Location Code")
                {
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                }
                field(Description; Description)
                {
                }
                field(Quantity; Quantity)
                {
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }
                field("Zone Code"; "Zone Code")
                {

                    trigger OnValidate()
                    var
                        WhseActLine: Record "Warehouse Activity Line";
                    begin
                        if WhseActLine.Get(WhseActLine."Activity Type"::Pick, "No.", "Line No.") then begin
                            WhseActLine."Zone Code" := "Zone Code";
                            WhseActLine.Modify;
                        end;
                    end;
                }
                field("Bin Code"; "Bin Code")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        BinCode: Code[20];
                        VariantCode: Code[10];
                        CodeDate: Date;
                    begin
                        // /BinCode := WMSMgt.BinContentLookUp("Location Code", "Item No.", VariantCode, "Zone Code", "Bin Code", CodeDate); //EN1.01
                        BinCode := WMSMgt.BinContentLookUp("Location Code", "Item No.", VariantCode, "Zone Code", "Bin Code");
                        if BinCode <> '' then begin
                            Text := BinCode;
                            // "Code Date" := CodeDate; //EN1.05
                            exit(true);
                        end
                    end;

                    trigger OnValidate()
                    var
                        WhseActLine: Record "Warehouse Activity Line";
                    begin
                        //<<EN1.02 + EN1.05
                        if "Bin Code" = '' then begin
                            "Zone Code" := '';
                            // "Code Date" := 0D;
                        end;
                        //>>EN1.02 + EN1.05

                        if WhseActLine.Get(WhseActLine."Activity Type"::Pick, "No.", "Line No.") then begin
                            if WhseActLine."Action Type" = WhseActLine."Action Type"::Take then begin
                                WhseActLine.Validate("Bin Code", "Bin Code");
                                WhseActLine.Modify;
                            end;
                        end;
                    end;
                }
                field("Special Equipment Code"; "Special Equipment Code")
                {
                }
                // field("Code Date"; "Code Date")
                // {
                //     Editable = false;
                // }
                // field(CalcRemainingLife; CalcRemainingLife)
                // {
                //     Caption = 'Days Left';
                //     Editable = false;
                //     Style = Favorable;
                //     StyleExpr = TRUE;
                // }
                field("Expiration Date"; "Expiration Date")
                {
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    Visible = false;
                }
                field("Bin Ranking"; "Bin Ranking")
                {
                }
                field("Assigned Role"; "Assigned App. Role ELA")
                {
                    Caption = 'Assigned Role';
                }
                field("Ship Action"; "Ship Action ELA")
                {
                    Editable = false;
                }
                field("Assigned To"; "Assigned App. User ELA")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("<Action1000000020>")
            {
                Caption = 'Functions';
                action("<Action1000000022>")
                {
                    Caption = 'Release to &Pick';
                    Image = RegisterPick;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ReleaseToPick;
                    end;
                }
                action("&Refresh (F2)")
                {
                    Caption = '&Refresh (F2)';
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F2';

                    trigger OnAction()
                    begin
                        PopulatePage;
                    end;
                }
                action("<Action1000000021>")
                {
                    Caption = '&Select All';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        DoAllOrdersSelection(true);
                    end;
                }
                action("&De-Select All")
                {
                    Caption = '&De-Select All';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        DoAllOrdersSelection(false);
                    end;
                }
                action("<Action1000000026>")
                {
                    Caption = 'S&how Released';
                    Image = ShowList;
                    Visible = false;

                    trigger OnAction()
                    begin
                        ShowReleased := true;
                        PopulatePage;
                    end;
                }
                action("&Delete Pick")
                {
                    Caption = '&Delete Pick';
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        WhseActHdr: Record "Warehouse Activity Header";
                    begin
                        //<<EN1.02
                        if Confirm(StrSubstNo(TEXT001, "No.", "Source No."), false) then begin
                            WhseActHdr.Get("Activity Type", "No.");
                            WhseActHdr.Delete(true);
                            PopulatePage;
                        end;
                        //>>EN1.02
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        PopulatePage;
    end;

    var
        WMSMgt: Codeunit "WMS Management";
        ShipDashbrdMgt: Codeunit "Shipment Mgmt. ELA";
        Selected: Boolean;
        ShowReleased: Boolean;
        TEXT001: Label 'Do you want to delete Pick No. %1 for Order No. %2?';

    procedure DoSingleOrderSelection(NewStatus: Boolean)
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin
        Reset;
        SetRange("No.", "No.");
        ModifyAll("Released To Pick ELA", NewStatus);

        Reset;
        CurrPage.Update;
    end;

    procedure DoAllOrdersSelection(NewStatus: Boolean)
    begin
        Reset;
        ModifyAll("Released To Pick ELA", NewStatus);

        Reset;
        CurrPage.Update;
    end;

    procedure ReleaseToPick()
    var
        WhseActLine: Record "Warehouse Activity Line";
        TmpWhseActLine: Record "Warehouse Activity Line" temporary;
        TmpWhseActHdr: Record "Warehouse Activity Header" temporary;
        ShipDashBrd: Codeunit "Shipment Mgmt. ELA";
    begin
        TmpWhseActLine.Reset;
        TmpWhseActLine.DeleteAll;
        TmpWhseActHdr.Reset;
        TmpWhseActHdr.DeleteAll;

        Reset;
        SetFilter("Released To Pick ELA", '%1', true);
        if FindSet then
            repeat
                TmpWhseActLine.Init;
                TmpWhseActLine.Copy(Rec);
                TmpWhseActLine.Insert;
            until Next = 0;

        TmpWhseActLine.Reset;
        if TmpWhseActLine.FindSet then
            repeat
                WhseActLine.Reset;
                WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
                WhseActLine.SetRange(WhseActLine."No.", TmpWhseActLine."No.");
                WhseActLine.SetRange("Released To Pick ELA", false);
                if WhseActLine.FindSet then begin
                    repeat
                        if (WhseActLine."Line No." = TmpWhseActLine."Line No.") and
                           (WhseActLine."Bin Code" <> TmpWhseActLine."Bin Code") and
                           (WhseActLine."Action Type" = WhseActLine."Action Type"::Take)
                        then begin
                            WhseActLine."Zone Code" := TmpWhseActLine."Zone Code";
                            WhseActLine.Validate("Bin Code", TmpWhseActLine."Bin Code");
                        end;

                        if WhseActLine."Line No." = TmpWhseActLine."Line No." then begin
                            // WhseActLine.Validate("Released To Pick", TmpWhseActLine."Released To Pick");
                            //todo @Kamranshehzad add release to pick document from warehouse pick and setting for auto release.

                            WhseActLine."Special Equipment Code" := TmpWhseActLine."Special Equipment Code";
                            WhseActLine.Validate("Assigned App. Role ELA", TmpWhseActLine."Assigned App. Role ELA");
                            WhseActLine."Assigned App. User ELA" := TmpWhseActLine."Assigned App. User ELA";
                            WhseActLine.Modify;
                            ShipDashbrdMgt.ReleasePickDocument(WhseActLine."No.");
                            //commit; //do we need commit?
                        end;

                    until WhseActLine.Next = 0;
                end;
            until TmpWhseActLine.Next = 0;
        Commit;


        TmpWhseActLine.Reset;
        TmpWhseActLine.SetRange("Released To Pick ELA", true);
        // TmpWhseActLine.SetRange("Receive To Pick", true);
        if TmpWhseActLine.FindSet then
            repeat
                if not TmpWhseActHdr.Get(TmpWhseActLine."Activity Type", TmpWhseActLine."No.") then begin
                    TmpWhseActHdr.Init;
                    TmpWhseActHdr.Type := TmpWhseActLine."Activity Type";
                    TmpWhseActHdr."No." := TmpWhseActLine."No.";
                    TmpWhseActHdr.Insert;
                end;
            until TmpWhseActLine.Next = 0;

        //todo #8 @Kamranshehzad add a flag here for bulk picking in wms roles
        // ShipDashbrdMgt.AutoAssignPallets("Source No.");

        CurrPage.Close;
        PopulatePage;

    end;

    procedure PopulatePage()
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin
        Clear(Rec);
        Reset;
        DeleteAll;
        WhseActLine.Reset;
        WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
        WhseActLine.SetRange("Action Type", WhseActLine."Action Type"::Take);
        WhseActLine.SetRange("Released To Pick ELA", ShowReleased);
        if WhseActLine.FindSet then
            repeat
                Rec.Init;
                Rec.Copy(WhseActLine);
                Rec.Insert;
            until WhseActLine.Next = 0;

        // SetCurrentKey("No.", "Item No.", "Code Date", Quantity);
        //ASCENDING(FALSE);

        CurrPage.Update;
    end;
}

