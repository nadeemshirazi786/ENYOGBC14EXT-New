page 14229242 "Containers Contents ELA"
{
    ApplicationArea = Warehouse;
    Caption = 'Containers';
    PageType = Worksheet;
    SourceTable = "Container Content ELA";
    UsageCategory = Lists;
    //CardPageId = "EN Container Card";
    SourceTableView = sorting("Container No.", "Line No.");
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Container No."; Rec."Container No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Location; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("License Plate No."; Rec."License Plate No.")
                {
                    ApplicationArea = All;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                }
                // field("Pallet No."; Rec."Pallet No.")
                // {
                //     ApplicationArea = All;
                // }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                }

                field("Activty Type"; "Activity Type")
                {
                    ApplicationArea = All;
                }

                field("Activity No."; "Activity No.")
                {
                    ApplicationArea = All;
                }

                field("Activity Line No."; "Activity Line No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Whse. Document Type"; "Whse. Document Type")
                {
                    ApplicationArea = All;
                }
                field("Whse. Document No."; "Whse. Document No.")
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
            group(Process)
            {
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
                        if Container.Get(Rec."Container No.") then begin
                            ContainerCard.SetRecord(Container);
                            ContainerCard.Run();
                        end;

                        // ContainerMgmt.ShowContainer("Source Document Type", "No.", "Location Code", "Document Type",
                        //   "Document No.", "Whse. Document Type", "Whse. Document No."
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