page 14229122 "EN Finished Repack Order"
{


    Caption = 'Finished Repack Order';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "EN Repack Order";
    SourceTableView = WHERE(Status = CONST(Finished));



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
                field(Quantity; Quantity)
                {

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate;
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }

                field("Quantity Produced"; "Quantity Produced")
                {
                }

                field("Destination Location"; "Destination Location")
                {
                }
                field("Bin Code"; "Bin Code")
                {
                }
            }
            part(RepackLines; "EN Finished Repack Order Subf.")
            {
                SubPageLink = "Order No." = FIELD("No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Repack Location"; "Repack Location")
                {
                }
                field(PostingDate2; "Posting Date")
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
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Navigate;
                end;
            }
        }
    }

    local procedure ItemNoOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure QuantityOnAfterValidate()
    begin
        CurrPage.Update;
    end;
}

