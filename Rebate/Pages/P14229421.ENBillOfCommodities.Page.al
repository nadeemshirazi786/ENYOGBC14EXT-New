page 14229421 "Bill of Commodities ELA"
{

    // ENRE1.00 2021-09-08 AJ
    //   ENRE1.00 - New page
    //   ENRE1.00 - renumbered

    //Caption = 'Bill of Commodities';
    PageType = Document;
    SourceTable = "Item BOC Header ELA";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Commodity Relationship"; "Commodity Relationship")
                {
                    ApplicationArea = All;
                }
                field("No. Servings"; "No. Servings")
                {
                    ApplicationArea = All;
                }
                field("Net Weight"; "Net Weight")
                {
                    ApplicationArea = All;
                }
            }
            part(BOCLines; "Bill of Commodities Sform ELA")
            {
                ApplicationArea = All;
                SubPageLink = "Item BOC No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action23019014>")
            {
                Caption = 'Bill of Commodities';
            }
        }
        area(processing)
        {
            group("<Action23019016>")
            {
                Caption = 'F&unctions';
                action("Copy BOC")
                {
                    ApplicationArea = All;
                    Caption = 'Copy BOC';
                    Image = Copy;

                    trigger OnAction()
                    begin

                        TestField("No.");
                        if PAGE.RunModal(0, grecItemBOCHeader) = ACTION::LookupOK then
                            CopyBOC(grecItemBOCHeader."No.", Rec);
                    end;
                }
            }
        }
    }

    var
        grecItemBOCHeader: Record "Item BOC Header ELA";
}

