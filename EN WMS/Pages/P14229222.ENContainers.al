//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Containers (ID 14229222).
/// </summary>
page 14229222 "Containers ELA"
{
    ApplicationArea = Warehouse;
    Caption = 'Containers';
    PageType = Worksheet;
    SourceTable = "Container ELA";
    UsageCategory = Lists;
    CardPageId = "Container Card ELA";
    SourceTableView = sorting("No.");
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("Closed"; Rec.Closed)
                {
                    ApplicationArea = Warehouse;
                }
                field("Container Type"; Rec."Container Type")
                {
                    ApplicationArea = Warehouse;
                }
                field("Load No."; Rec."Load No.")
                {
                    ApplicationArea = Warehouse;
                }
                // field("Shipment No."; Rec."Shipment No.")
                // {
                //     ApplicationArea = Warehouse;
                // }
                field("Document Status"; Rec."Document Status")
                {
                    ApplicationArea = Warehouse;
                }
                field(Location; Rec."Location Code")
                {
                    ApplicationArea = Warehouse;
                }
                field("Parent Container No."; Rec."Parent Container No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = Warehouse;
                }
                field("Tare Weight"; Rec."Tare Weight")
                {
                    ApplicationArea = Warehouse;
                }
                field("Freight Charges"; Rec."Freight Charges")
                {
                    ApplicationArea = Warehouse;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Process)
            {
                action("New")
                {
                    ApplicationArea = Suite;
                    Caption = 'New';
                    image = New;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortcutKey = 'F3';
                    ToolTip = 'Create a new container';
                    trigger OnAction()
                    var
                        SourceDocType: Enum "WMS Source Doc Type ELA";
                        WhseDocType: Enum "Whse. Doc. Type ELA";
                        WMSActivityType: Enum "WMS Activity Type ELA";
                        DocumentNo: code[20];
                        WhseDocNo: code[20];
                        Location: code[20];
                        WMSAcitivityNo: code[20];
                        ContainerMgmt: Codeunit "Container Mgmt. ELA";
                        WhseRcptHdr: record "Warehouse Receipt Header";
                        PurchaseHeader: record "Purchase Header";
                        SalesHeader: record "Sales Header";
                    begin
                        //DocumentNo := GetFilter("Document No.");
                        //WhseDocNo := GetFilter("Whse. Document No.");
                        // WMSAcitivityNo := GetFilter("Activity No.");
                        //if WMSAcitivityNo <> '' then
                        //  evaluate(WMSActivityType, GetFilter("Activity Type"));

                        /*if DocumentNo <> '' then begin
                            Evaluate(SourceDocType, GetFilter("Source Document Type"));
                            if SourceDocType = SourceDocType::"Purchase Order" then begin
                                PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocumentNo);
                                ContainerMgmt.CreateNewContainer("Load No.", '', SourceDocType, PurchaseHeader."Document Type", DocumentNo, WhseDocType, WhseDocNo,
                                    WMSActivityType, WMSAcitivityNo, PurchaseHeader."Location Code", true);
                            end;

                            if SourceDocType = SourceDocType::"Sales Order" then begin
                                SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo);
                                ContainerMgmt.CreateNewContainer("Load No.", '', SourceDocType, SalesHeader."Document Type", DocumentNo, WhseDocType, WhseDocNo,
                                 WMSActivityType, WMSAcitivityNo, SalesHeader."Location Code", true);
                            end;
                        end else
                            if (WhseDocNo <> '') then begin
                             //   Evaluate(WhseDocType, GetFilter("Whse. Document Type"));
                                if WhseDocType = WhseDocType::Receipt then begin
                                    WhseRcptHdr.Get(WhseDocNo);
                                    ContainerMgmt.CreateNewContainer("Load No.", '', SourceDocType, 0, DocumentNo, WhseDocType, WhseDocNo,
                                     WMSActivityType, WMSAcitivityNo, WhseRcptHdr."Location Code", true);
                                end;
                            end;*/
                        //  Enum::"EN Whse. Doc. Type".FromInteger("EN Whse. Doc. Type".Ordinals.Get("EN Whse. Doc. Type".Names.IndexOf(GetFilter("Whse. Document Type")));
                        // WhseDocType. GetFilter("Whse. Document Type").;
                    end;
                }

                action(Edit)
                {
                    ApplicationArea = Suite;
                    Caption = 'Edit';
                    image = Edit;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortcutKey = 'F2';
                    ToolTip = 'Edit a container';
                    trigger OnAction()
                    var
                        Container: record "Container ELA";
                        ContainerCard: page "Container Card ELA";
                    // ContainerMgmt: Codeunit "EN Container Mgmt.";
                    begin
                        if Container.Get("No.") then begin
                            ContainerCard.SetRecord(Container);
                            ContainerCard.Run();
                        end;

                        /* ContainerMgmt.ShowContainer("Source Document Type", "No.", "Location Code", "Document Type",
                           "Document No.", "Whse. Document Type", "Whse. Document No."*/
                        // );
                        //(SourceDocType, '', Location, DocumentType, DocumentNo, WhseDocType::Receipt, WhseDocNo);
                    end;
                }
            }
        }
    }

    // trigger OnNewRecord(BelowxRec: Boolean)
    // var
    // begin
    //     Message('On new record %1', rec.GetFilters());
    // end;

    // trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    // var
    // begin
    //     Message('On Insert record %1', rec.GetFilters());
    //     exit(true);
    // end;
}
