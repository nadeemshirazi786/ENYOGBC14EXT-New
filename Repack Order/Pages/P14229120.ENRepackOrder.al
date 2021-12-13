page 14229120 "EN Repack Order"
{


    Caption = 'Repack Order';
    PageType = Document;
    SourceTable = "EN Repack Order";
    SourceTableView = WHERE(Status = CONST(Open));
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Item No."; "Item No.")
                {
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        ItemNoOnAfterValidate;
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                }
                field(Description; Description)
                {
                }
                field("Description 2"; "Description 2")
                {
                }
                field("Lot No."; "Lot No.")
                {

                    trigger OnAssistEdit()
                    begin
                        LotNoAssistEdit;
                    end;
                }
                field(Farm; Farm)
                {
                }
                field(Brand; Brand)
                {
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                }
                field("Search Description"; "Search Description")
                {
                }
                field(PostingDate; "Posting Date")
                {
                }
                field("Date Required"; "Date Required")
                {
                }
                field("Due Date"; "Due Date")
                {
                }
                field(Quantity; Quantity)
                {
                    BlankZero = true;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate;
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }

                field("Quantity to Produce"; "Quantity to Produce")
                {
                }

                field("Destination Location"; "Destination Location")
                {
                    ShowMandatory = LocationCodeMandatory;
                }
                field("Bin Code"; "Bin Code")
                {
                }
            }
            part(RepackLines; "EN Repack Order Subform")
            {
                Caption = 'Lines';
                SubPageLink = "Order No." = FIELD("No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field(PostingDate2; "Posting Date")
                {
                }
                field("Repack Location"; "Repack Location")
                {
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Calculate Lines")
                {
                    Caption = 'Calculate Lines';
                    Image = CalculateLines;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        CalculateLines;
                    end;
                }
                action("Finish Order")
                {
                    Caption = 'Finish Order';
                    Image = Stop;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        FinishOrder;
                        CurrPage.Update(false);
                    end;
                }
                separator(Action37002058)
                {
                }
                action(Navigate)
                {
                    Caption = 'Navigate';
                    Image = Navigate;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Navigate;
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("P&ost")
                {
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Repack-Post (Yes/No)";
                    ShortCutKey = 'F9';
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action("Order")
                {
                    Caption = 'Order';
                    Ellipsis = true;
                    Image = "Order";
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        DocPrint: Codeunit "Document-Print";
                    begin
                        //DocPrint.PrintRepackOrder(Rec);TBR
                    end;
                }
                action(Labels)
                {
                    Caption = 'Labels';
                    Ellipsis = true;
                    Image = Text;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        PrintLabels;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetLocationCodeMandatory;
    end;

    var
        [InDataSet]
        LocationCodeMandatory: Boolean;

    local procedure ItemNoOnAfterValidate()
    begin
        CurrPage.Update;
    end;



    local procedure QuantityOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure SetLocationCodeMandatory()
    var
        InventorySetup: Record "Inventory Setup";
    begin

        InventorySetup.Get;
        LocationCodeMandatory := InventorySetup."Location Mandatory";
    end;
}

