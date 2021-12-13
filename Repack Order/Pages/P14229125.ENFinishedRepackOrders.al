page 14229125 "EN Finished Repack Orders"
{


    Caption = 'Finished Repack Orders';
    CardPageID = "EN Finished Repack Order";
    Editable = false;
    PageType = List;
    SourceTable = "EN Repack Order";
    SourceTableView = SORTING(Status)
                      WHERE(Status = CONST(Finished));
    ApplicationArea = All;
    UsageCategory = History;


    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                }
                field("Item No."; "Item No.")
                {
                }
                field("Variant Code"; "Variant Code")
                {
                    Visible = false;
                }
                field(Description; Description)
                {
                }
                field("Lot No."; "Lot No.")
                {
                }
                field(Brand; Brand)
                {
                }
                field(Farm; Farm)
                {
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field("Date Required"; "Date Required")
                {
                }
                field("Repack Location"; "Repack Location")
                {
                    Visible = false;
                }
                field("Destination Location"; "Destination Location")
                {
                }
                field(Quantity; Quantity)
                {
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
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
        }
    }
}

