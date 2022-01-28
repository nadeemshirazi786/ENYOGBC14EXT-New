//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Container Card (ID 14229224).
/// </summary>
page 14229223 "Container Card ELA"
{
    //TODO #19 @Kamranshehzad Create report for license plate no 
    //todo #20 @Kamranshehzad add assign content 
    Caption = 'Container Card';
    PageType = Document;
    SourceTable = "Container ELA";
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = NOT IsContainerClosed;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("Closed"; Rec."Closed")
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
                field("Direction"; "Direction")
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
            part(Contents; "Container Subform ELA")
            {
                Editable = NOT IsContainerClosed;
                Caption = 'Contents';
                SubPageLink = "Container No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Process)
            {

                // action("Assign Content")
                // {
                //     ApplicationArea = Suite;
                //     Caption = 'Assign &Content';
                //     Image = ResourceGroup;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     PromotedIsBig = true;
                //     ShortCutKey = 'F6';
                //     ToolTip = 'Add Items';
                //     trigger OnAction()
                //     var
                //         ContMgmt: Codeunit "EN Container Mgmt.";
                //         WhseDocType: enum "EN Whse. Doc. Type";
                //         AssignContents: page "EN Assign Container Contents";
                //         SourceDocTypeFilter: Enum "EN WMS Source Doc Type";
                //     begin
                //         AssignContents.SetDocumentFilters(SourceDocTypeFilter::"Purchase Order", "Document Type", "No.", 0,
                //                        WhseDocType, '', '', false);
                //         AssignContents.Run();

                //         // ContMgmt.ShowContainer('', "Location Code", 0, '', WhseDocType::Receipt, "No.");
                //     end;
                // }

                action("Close")
                {
                    ApplicationArea = Suite;
                    Caption = 'Close';
                    image = Close;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortcutKey = 'F10';
                    ToolTip = 'Close the Container';
                    trigger OnAction()
                    begin
                        IsContainerClosed := true;
                        ContainerMgmt.CloseContainer("No.");
                    end;
                }

                action("Re-Open")
                {
                    ApplicationArea = Suite;
                    Caption = 'Re-Open';
                    image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortcutKey = 'F11';
                    ToolTip = 'Re-open the Container';
                    trigger OnAction()
                    begin
                        IsContainerClosed := false;
                        ContainerMgmt.ReOpenContainer("No.");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
    begin
        if Closed then
            IsContainerClosed := true
        else
            IsContainerClosed := false;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
    begin
        // Message('%1', FilterGroup(2));
        FilterGroup(2);
        Message('On new record %1 %2', rec.GetFilters(), xrec.GetFilters());
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
    begin
        FilterGroup(2);
        Message('On Insert record %1', rec.GetFilters());
        exit(true);
    end;

    var
        [InDataSet]
        IsContainerClosed: Boolean;
        ContainerMgmt: codeunit "Container Mgmt. ELA";


}
